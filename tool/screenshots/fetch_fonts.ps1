# 下载截图用中文字体 Noto Sans SC（OFL 1.1），文件不入库。
$ErrorActionPreference = 'Stop'
$dir = Join-Path $PSScriptRoot 'fonts'
New-Item -ItemType Directory -Force -Path $dir | Out-Null

$base = 'https://cdn.jsdelivr.net/gh/notofonts/noto-cjk@main/Sans/SubsetOTF/SC/'
$files = @('NotoSansSC-Regular.otf', 'NotoSansSC-Bold.otf')

foreach ($name in $files) {
    $dest = Join-Path $dir $name
    if (Test-Path $dest) {
        Write-Host "已存在，跳过：$name"
        continue
    }
    Write-Host "下载 $name ..."
    Invoke-WebRequest -Uri ($base + $name) -OutFile $dest -UseBasicParsing
    Write-Host "完成：$dest"
}

Write-Host '字体已就绪，现在可以运行：'
Write-Host 'flutter test test/screenshots/render_screenshots.dart --update-goldens'
