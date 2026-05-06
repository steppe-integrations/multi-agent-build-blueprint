# Stage 1 — OTel Foundation (Jaeger v2)

**Goal:** stand up a single Jaeger v2 collector. Bind ports, smoke-test, point one client at it.

**Time:** ~30 minutes the first time, ~5 minutes when you've done it before.

**Depends on:** nothing.

---

## Why Jaeger v2 specifically

- **Single binary**, single YAML config. No services-to-coordinate.
- **OTLP-native.** Not a Jaeger-specific protocol; speaks OpenTelemetry directly.
- **Permissive license**, free, no SaaS lock-in.
- **GenAI-aware.** Renders `gen_ai.*` semantic-convention attributes natively.

Alternatives that are also fine: Grafana Tempo, Honeycomb, vendor APMs that accept OTLP. Pick Jaeger if you want zero-cost zero-friction.

> **Important:** Jaeger v2 is not a flag-compatible upgrade from v1. The v1 `--collector.otlp.grpc.host-port` flags will fail. Use `--config "file:..."` exclusively.

---

## Steps

### 1. Download Jaeger v2

Get the latest binary from [github.com/jaegertracing/jaeger/releases](https://github.com/jaegertracing/jaeger/releases). Pick `jaeger-2.x.x-windows-amd64.tar.gz` (or your platform's equivalent). Extract.

A helper script is in [`infra/download-jaeger.ps1`](../infra/download-jaeger.ps1).

### 2. Drop in `jaeger.yaml`

Use [`infra/jaeger.yaml`](../infra/jaeger.yaml) verbatim. The config:

- Binds OTLP gRPC on `0.0.0.0:4317`.
- Binds OTLP HTTP on `0.0.0.0:4318`.
- Binds the UI on `0.0.0.0:16686`.
- Stores traces in memory by default (good for dev; configure persistent storage later).

### 3. Start it

```powershell
.\infra\start-jaeger.ps1
```

This script:
- Verifies the binary exists (downloads if missing).
- Verifies port 4317 isn't already bound (idempotent).
- Starts Jaeger with `--config "file:infra/jaeger.yaml"`.
- Tails the log and exits when 4317 is listening.

### 4. Smoke-test

```powershell
.\infra\smoke-otel.ps1
```

This:
- POSTs a synthetic OTLP HTTP trace to `http://localhost:4318/v1/traces`.
- Expects a 200 response.
- Queries `http://localhost:16686/api/services` and verifies the synthetic service appears.

### 5. Open the UI

[http://localhost:16686](http://localhost:16686). You should see your synthetic service listed.

---

## Configuration knobs you'll touch later

- **Persistent storage.** Replace memory storage with Cassandra, Elasticsearch, or Badger. See [`infra/jaeger-persistent.yaml`](../infra/jaeger-persistent.yaml) for an example with Badger (simplest local option).
- **Sampling.** By default Jaeger captures everything. For production, configure tail-based sampling at the collector level.
- **Multi-tenant.** Single-tenant for dev; if you need multi-tenant, look at OpenTelemetry Collector with tenant routing instead.

---

## Verification command

```powershell
$resp = Invoke-WebRequest -Uri http://localhost:4318/v1/traces -Method POST `
  -ContentType "application/json" `
  -Body (Get-Content -Raw infra\smoke-trace.json)
if ($resp.StatusCode -eq 200) { "OTEL-FOUNDATION-OK" } else { exit 1 }
```

---

## Common pitfalls

- **Port 4317 already in use.** Another collector running. Kill it or pick different ports (and update everything downstream).
- **Firewall blocks UI.** Test from `localhost` first. For network-reachable, see Stage 4.
- **YAML indentation errors.** Jaeger's YAML parser is strict. Use the provided `jaeger.yaml` verbatim before editing.
- **Tried to use v1 flags.** `--collector.otlp.grpc.host-port` is not a v2 flag. Use `--config "file:..."`.

---

## What you have now

A local Jaeger v2 collector listening on three ports. Anything that emits OTLP traces — including MAF agents, custom services, manual smoke tests — can point at this and be observable.

Next: **[`docs/03-maf-runtime.md`](03-maf-runtime.md)** to add MAF agents that auto-emit GenAI spans. Or skip ahead to **[`docs/04-cowork-desktop.md`](04-cowork-desktop.md)** if you're not running agents yet.
