# Start Jaeger v2 collector locally (single-PC dev).
#
# Idempotent: if 4317 is already bound, no-op. Otherwise downloads (if needed),
# starts the binary in the background, waits for the port to come up, and
# prints the local UI URL.
#
# For the cross-PC noisy variant (prints reachable IPs, env vars, firewall
# command), use start-shared-otel.ps1 instead.

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$exe = Join-Path $repoRoot 'tools\jaeger.exe'
$cfg = Join-Path $repoRoot 'infra\jaeger.yaml'

$logDir = Join-Path $env:LOCALAPPDATA 'multi-agent-build-blueprint\logs'
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$log = Join-Path $logDir 'jaeger.log'

if (Get-NetTCPConnection -LocalPort 4317 -State Listen -ErrorAction SilentlyContinue) {
    Write-Host 'Jaeger already listening on :4317' -ForegroundColor Yellow
    Write-Host '  To stop: Get-Process -Name jaeger | Stop-Process -Force'
    exit 0
}

if (-not (Test-Path $exe)) {
    Write-Host 'jaeger.exe not present; running tools\download-jaeger.ps1 ...' -ForegroundColor Yellow
    $downloadScript = Join-Path $repoRoot 'tools\download-jaeger.ps1'
    & "$downloadScript"
}
if (-not (Test-Path $cfg)) {
    Write-Host ('Config not found: {0}' -f $cfg) -ForegroundColor Red
    exit 1
}

# PowerShell 5.1: -ArgumentList as string array doesn't auto-quote spaces.
# Pass a single pre-quoted string so CommandLineToArgvW sees one argument.
$argsLine = '--config "file:{0}"' -f $cfg

$proc = Start-Process -FilePath $exe -ArgumentList $argsLine `
    -RedirectStandardOutput $log -RedirectStandardError "$log.err" `
    -WindowStyle Hidden -PassThru

Start-Sleep -Seconds 3

if (-not (Get-NetTCPConnection -LocalPort 4317 -State Listen -ErrorAction SilentlyContinue)) {
    Write-Host ('Jaeger did not come up. Last lines of {0}:' -f "$log.err") -ForegroundColor Red
    if (Test-Path "$log.err") {
        Get-Content "$log.err" -Tail 15 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkRed }
    }
    exit 1
}

Write-Host ('Started. PID {0}. Logs at {1}' -f $proc.Id, $log) -ForegroundColor Green
Write-Host ''
Write-Host 'Local UI: http://localhost:16686' -ForegroundColor Cyan
Write-Host 'OTLP gRPC: http://localhost:4317'
Write-Host 'OTLP HTTP: http://localhost:4318'
Write-Host ''
Write-Host 'To stop: Get-Process -Name jaeger | Stop-Process -Force' -ForegroundColor DarkGray
