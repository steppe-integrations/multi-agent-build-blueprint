# Download the latest Jaeger v2 binary for Windows.
#
# Pulls from github.com/jaegertracing/jaeger/releases. Pinned to v2.x; if you
# want a specific version, edit $version below.

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$toolsDir = Join-Path $repoRoot 'tools'
if (-not (Test-Path $toolsDir)) { New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null }

$version = '2.17.0'  # update as new releases come out
$tarName = "jaeger-$version-windows-amd64.tar.gz"
$url = "https://github.com/jaegertracing/jaeger/releases/download/v$version/$tarName"
$tarPath = Join-Path $toolsDir $tarName
$exePath = Join-Path $toolsDir 'jaeger.exe'

if (Test-Path $exePath) {
    Write-Host "jaeger.exe already present at $exePath" -ForegroundColor Yellow
    exit 0
}

Write-Host "Downloading Jaeger v$version ..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $url -OutFile $tarPath

Write-Host "Extracting ..." -ForegroundColor Cyan
tar -xzf $tarPath -C $toolsDir

# The tarball extracts to jaeger-$version-windows-amd64/jaeger.exe
$extractDir = Join-Path $toolsDir "jaeger-$version-windows-amd64"
$srcExe = Join-Path $extractDir 'jaeger.exe'
Copy-Item $srcExe $exePath -Force

Remove-Item $tarPath -Force
Remove-Item $extractDir -Recurse -Force

Write-Host "Installed jaeger.exe at $exePath" -ForegroundColor Green
