# Multi-Agent Build Blueprint

A complete, paste-ready guide to standing up the **Dispatch + MAF + OTel** stack — the build-and-run substrate behind durable AI-assisted engineering at Steppe Integrations.

This repo is the canonical companion to:

- **Article:** [Dispatch + MAF + OTel: A Complete Multi-Agent Stack](https://steppeintegrations.com/articles/dispatch-maf-otel-stack/)
- **Methodology piece:** [Five Layers for a Replicable AI-Assisted Build Session](https://steppeintegrations.com/articles/five-layer-build-blueprint/)

If you're reading the article and thinking *"how do I actually stand this up?"* — you're in the right place.

---

## What you get from following this guide

After working through the stages in [`docs/`](docs/), you will have:

- A **shared OTel collector** (Jaeger v2) reachable from any machine on your local network.
- An **MAF runtime host** that emits GenAI semantic-convention spans automatically.
- A **Cowork desktop workflow** for parallel build sessions, with Dispatch phone-pairing.
- A **3-PC scaling pattern** ready to grow into when you outgrow one machine.
- A **scheduled Routine** that posts a phone-friendly state digest to a pinned GitHub issue.
- **Status-file gate signals** that let parallel build sessions coordinate without a human in the loop.

---

## Why this stack

Three independent product surfaces that compose into something larger than the sum of their parts:

| Pillar | Layer | Why it's here |
|---|---|---|
| **Cowork (with Dispatch)** | Build time | Parallelizes AI-assisted engineering. Auto-worktree per session. Phone-pair via QR. |
| **Microsoft Agent Framework (MAF)** | Runtime | Three-tier middleware (Agent Run / Function Calling / Chat Client). `AIAgent.RunAsync` as A2A primitive. First-class workflows. |
| **OpenTelemetry** | Cross-cutting | GenAI semantic conventions (stabilized late 2025). One trace ID across build session → agent run → A2A handoff → downstream service. |

The composition is the product. None of the three replaces the others.

---

## Why **not** to use it

Be honest about your situation. Skip this stack if:

- You're building a one-off internal tool with no users → OTel is overkill.
- You're at the POC stage where the agent design is still in flux → MAF is overkill until shape stabilizes.
- You're a solo developer on a single greenfield stream → Cowork desktop is overkill; CLI Claude Code is fine.

The stack pays off when you're past POC, shipping AI features into production, and running ≥2 parallel build streams.

---

## How to use this repo

Read in this order:

1. **[`docs/01-stage-overview.md`](docs/01-stage-overview.md)** — the staged adoption order and what each stage gives you.
2. **[`docs/02-otel-foundation.md`](docs/02-otel-foundation.md)** — Stage 1: stand up Jaeger v2.
3. **[`docs/03-maf-runtime.md`](docs/03-maf-runtime.md)** — Stage 2: instrument MAF agents.
4. **[`docs/04-cowork-desktop.md`](docs/04-cowork-desktop.md)** — Stage 3: parallel build sessions.
5. **[`docs/05-3pc-topology.md`](docs/05-3pc-topology.md)** — Stage 4: scale to 3 PCs.
6. **[`docs/06-routines.md`](docs/06-routines.md)** — Stage 5: ambient awareness via scheduled tasks.
7. **[`docs/07-dispatch-phone.md`](docs/07-dispatch-phone.md)** — Stage 6: phone-pair via QR.

Then dip into:

- **[`prompts/`](prompts/)** — paste-ready kickoff prompts, design-review prompts, hotfix prompts, all parameterized.
- **[`infra/`](infra/)** — copy-paste PowerShell scripts to start collectors, smoke-test, etc.
- **[`memory-templates/`](memory-templates/)** — starter `feedback_*.md` and `reference_*.md` files for your project's memory directory.
- **[`adr-templates/`](adr-templates/)** — Architecture Decision Record templates for the load-bearing choices in this stack.

---

## When to build all vs. some

**Build all six stages** when you're running production agents *and* shipping engineering work in parallel streams. The compounding value of cross-tier traceability + ambient awareness justifies the setup cost.

**Build stages 1–3 only** when you're a small team or solo, working on a single project with one or two streams. You get unified observability and parallel build velocity without the operational burden of a third PC.

**Build stage 1 only** when you're brand new to OTel. Single-machine Jaeger gives you immediate observability ROI and lays the substrate for everything else.

See [`docs/01-stage-overview.md`](docs/01-stage-overview.md) for the full decision tree.

---

## License

MIT. Use it, fork it, ship variants. If you build something interesting, file an issue or PR.

---

## Maintainer

Derek Ciula — Steppe Integrations.
- Articles: [steppeintegrations.com/articles/](https://steppeintegrations.com/articles/)
- Org: [github.com/steppe-integrations](https://github.com/steppe-integrations)
