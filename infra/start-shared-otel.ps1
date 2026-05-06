# Start Jaeger v2 as a shared OTel collector for multi-PC topology.
#
# Same binary, same config as start-jaeger.ps1, but prints connection guidance
# other PCs need: reachable IPs, paste-ready env vars, firewall command.
# Run on PC 3 in the 3-PC pattern.

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$exe = Join-Path $repoRoot 'tools\jaeger.exe'
$cfg = Join-Path $repoRoot 'infra\jaeger.yaml'

$logDir = Join-Path $env:LOCALAPPDATA 'multi-agent-build-blueprint\logs'
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$log = Join-Path $logDir 'shared-otel.log'

Write-Host '=== Shared OTel collector (Jaeger v2) ===' -ForegroundColor Cyan
Write-Host ''

if (Get-NetTCPConnection -LocalPort 4317 -State Listen -ErrorAction SilentlyContinue) {
    Write-Host 'Jaeger already listening on :4317' -ForegroundColor Yellow
    Write-Host '  (started by start-jaeger.ps1 or a previous run of this script)'
    Write-Host '  To stop: Get-Process -Name jaeger | Stop-Process -Force'
    Write-Host ''
} else {
    if (-not (Test-Path $exe)) {
        Write-Host 'jaeger.exe not present; running tools\download-jaeger.ps1 ...' -ForegroundColor Yellow
        $downloadScript = Join-Path $repoRoot 'tools\download-jaeger.ps1'
        & "$downloadScript"
    }
    if (-not (Test-Path $cfg)) {
        Write-Host ('Config not found: {0}' -f $cfg) -ForegroundColor Red
        exit 1
    }

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
    Write-Host ('Started. PID {0}. Logs at {1}' -f $proc.Id, $log)
    Write-Host ''
}

# Machine identity + connection guidance
$ipv4s = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object {
        $_.InterfaceAlias -notmatch '(Loopback|vEthernet|WSL|Pseudo|Tunnel)' -and
        $_.IPAddress -notmatch '^169\.254' -and
        $_.IPAddress -ne '127.0.0.1'
    } |
    Select-Object -ExpandProperty IPAddress

Write-Host ('Machine: {0}' -f $env:COMPUTERNAME)
if ($ipv4s) {
    Write-Host  'Reachable IPv4 addresses (binds 0.0.0.0 per infra/jaeger.yaml):'
    foreach ($ip in $ipv4s) { Write-Host ('  - {0}' -f $ip) }
} else {
    Write-Host 'No external IPv4 NICs found (loopback only).'
}
Write-Host ''

Write-Host '--- Local UI ---' -ForegroundColor Cyan
Write-Host  '  http://localhost:16686'
Write-Host ''

if ($ipv4s) {
    Write-Host '--- Reachable from other PCs (after firewall opened) ---' -ForegroundColor Cyan
    foreach ($ip in $ipv4s) {
        Write-Host ('  http://{0}:16686' -f $ip)
    }
    Write-Host ''
    $primary = $ipv4s[0]
    Write-Host '--- Paste on PC 1 / PC 2 (per Cowork session) ---' -ForegroundColor Cyan
    Write-Host '  Current shell only:'
    Write-Host ('    $env:OTEL_EXPORTER_OTLP_ENDPOINT = "http://{0}:4317"' -f $primary) -ForegroundColor White
    Write-Host  '    $env:OTEL_EXPORTER_OTLP_PROTOCOL = "grpc"' -ForegroundColor White
    Write-Host ''
    Write-Host '  Persistent (restart shell after):'
    Write-Host ('    setx OTEL_EXPORTER_OTLP_ENDPOINT "http://{0}:4317"' -f $primary) -ForegroundColor White
    Write-Host  '    setx OTEL_EXPORTER_OTLP_PROTOCOL "grpc"' -ForegroundColor White
    Write-Host ''
}

Write-Host '--- Firewall (admin shell, one-time) ---' -ForegroundColor Cyan
Write-Host '  New-NetFirewallRule -DisplayName "Multi-Agent OTel" `' -ForegroundColor White
Write-Host '    -Direction Inbound -Protocol TCP -LocalPort 4317,4318,16686 -Action Allow' -ForegroundColor White
Write-Host ''

Write-Host 'To stop: Get-Process -Name jaeger | Stop-Process -Force' -ForegroundColor DarkGray
