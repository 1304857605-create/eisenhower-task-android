#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
四象限清单 (Quadrant List) — 应用图标生成脚本
=================================================

概念：四象限 + 一勾
  - 2×2 四块圆角方块 = 四象限矩阵（Q1 红 / Q2 蓝 / Q3 琥珀 / Q4 灰）
  - Q1（重要且紧急）被强调：放大 + 向外轻推 + 白色粗对勾
  - 白色对勾 = 清单被划掉 / 马上做（应用是清单，"勾"是它的母题）

实现要点：
  - 坐标全部用相对比例；无随机数、不联网、除 Pillow 外零依赖，可重复运行。
  - 每个尺寸先 4×/8× 超采样绘制，再 LANCZOS 降采样，边缘干净抗锯齿。
  - 小尺寸（<= 96px）额外做光学微调（缝隙加大、圆角微收、勾线加粗），避免降采样糊成色块。
  - adaptive foreground 内容外接框 ≈ 199px（< 285px 安全区上限），保证四块外角落在
    264px 安全圆内，圆形遮罩下不被切角。

用法：
  python generate_icon.py
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFont, ImageMath

OUT = Path(__file__).resolve().parent
CAND_DIR = OUT / "candidates"

# --------------------------------------------------------------------------
# 调色板（与应用四象限配色一致）
# --------------------------------------------------------------------------
WARM_WHITE = (247, 247, 245)   # #F7F7F5 浅色背景
GRAPHITE = (28, 29, 34)        # #1C1D22 石墨深色底
Q1_RED = (229, 72, 77)         # #E5484D 重要且紧急
Q2_BLUE = (59, 130, 246)       # #3B82F6 重要不紧急
Q3_AMBER = (232, 163, 61)      # #E8A33D 紧急不重要
Q4_GRAY = (139, 141, 152)      # #8B8D98 不重要不紧急
WHITE = (255, 255, 255)
PRIMARY = (61, 90, 128)        # #3D5A80 石墨蓝（主题色，仅预览用）

QUAD_COLORS = (Q1_RED, Q2_BLUE, Q3_AMBER, Q4_GRAY)
QUAD_NAMES = ("Q1 重要且紧急", "Q2 重要不紧急", "Q3 紧急不重要", "Q4 不重要不紧急")
QUAD_HEX = ("#E5484D", "#3B82F6", "#E8A33D", "#8B8D98")

# 统一嵌入 sRGB ICC profile，保证"PNG + sRGB"在任何看图/商店后台上色一致。
# 注意：Pillow/lcms 生成的 profile 头部带有"当前时间"，会让每次运行的 PNG 字节不同；
# 这里把 ICC 头部的 dateTimeNumber（offset 24..35）固定掉（profile ID 为空，因此安全），
# 保证脚本重复运行输出字节级一致。
try:
    from PIL import ImageCms

    def _srgb_icc_bytes() -> bytes:
        prof = bytearray(ImageCms.ImageCmsProfile(ImageCms.createProfile("sRGB")).tobytes())
        stamp = (2026, 1, 1, 0, 0, 0)  # year, month, day, hour, minute, second
        for i, value in enumerate(stamp):
            prof[24 + i * 2: 26 + i * 2] = int(value).to_bytes(2, "big")
        return bytes(prof)

    SRGB_ICC = _srgb_icc_bytes()
except Exception:  # 极少数 Pillow 构建不带 lcms
    SRGB_ICC = None


def save_png(im: Image.Image, path) -> None:
    im.save(str(path), format="PNG", optimize=True, icc_profile=SRGB_ICC)

# 统一的设计参数
DESIGN = dict(
    content=0.780,       # 四块外接框占画布比例（商店图标/旧版图标有底色，内容可更满）
    gap=0.098,           # 块间缝隙占画布比例
    radius=0.285,        # 圆角半径 / 块边长
    q1_scale=1.0,        # Q1 放大倍数（最终方案不放大，靠对勾高亮）
    q1_shift=0.0,        # Q1 向画布左上外推比例
    check=True,          # Q1 内白色对勾
    check_span=0.310,    # 对勾半跨度 / Q1 块边长
    check_stroke=0.170,  # 对勾线宽 / Q1 块边长
    mute=0.0,            # 非 Q1 块向底色混合的比例（0 = 不弱化）
    background=WARM_WHITE,
)


def design(**kw) -> dict:
    cfg = dict(DESIGN)
    cfg.update(kw)
    return cfg


# --------------------------------------------------------------------------
# 几何：返回四块矩形与圆角
# --------------------------------------------------------------------------
def geometry(cfg: dict, canvas: float):
    span = cfg["content"] * canvas
    gap = cfg["gap"] * canvas
    block = (span - gap) / 2.0
    x0 = (canvas - span) / 2.0
    y0 = x0
    step = block + gap

    cells = [
        (x0, y0, x0 + block, y0 + block),
        (x0 + step, y0, x0 + step + block, y0 + block),
        (x0, y0 + step, x0 + block, y0 + step + block),
        (x0 + step, y0 + step, x0 + step + block, y0 + step + block),
    ]

    # ---- Q1 强调：以自身中心放大 + 向画布左上外推 ----
    qx0, qy0, qx1, qy1 = cells[0]
    cx, cy = (qx0 + qx1) / 2.0, (qy0 + qy1) / 2.0
    half = block * cfg["q1_scale"] / 2.0
    shift = cfg["q1_shift"] * canvas
    cells[0] = (cx - half - shift, cy - half - shift, cx + half - shift, cy + half - shift)

    radius = cfg["radius"] * block

    # ---- 归一化：内容外接框最大边 = content * canvas ----
    bx0 = min(c[0] for c in cells)
    by0 = min(c[1] for c in cells)
    bx1 = max(c[2] for c in cells)
    by1 = max(c[3] for c in cells)
    bbox_side = max(bx1 - bx0, by1 - by0)
    target = cfg["content"] * canvas
    k = target / bbox_side if cfg.get("fit", True) else 1.0

    mx = my = canvas / 2.0
    cells = [((u - mx) * k + mx, (v - my) * k + my, (w - mx) * k + mx, (z - my) * k + my)
             for (u, v, w, z) in cells]
    return cells, radius * k


# --------------------------------------------------------------------------
# 白色对勾（粗线 + 圆头 + 圆角转折，48px 下仍可读）
# --------------------------------------------------------------------------
def draw_check(draw: ImageDraw.ImageDraw, rect, cfg: dict, fill=WHITE + (255,)):
    x0, y0, x1, y1 = rect
    b = x1 - x0
    cx, cy = (x0 + x1) / 2.0, (y0 + y1) / 2.0
    s = cfg["check_span"] * b
    w = cfg["check_stroke"] * b
    # 勾的包围盒并不以块中心对称（右上长臂更长），整体偏移，让白色包围盒光学居中
    ox = cx - 0.045 * s
    oy = cy - 0.030 * s

    pts = [
        (ox - 0.86 * s, oy + 0.10 * s),
        (ox - 0.20 * s, oy + 0.76 * s),
        (ox + 0.95 * s, oy - 0.70 * s),
    ]
    draw.line(pts, fill=fill, width=max(1, int(round(w))), joint="curve")
    r = w / 2.0
    for px, py in (pts[0], pts[-1]):
        draw.ellipse([px - r, py - r, px + r, py + r], fill=fill)


# --------------------------------------------------------------------------
# 渲染：超采样 -> LANCZOS
# --------------------------------------------------------------------------
def supersample_for(size: int) -> int:
    return 4 if size > 512 else 8


def resize_rgba(img: Image.Image, size: int) -> Image.Image:
    """预乘 alpha 后再 LANCZOS 降采样，避免透明图边缘出现"黑边/脏边"。

    普通 RGBA 直接缩放会把透明像素的黑色 RGB 混进边缘，形成 1px 暗边；
    预乘 -> 缩放 -> 反预乘 是标准做法，且不需要 Pillow 以外的库。
    """
    if img.mode != "RGBA":
        return img.resize((size, size), Image.LANCZOS)
    r, g, b, a = img.split()
    pre = Image.merge("RGBA", (ImageChops.multiply(r, a), ImageChops.multiply(g, a),
                               ImageChops.multiply(b, a), a))
    pre = pre.resize((size, size), Image.LANCZOS)
    r, g, b, a = pre.split()
    a_safe = a.point(lambda v: v if v else 1)

    def un(c):
        out = ImageMath.lambda_eval(lambda x: x["c"] * 255 / x["a"], c=c, a=a_safe)
        return out.convert("L")

    return Image.merge("RGBA", (un(r), un(g), un(b), a))


def optical_cfg(cfg: dict, size: int) -> dict:
    """小尺寸光学微调：缝隙略加大、圆角略收、勾线略加粗。"""
    if size > 96:
        return cfg
    tuned = dict(cfg)
    k = (96 - size) / 96.0 * 0.35     # 96 -> 0, 48 -> 0.175
    tuned["gap"] = cfg["gap"] * (1.0 + 0.16 * k)
    tuned["radius"] = cfg["radius"] * (1.0 - 0.10 * k)
    tuned["check_stroke"] = cfg["check_stroke"] * (1.0 + 0.14 * k)
    return tuned


def render(
    cfg: dict,
    size: int,
    *,
    background=None,
    bg_radius: float | None = None,
    fit: bool = True,
    color=None,
    knockout_check: bool = False,
    **overrides,
) -> Image.Image:
    """渲染正方形图标（RGBA）。background=None 透明；color 为单色覆盖；knockout_check 把勾挖空。"""
    cfg = dict(cfg)
    cfg.update(overrides)
    cfg["fit"] = fit
    ss = supersample_for(size)
    canvas = size * ss
    subs = optical_cfg(cfg, size)

    img = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    if background is not None:
        if bg_radius is None:
            draw.rectangle([0, 0, canvas - 1, canvas - 1], fill=background + (255,))
        else:
            draw.rounded_rectangle([0, 0, canvas - 1, canvas - 1],
                                   radius=bg_radius * canvas, fill=background + (255,))

    cells, radius = geometry(subs, canvas)

    # 配色（可选：非 Q1 块向底色混合，做视觉层级）
    mix_bg = background if background is not None else cfg.get("background", WARM_WHITE)
    mute = cfg.get("mute", 0.0)
    fills = []
    for i, c in enumerate(QUAD_COLORS):
        if color is not None:
            fills.append(color)
        elif mute and i > 0:
            fills.append(tuple(int(round(c[j] * (1 - mute) + mix_bg[j] * mute)) for j in range(3)))
        else:
            fills.append(c)

    for (x0, y0, x1, y1), fill in zip(cells, fills):
        draw.rounded_rectangle([x0, y0, x1, y1], radius=radius, fill=fill + (255,))

    if subs["check"]:
        fill = (0, 0, 0, 0) if knockout_check else WHITE + (255,)
        draw_check(draw, cells[0], subs, fill=fill)

    return resize_rgba(img, size)


# --------------------------------------------------------------------------
# 最终选型（候选对比后确定）
# --------------------------------------------------------------------------
FINAL = design()

# 自适应前景：432 图中内容外接框 ≈ 199px（含抗锯齿羽边约 204px，远低于 285px 安全区上限）。
# 四块外角顶点距中心 = 0.654 * 199 ≈ 130px < 132px（66dp 安全圆半径），圆形/异形遮罩都不切角。
ADAPTIVE_CONTENT = 0.460


# --------------------------------------------------------------------------
# 字体 / 预览辅助
# --------------------------------------------------------------------------
def load_font(size: int, bold: bool = False):
    names = ("msyhbd.ttc", "msyh.ttc") if bold else ("msyh.ttc", "msyhbd.ttc")
    for name in names:
        p = Path(r"C:\Windows\Fonts") / name
        if p.exists():
            try:
                return ImageFont.truetype(str(p), size)
            except OSError:
                pass
    try:
        return ImageFont.load_default(size)
    except TypeError:  # Pillow < 10.1
        return ImageFont.load_default()


def paste_rgba(base: Image.Image, im: Image.Image, xy) -> None:
    base.alpha_composite(im.convert("RGBA"), dest=xy)


def masked_icon(fg: Image.Image, bg: Image.Image, size_out: int, kind: str,
                ratio: float = 0.0) -> Image.Image:
    comp = Image.alpha_composite(bg.convert("RGBA"), fg.convert("RGBA"))
    s = comp.width
    mask = Image.new("L", (s, s), 0)
    md = ImageDraw.Draw(mask)
    if kind == "circle":
        md.ellipse([0, 0, s - 1, s - 1], fill=255)
    else:
        md.rounded_rectangle([0, 0, s - 1, s - 1], radius=int(ratio * s), fill=255)
    comp.putalpha(mask)
    return resize_rgba(comp, size_out)


# --------------------------------------------------------------------------
# 候选对比图
# --------------------------------------------------------------------------
def make_gallery(items: dict[str, dict]) -> None:
    """3 列缩略图墙：看构图与配色。"""
    cols, cell = 3, 356
    rows = (len(items) + cols - 1) // cols
    W = cols * cell + 40
    H = rows * (cell + 44) + 74
    img = Image.new("RGBA", (W, H), (236, 236, 232, 255))
    d = ImageDraw.Draw(img)
    f_t = load_font(24, bold=True)
    f_l = load_font(15)
    d.text((24, 22), "候选方案总览（1024 缩略）", font=f_t, fill=(32, 34, 40))
    for i, (name, cfg) in enumerate(items.items()):
        cx = 20 + (i % cols) * cell
        cy = 66 + (i // cols) * (cell + 44)
        thumb = render(cfg, cell - 36, background=cfg["background"])
        bgc = Image.new("RGBA", (cell - 36, cell - 36), cfg["background"] + (255,))
        paste_rgba(img, bgc, (cx, cy))
        paste_rgba(img, thumb, (cx, cy))
        d.text((cx, cy + cell - 30), name, font=f_l, fill=(64, 66, 74))
    save_png(img.convert("RGB"), CAND_DIR / "gallery-1024.png")


def make_48_sheet(items: dict[str, dict]) -> None:
    """2×2 单元：48px 实际尺寸（白底/黑底）+ 4× 最近邻放大。"""
    cols, cw, ch = 2, 540, 268
    rows = (len(items) + cols - 1) // cols
    W = cols * cw + 40
    H = rows * ch + 78
    img = Image.new("RGBA", (W, H), (236, 236, 232, 255))
    d = ImageDraw.Draw(img)
    f_t = load_font(23, bold=True)
    f_l = load_font(15)
    f_s = load_font(13)
    d.text((24, 22), "候选方案 48px 实际尺寸（白底/黑底）+ 4× 最近邻放大检查", font=f_t,
           fill=(32, 34, 40))
    for i, (name, cfg) in enumerate(items.items()):
        ox = 20 + (i % cols) * cw
        oy = 66 + (i // cols) * ch
        d.text((ox, oy), name, font=f_l, fill=(60, 62, 70))
        light = render(cfg, 48, background=cfg["background"], bg_radius=0.235)
        dark = render(cfg, 48, background=cfg["background"], bg_radius=0.235)
        # 白底单元
        wp = Image.new("RGBA", (48, 48), (255, 255, 255, 255))
        paste_rgba(img, wp, (ox, oy + 26))
        paste_rgba(img, light, (ox, oy + 26))
        # 黑底单元
        bp = Image.new("RGBA", (48, 48), (16, 17, 20, 255))
        paste_rgba(img, bp, (ox + 6 + 48, oy + 26))
        paste_rgba(img, dark, (ox + 6 + 48, oy + 26))
        d.text((ox, oy + 80), "48px 白底", font=f_s, fill=(110, 112, 120))
        d.text((ox + 54, oy + 80), "黑底", font=f_s, fill=(110, 112, 120))
        # 4× 放大（白底 / 黑底）
        for j, (bgc, panel_x) in enumerate((
            ((255, 255, 255), ox + 120),
            ((16, 17, 20), ox + 120 + 196),
        )):
            up = Image.new("RGBA", (192, 192), bgc + (255,))
            base = Image.new("RGBA", (192, 192), (0, 0, 0, 0))
            icon48 = render(cfg, 48, background=cfg["background"], bg_radius=0.235)
            base.alpha_composite(icon48.resize((192, 192), Image.NEAREST))
            up.alpha_composite(base)
            paste_rgba(img, up, (panel_x, oy + 24))
    save_png(img.convert("RGB"), CAND_DIR / "candidates-48px.png")


# --------------------------------------------------------------------------
# 预览图
# --------------------------------------------------------------------------
PREVIEW_BG = (235, 235, 231)
MIPMAPS = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}


def make_preview(icon1024: Image.Image, fg: Image.Image, bg: Image.Image,
                 mono: Image.Image) -> None:
    W, H = 1400, 1120
    img = Image.new("RGBA", (W, H), PREVIEW_BG + (255,))
    d = ImageDraw.Draw(img)

    f_title = load_font(34, bold=True)
    f_sub = load_font(18)
    f_panel = load_font(19, bold=True)
    f_cap = load_font(16)
    f_tiny = load_font(14)

    d.text((56, 42), "四象限清单 · 应用图标预览", font=f_title, fill=(30, 32, 38))
    d.text((56, 90), "Quadrant List · app icon preview · sRGB · 2×2 四象限 + Q1 高亮对勾",
           font=f_sub, fill=(108, 110, 120))

    # ---- 大图：1024 资产显示为 512 ----
    big = icon1024.resize((512, 512), Image.LANCZOS).convert("RGBA")
    paste_rgba(img, big, (56, 150))
    d.rounded_rectangle([56, 150, 56 + 512, 150 + 512], radius=40,
                        outline=(206, 205, 200, 255), width=1)
    d.text((56, 676), "icon-1024.png（1024×1024，此处按 50% 显示）", font=f_cap,
           fill=(96, 98, 108))

    # ---- 实际大小 48px 对照 ----
    real48 = render(FINAL, 48, background=WARM_WHITE, bg_radius=0.235)
    paste_rgba(img, real48, (56, 716))
    d.text((120, 720), "← 实际大小 48px（启动器图标常见尺寸）", font=f_cap,
           fill=(96, 98, 108))
    d.text((120, 744), "同一文件缩到 48px 仍能看出四象限 + 白色对勾", font=f_tiny,
           fill=(130, 132, 140))

    # ---- 色板 ----
    sw = 62
    for i, (col, nm, hx) in enumerate(zip(QUAD_COLORS, QUAD_NAMES, QUAD_HEX)):
        x = 56 + i * 132
        d.rounded_rectangle([x, 792, x + sw, 792 + sw], radius=16, fill=col + (255,))
        d.text((x, 862), hx, font=f_cap, fill=(60, 62, 70))
        d.text((x, 884), nm, font=f_tiny, fill=(120, 122, 130))
    d.text((56, 932), "图标底色 #F7F7F5（暖白）· 深色备选 #1C1D22 见 candidates/",
           font=f_tiny, fill=(120, 122, 130))
    d.text((56, 956), "旧版启动器图标：圆角 23.5% 的暖白方块 + 四象限块 + Q1 对勾",
           font=f_tiny, fill=(120, 122, 130))

    # ---- 右侧面板 ----
    px, pw = 640, 704

    def panel_header(text_, x0, y0, color=(40, 42, 50)):
        d.text((x0 + 28, y0 + 20), text_, font=f_panel, fill=color)

    mipmap_imgs = {s: render(FINAL, s, background=WARM_WHITE, bg_radius=0.235)
                   for s in MIPMAPS.values()}
    sizes = (48, 72, 96, 144, 192)

    # 面板 1：浅色底实际尺寸
    p1y = 150
    d.rounded_rectangle([px, p1y, px + pw, p1y + 300], radius=24, fill=(255, 255, 255, 255))
    panel_header("旧版方形图标 · 白底 · 实际像素尺寸（48 / 72 / 96 / 144 / 192）", px, p1y)
    d.text((px + 28, p1y + 52),
           "图标底色 #F7F7F5 与纯白只差约 3%，白底上圆角边界很淡（符合预期）",
           font=load_font(13), fill=(150, 152, 160))
    base = p1y + 262
    x = px + 28
    for s in sizes:
        paste_rgba(img, mipmap_imgs[s], (x, base - s))
        d.text((x, base + 8), f"{s}px", font=f_tiny, fill=(130, 132, 140))
        x += s + 14

    # 面板 2：黑底实际尺寸
    p2y = p1y + 332
    d.rounded_rectangle([px, p2y, px + pw, p2y + 300], radius=24, fill=(16, 17, 20, 255))
    panel_header("旧版方形图标 · 黑底 · 实际像素尺寸", px, p2y, color=(228, 229, 234))
    base = p2y + 262
    x = px + 28
    for s in sizes:
        paste_rgba(img, mipmap_imgs[s], (x, base - s))
        d.text((x, base + 8), f"{s}px", font=f_tiny, fill=(150, 152, 160))
        x += s + 14

    # 面板 3：自适应图标遮罩 + 单色
    p3y = p2y + 332
    d.rounded_rectangle([px, p3y, px + pw, p3y + 300], radius=24, fill=(255, 255, 255, 255))
    panel_header("Android 自适应图标（前景 + #F7F7F5 背景）· 遮罩演示", px, p3y)

    items = [
        ("圆形遮罩", masked_icon(fg, bg, 128, "circle")),
        ("圆角方形 · 22%", masked_icon(fg, bg, 128, "round", 0.22)),
        ("Squircle · 30%", masked_icon(fg, bg, 128, "round", 0.30)),
    ]
    tint = Image.new("RGBA", (432, 432), PRIMARY + (255,))
    mono_comp = Image.alpha_composite(tint, mono.convert("RGBA"))
    mono_round = Image.new("L", (432, 432), 0)
    ImageDraw.Draw(mono_round).rounded_rectangle([0, 0, 431, 431], radius=127, fill=255)
    mono_comp.putalpha(mono_round)
    items.append(("单色 / 主题图标（主题色 #3D5A80）", resize_rgba(mono_comp, 128)))

    x = px + 30
    for label, im in items:
        paste_rgba(img, im, (x, p3y + 66))
        d.text((x, p3y + 208), label, font=f_tiny, fill=(96, 98, 108))
        x += 160

    d.text((px + 30, p3y + 250),
           "前景内容外接框 ≈199px（安全区上限 285px）；四块外角距中心 ≈130px < 132px，圆遮罩不切角",
           font=f_tiny, fill=(150, 152, 160))

    save_png(img.convert("RGB"), OUT / "icon-preview.png")


# --------------------------------------------------------------------------
# 主流程
# --------------------------------------------------------------------------
def main() -> None:
    CAND_DIR.mkdir(parents=True, exist_ok=True)

    candidates = {
        "a-baseline-equal": design(check=False),
        "b-lift-check": design(q1_scale=1.10, q1_shift=0.012),
        "c-dark-equal-check": design(background=GRAPHITE),
        "d-equal-check": design(),  # 最终选型
        "e-muted-others": design(mute=0.10),
        "f-strong-lift-check": design(q1_scale=1.18, q1_shift=0.026),
        "g-wide-gap-check": design(gap=0.120),
    }
    for name, cfg in candidates.items():
        save_png(render(cfg, 1024, background=cfg["background"]).convert("RGB"),
                 CAND_DIR / f"candidate-{name}-1024.png")

    make_gallery(candidates)
    make_48_sheet(candidates)

    # ---------------- 最终交付 ----------------
    # 不透明资产统一输出 RGB（PNG，sRGB 语义），避免无意义的 alpha 通道
    icon1024 = render(FINAL, 1024, background=WARM_WHITE).convert("RGB")
    save_png(icon1024, OUT / "icon-1024.png")
    save_png(icon1024.resize((512, 512), Image.LANCZOS), OUT / "icon-512.png")

    # 自适应前景：透明，内容外接框 ≈ 204px（含抗锯齿羽边）≤ 285px 安全区上限
    fg = render(FINAL, 432, background=None, content=ADAPTIVE_CONTENT)
    save_png(fg, OUT / "adaptive-foreground-432.png")

    save_png(Image.new("RGB", (432, 432), WARM_WHITE), OUT / "adaptive-background-432.png")

    # 单色层：纯白图形 + 对勾挖空，供 Android 13 主题图标
    mono = render(FINAL, 432, background=None, content=ADAPTIVE_CONTENT,
                  color=WHITE, knockout_check=True)
    save_png(mono, OUT / "monochrome-432.png")

    # 旧版方形启动器图标：暖白圆角方块 + 透明外角
    for folder, s in MIPMAPS.items():
        (OUT / folder).mkdir(parents=True, exist_ok=True)
        save_png(render(FINAL, s, background=WARM_WHITE, bg_radius=0.235),
                 OUT / folder / "ic_launcher.png")

    make_preview(icon1024, fg, Image.open(OUT / "adaptive-background-432.png"),
                 mono)
    print("done ->", OUT)


if __name__ == "__main__":
    main()
