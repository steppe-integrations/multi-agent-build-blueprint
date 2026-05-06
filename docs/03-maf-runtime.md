# Stage 2 — MAF Runtime

**Goal:** stand up a Microsoft Agent Framework host that emits GenAI semantic-convention spans automatically.

**Time:** ~2 hours the first time, faster after.

**Depends on:** Stage 1 (OTel collector running).

---

## Why MAF

Three properties make MAF the right runtime substrate:

1. **Three-layer middleware.** Inject instrumentation, retry, redaction, cost capture without forking agent code.
2. **`AIAgent.RunAsync` as A2A primitive.** Agent-to-agent invocation = same shape as tool invocation.
3. **First-class workflows.** Sequential, parallel, conditional flow constructs are framework-native.

If you're choosing between LangChain, Semantic Kernel, and MAF: MAF's middleware tiering and A2A primitive are first-class in a way the alternatives are not.

---

## Steps

### 1. Bootstrap a .NET 9 host project

```powershell
dotnet new webapi -n YourAgentHost -f net9.0
cd YourAgentHost
```

### 2. Add MAF packages

```powershell
dotnet add package Microsoft.AgentFramework
dotnet add package Microsoft.AgentFramework.OpenAI    # or AzureOpenAI, etc.
dotnet add package OpenTelemetry.Extensions.Hosting
dotnet add package OpenTelemetry.Exporter.OpenTelemetryProtocol
dotnet add package OpenTelemetry.Instrumentation.AspNetCore
```

### 3. Wire up OTel exporter

In `Program.cs`:

```csharp
builder.Services.AddOpenTelemetry()
    .WithTracing(t => t
        .AddSource("Microsoft.AgentFramework.*")
        .AddAspNetCoreInstrumentation()
        .AddOtlpExporter(o => {
            o.Endpoint = new Uri(builder.Configuration["OTEL_EXPORTER_OTLP_ENDPOINT"]
                                ?? "http://localhost:4317");
            o.Protocol = OpenTelemetry.Exporter.OtlpExportProtocol.Grpc;
        }));
```

### 4. Register at least one agent

See [`prompts/maf-first-agent.md`](../prompts/maf-first-agent.md) for a paste-ready scaffold. Minimal version:

```csharp
var agent = new ChatClientAgent(chatClient, options: new() {
    Name = "researcher",
    Instructions = "You research topics and produce concise summaries."
});

builder.Services.AddSingleton<AIAgent>(agent);
```

### 5. Configure middleware

Add at least the **Agent Run** tier — top-level instrumentation. The other two (Function Calling, Chat Client) get added as you grow:

```csharp
agent = agent.WithMiddleware(new TracingMiddleware());
```

A skeleton `TracingMiddleware` is in [`prompts/maf-tracing-middleware.md`](../prompts/maf-tracing-middleware.md). It wraps each `RunAsync` in a span with `gen_ai.agent.name` set automatically.

### 6. Smoke-test

Run the host. Send a request that invokes the agent. Open Jaeger UI. Search for `gen_ai.agent.name = researcher`. You should see at least one span per request, with a parent span representing the workflow.

---

## A2A handoff pattern

Once you have one agent working, add a second one and have the first invoke it:

```csharp
var researcher = serviceProvider.GetRequiredService<AIAgent>("researcher");
var synthesizer = serviceProvider.GetRequiredService<AIAgent>("synthesizer");

var research = await researcher.RunAsync(userQuery, ct);
var summary = await synthesizer.RunAsync(research.Output, ct);
```

In Jaeger, you'll now see a parent span for the workflow with two child spans (one per agent). The `synthesizer` span is logically an A2A handoff, but mechanically it's just another `RunAsync`.

---

## Verification command

```powershell
# After your host is running:
$response = Invoke-RestMethod http://localhost:5000/api/agent/test -Method POST `
  -ContentType "application/json" -Body '{"query":"hello"}'

# Check Jaeger for the trace
$traces = Invoke-RestMethod "http://localhost:16686/api/traces?service=YourAgentHost&limit=1"
if ($traces.data.Count -gt 0 -and
    $traces.data[0].spans | Where-Object { $_.tags.key -contains "gen_ai.agent.name" }) {
    "MAF-RUNTIME-OK"
} else { exit 1 }
```

---

## Common pitfalls

- **Spans don't appear.** Check `OTEL_EXPORTER_OTLP_ENDPOINT` is set and reachable. Default is `http://localhost:4317` (gRPC).
- **`gen_ai.*` attributes missing.** Ensure your MAF version is recent enough; the GenAI conventions stabilized late 2025. Older versions used custom attribute names.
- **Service name shows as `unknown_service`.** Set `OTEL_SERVICE_NAME` env var or `OpenTelemetryBuilder.ConfigureResource(r => r.AddService("YourAgentHost"))`.
- **Agent runs but no spans.** Make sure you actually called `.WithMiddleware(new TracingMiddleware())` — the registration alone doesn't auto-instrument.

---

## What you have now

An MAF host that emits GenAI spans for every agent run, every tool call, and every model request. All visible as a single trace tree in Jaeger. Cost, model, finish reason, token counts — all captured.

Next: **[`docs/04-cowork-desktop.md`](04-cowork-desktop.md)** for parallel build sessions.
