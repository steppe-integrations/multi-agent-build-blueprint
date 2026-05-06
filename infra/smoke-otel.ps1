# Smoke-test the OTel collector by POSTing a synthetic OTLP HTTP trace and
# verifying it appears in Jaeger's services list.

param(
    [string]$Endpoint = 'http://localhost:4318'
)

$ErrorActionPreference = 'Stop'
$queryEndpoint = $Endpoint -replace ':4318$', ':16686' -replace 'http://([^/]+):4318.*', 'http://$1:16686'

$traceId = ([guid]::NewGuid().ToString('N')).PadRight(32, '0').Substring(0, 32)
$spanId = ([guid]::NewGuid().ToString('N')).Substring(0, 16)
$nowNs = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() * 1000000

$body = @{
    resourceSpans = @(
        @{
            resource = @{
                attributes = @(
                    @{ key = 'service.name'; value = @{ stringValue = 'mab-smoke' } }
                )
            }
            scopeSpans = @(
                @{
                    scope = @{ name = 'mab.smoke' }
                    spans = @(
                        @{
                            traceId = $traceId
                            spanId = $spanId
                            name = 'mab.smoke.test'
                            kind = 1
                            startTimeUnixNano = "$nowNs"
                            endTimeUnixNano = "$($nowNs + 1000000)"
                            attributes = @(
                                @{ key = 'gen_ai.agent.name'; value = @{ stringValue = 'smoke-test' } }
                            )
                        }
                    )
                }
            )
        }
    )
} | ConvertTo-Json -Depth 10

Write-Host "POSTing synthetic trace to $Endpoint/v1/traces ..." -ForegroundColor Cyan
$resp = Invoke-WebRequest -Uri "$Endpoint/v1/traces" -Method POST `
    -ContentType 'application/json' -Body $body

if ($resp.StatusCode -ne 200) {
    Write-Host ('Bad status: {0}' -f $resp.StatusCode) -ForegroundColor Red
    exit 1
}
Write-Host 'OTLP HTTP returned 200.' -ForegroundColor Green

Start-Sleep -Seconds 2

Write-Host "Querying Jaeger services at $queryEndpoint/api/services ..." -ForegroundColor Cyan
$svcs = Invoke-RestMethod "$queryEndpoint/api/services"
if ($svcs.data -contains 'mab-smoke') {
    Write-Host 'OTEL-FOUNDATION-OK' -ForegroundColor Green
    exit 0
} else {
    Write-Host 'mab-smoke service did not appear. Available services:' -ForegroundColor Red
    $svcs.data | ForEach-Object { Write-Host "  $_" }
    exit 1
}
