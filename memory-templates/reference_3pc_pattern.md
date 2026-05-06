# 3-PC topology — pointer

The 3-PC scaling pattern (orchestrator / overflow / persistent + OTel + Routines) is documented in detail at:

- **Repo:** [multi-agent-build-blueprint/docs/05-3pc-topology.md](https://github.com/steppe-integrations/multi-agent-build-blueprint/blob/main/docs/05-3pc-topology.md)
- **Article:** [steppeintegrations.com/articles/dispatch-maf-otel-stack/](https://steppeintegrations.com/articles/dispatch-maf-otel-stack/)

## TL;DR for sessions

If the project is using 3 PCs:

- **PC 1** = orchestrator. Lightweight sessions. Status-file reads. Merges.
- **PC 2** = overflow. Heavy-compute sessions. Same git remote.
- **PC 3** = persistent. Always on. Hosts shared OTel collector. Runs Routines. Phone-pair target.

Both PC 1 and PC 2 export OTLP traces to PC 3 via:
```
OTEL_EXPORTER_OTLP_ENDPOINT=http://<pc3-host>:4317
OTEL_EXPORTER_OTLP_PROTOCOL=grpc
```

## When to invoke this pattern

- Parallel-session count regularly exceeds 4–5.
- Heavy-compute sessions block orchestrator responsiveness.
- Telemetry needs to survive laptop sleep.
- Phone wants one always-reachable target via Dispatch.

## When NOT to invoke

- Solo project, one or two streams: stay on one PC.
- Two streams, both lightweight: two PCs is fine; PC 3 is overkill.
