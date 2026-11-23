# 截图字体下载

截图脚本使用 **Noto Sans SC**（SIL Open Font License 1.1）渲染中文，字体文件体积较大，不提交到仓库。

在仓库根目录运行：

```powershell
pwsh -File tool/screenshots/fetch_fonts.ps1
```

或在 macOS / Linux：

```bash
bash tool/screenshots/fetch_fonts.sh
```

文件会下载到 `tool/screenshots/fonts/`（已被 `.gitignore` 忽略）：

```text
tool/screenshots/fonts/
├── NotoSansSC-Regular.otf
└── NotoSansSC-Bold.otf
```

字体来源：<https://github.com/notofonts/noto-cjk>（SIL Open Font License 1.1）。
