# Stage 4 — 3-PC Topology

**Goal:** scale to three machines: orchestrator (PC 1), overflow (PC 2), persistent + shared OTel collector + Routines runner (PC 3).

**Time:** ~1 hour for first-time setup, including firewall and network verification.

**Depends on:** Stage 1 (collector running locally) + Stage 3 (parallel sessions in use).

---

## Why three PCs

One PC is fine until parallel-session count exceeds 4–5 *and* heavy-compute sessions start blocking the orchestrator. Two PCs (orchestrator + overflow) handles most teams. PC 3 emerges when you need:

- **Always-on observability.** Traces survive your laptop sleeping.
- **Scheduled Routines.** Cloud-style polling jobs that need a stable home.
- **Phone-pair stability.** Your phone has *one* always-reachable target.

You don't need all three from day one. Adopt incrementally.

---

## Roles

### PC 1 — Orchestrator

Where you actually drive the build. Runs lightweight, fast-feedback sessions:
- UI scaffolds
- Small refactors
- Doc generation
- Plan reviews and design-acks

This is where you spend most of your active time.

### PC 2 — Overflow

Heavy-compute streams that would otherwise block PC 1:
- Data generation
- Model fine-tuning
- Large refactors with extensive verify-loops
- Long-running test suites

Same Cowork client, same git remote, different worktrees.

### PC 3 — Persistent

Always on. Hosts:
- **Shared OTel collector** (Jaeger v2). Both PC 1 and PC 2 export here.
- **Routines runner.** Scheduled tasks that need a stable home.
- **Optional: the Dispatch pair-target.** Phone pairs into PC 3 to read state without waking PC 1 or 2.

PC 3 doesn't need to be powerful. A small NUC or repurposed laptop works.

---

## Steps

### 1. Pick your PC 3

Anything with stable network, ≥8 GB RAM, and reasonable uptime. Doesn't need to be fast; it's mostly idle.

### 2. Install Jaeger v2 on PC 3

Same as Stage 1, but on PC 3. Use [`infra/start-shared-otel.ps1`](../infra/start-shared-otel.ps1), which is the noisy variant of `start-jaeger.ps1` — it prints reachable IPs, paste-ready env vars, and the firewall command.

### 3. Open firewall on PC 3

Admin PowerShell on PC 3:

```powershell
New-NetFirewallRule -DisplayName "Tempo shared OTel" `
    -Direction Inbound -Protocol TCP -LocalPort 4317,4318,16686 -Action Allow
```

### 4. Configure PC 1 and PC 2 to export to PC 3

On each, set:

```powershell
# Current shell only:
$env:OTEL_EXPORTER_OTLP_ENDPOINT = "http://<pc3-host>:4317"
$env:OTEL_EXPORTER_OTLP_PROTOCOL = "grpc"

# Persistent (restart shell after):
setx OTEL_EXPORTER_OTLP_ENDPOINT "http://<pc3-host>:4317"
setx OTEL_EXPORTER_OTLP_PROTOCOL "grpc"
```

Replace `<pc3-host>` with PC 3's IP or hostname (the start-shared-otel script prints the IPs for you).

### 5. Smoke-test cross-PC

From PC 1:

```powershell
.\infra\smoke-otel.ps1 -Endpoint http://<pc3-host>:4318
```

Then open `http://<pc3-host>:16686` and verify the synthetic span appears.

### 6. (Optional) Set up Routines runner

See **[`docs/06-routines.md`](06-routines.md)**. Routines run in the cloud, not on PC 3 directly, but they query PC 3's Jaeger API. PC 3 needs to be reachable from Anthropic's runners (Tailscale or static address).

---

## Topology diagram

```
              GitHub (shared remote)
                /     |     \
               /      |      \
              v       v       v
            ┌────┐  ┌────┐  ┌─────────────┐
            │PC 1│  │PC 2│  │PC 3         │
            │Orch│  │Over│  │Persistent + │
            │    │  │flow│  │OTel +       │
            │    │  │    │  │Routines     │
            └─┬──┘  └─┬──┘  └──┬───────┬──┘
              │       │        ^       │
              │ OTLP  │ OTLP   │       │
              └───────┴────────┘       │
                                       │
                                    Phone
                                  (Dispatch)
```

---

## Verification command

From PC 1, with PC 3's hostname as `$pc3`:

```powershell
$resp = Invoke-WebRequest -Uri "http://${pc3}:4318/v1/traces" -Method POST `
    -ContentType "application/json" -Body (Get-Content -Raw infra\smoke-trace.json)
if ($resp.StatusCode -eq 200) { "3PC-TOPOLOGY-OK" } else { exit 1 }
```

---

## Common pitfalls

- **Connection refused from PC 1.** Firewall on PC 3 didn't open the ports. See step 3.
- **Connection works but UI shows no traces.** Endpoint config is wrong (HTTP vs gRPC, port mismatch). gRPC = 4317, HTTP = 4318.
- **Traces appear sometimes but not always.** PC 3 is sleeping. Disable sleep on PC 3 or use a wake-on-LAN trigger.
- **PC 3 unreachable from cloud Routines.** Set up Tailscale on PC 3 or expose a static reverse proxy. Routines need network access to query Jaeger.

---

## What you have now

Three PCs working together: PC 1 drives parallel sessions, PC 2 absorbs heavy-compute, PC 3 keeps observability persistent and runs Routines. Scaled architecture, ready to grow further.

Next: **[`docs/06-routines.md`](06-routines.md)** to add ambient awareness via scheduled tasks.
