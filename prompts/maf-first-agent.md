# Scaffold — First MAF Agent

A minimal MAF agent registration that emits OTel spans on every run. Use this as the starting point for Stage 2.

---

## Project layout

```
YourAgentHost/
├── Program.cs
├── Agents/
│   ├── ResearcherAgent.cs
│   └── SynthesizerAgent.cs
├── Middleware/
│   └── TracingMiddleware.cs
├── appsettings.json
└── YourAgentHost.csproj
```

---

## `Program.cs`

```csharp
using Microsoft.AgentFramework;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

var builder = WebApplication.CreateBuilder(args);

// OTel
builder.Services.AddOpenTelemetry()
    .ConfigureResource(r => r.AddService("YourAgentHost"))
    .WithTracing(t => t
        .AddSource("Microsoft.AgentFramework.*")
        .AddAspNetCoreInstrumentation()
        .AddOtlpExporter(o => {
            o.Endpoint = new Uri(
                builder.Configuration["OTEL_EXPORTER_OTLP_ENDPOINT"]
                ?? "http://localhost:4317");
        }));

// Chat client (replace with your provider; OpenAI, Azure OpenAI, etc.)
builder.Services.AddSingleton<IChatClient>(sp =>
    new OpenAIChatClient(builder.Configuration["OPENAI_API_KEY"]!));

// Agents
builder.Services.AddSingleton<AIAgent>(sp => {
    var chatClient = sp.GetRequiredService<IChatClient>();
    return new ChatClientAgent(chatClient, options: new() {
        Name = "researcher",
        Instructions = "You research topics and produce concise summaries."
    }).WithMiddleware(new TracingMiddleware());
});

var app = builder.Build();

app.MapPost("/api/agent/test", async (
    AIAgent agent, AgentRequest request, CancellationToken ct) => {
    var result = await agent.RunAsync(request.Query, ct);
    return Results.Ok(new { result.Output });
});

app.Run();

public record AgentRequest(string Query);
```

---

## `Middleware/TracingMiddleware.cs`

```csharp
using System.Diagnostics;
using Microsoft.AgentFramework;

public class TracingMiddleware : IAgentMiddleware
{
    private static readonly ActivitySource _source = new("Microsoft.AgentFramework.Custom");

    public async Task<AgentResult> InvokeAsync(
        AgentContext ctx,
        AgentDelegate next,
        CancellationToken ct)
    {
        using var activity = _source.StartActivity(
            $"agent.{ctx.Agent.Name}.run",
            ActivityKind.Internal);

        activity?.SetTag("gen_ai.agent.name", ctx.Agent.Name);
        activity?.SetTag("gen_ai.system", "openai");

        try
        {
            var result = await next(ctx, ct);
            activity?.SetStatus(ActivityStatusCode.Ok);
            return result;
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            throw;
        }
    }
}
```

---

## Smoke test

After running the host:

```powershell
$response = Invoke-RestMethod http://localhost:5000/api/agent/test -Method POST `
    -ContentType "application/json" -Body '{"query":"summarize the OpenTelemetry GenAI semantic conventions"}'

# Open Jaeger UI: http://localhost:16686
# Search service: YourAgentHost
# You should see at least one trace with:
#   - root span: POST /api/agent/test
#   - child span: agent.researcher.run (with gen_ai.agent.name=researcher)
#   - grandchild span: chat.client.request (auto-instrumented by MAF)
```

---

## Adding A2A

Once one agent works, add a second:

```csharp
builder.Services.AddKeyedSingleton<AIAgent>("synthesizer", (sp, _) => {
    var chatClient = sp.GetRequiredService<IChatClient>();
    return new ChatClientAgent(chatClient, options: new() {
        Name = "synthesizer",
        Instructions = "You synthesize research into a final answer."
    }).WithMiddleware(new TracingMiddleware());
});

// In your endpoint:
var researcher = sp.GetRequiredKeyedService<AIAgent>("researcher");
var synthesizer = sp.GetRequiredKeyedService<AIAgent>("synthesizer");

var research = await researcher.RunAsync(query, ct);
var summary = await synthesizer.RunAsync(research.Output, ct);
```

The Jaeger waterfall will show two child spans under one parent — your first A2A handoff.

---

## Variants

- For Azure OpenAI, swap `OpenAIChatClient` for `AzureOpenAIChatClient` and provide endpoint+key.
- For tools (function calling), register tools on the agent and add the Function Calling middleware tier alongside the Agent Run tier.
- For workflows (sequential, parallel, conditional), see MAF's `Workflow` constructs; instrumentation flows automatically.
