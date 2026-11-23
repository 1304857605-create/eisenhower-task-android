#!/usr/bin/env bash
# 下载截图用中文字体 Noto Sans SC（OFL 1.1），文件不入库。
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p fonts
base="https://cdn.jsdelivr.net/gh/notofonts/noto-cjk@main/Sans/SubsetOTF/SC"
for name in NotoSansSC-Regular.otf NotoSansSC-Bold.otf; do
  if [ -f "fonts/$name" ]; then
    echo "已存在，跳过：$name"
  else
    echo "下载 $name ..."
    curl -fL "$base/$name" -o "fonts/$name"
  fi
done
echo "字体已就绪，现在可以运行："
echo "flutter test test/screenshots/render_screenshots.dart --update-goldens"
