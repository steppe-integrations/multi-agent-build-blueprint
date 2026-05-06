# Stage Overview & Decision Tree

Six stages, ordered by dependency and immediate ROI. Each stage tells you what it gives you, what it depends on, and when it's safe to skip.

---

## The six stages

| # | Stage | Gives you | Depends on | Time to stand up |
|---|---|---|---|---|
| 1 | OTel + Jaeger | Unified observability substrate; one trace ID across everything that follows. | Nothing. | ~30 min |
| 2 | MAF runtime | Agent runtime that emits GenAI spans automatically via middleware tiers. | Stage 1. | ~2 hours |
| 3 | Cowork desktop | Parallel build sessions; auto-worktree per session; integrated terminal. | Nothing (independent of 1 and 2 from a tooling standpoint). | ~15 min |
| 4 | 3-PC topology | Always-on observability and Routines runner; PC 3 as persistent target. | Stage 1 (collector) + Stage 3 (parallel sessions to scale). | ~1 hour |
| 5 | Routines | Scheduled awareness; status-digest comments on a pinned dashboard issue. | Stage 4 (PC 3 reachable from cloud) is *recommended* but not required. | ~30 min |
| 6 | Dispatch phone-pairing | Mobile remote control: kick off jobs, read status, paste prompts. | Stage 3. | ~5 min |

---

## Decision tree: build all vs. some

**Are you running agents in production?**

- **Yes** → you need at least Stages 1 and 2. Skip Stage 1 only if you have a different observability stack you're committed to.
- **No, this is a build-time tool** → you can probably skip Stages 1 and 2 entirely. Focus on 3.

**Are you running ≥2 parallel work-streams on this project?**

- **Yes** → Stage 3 is high ROI.
- **No (solo, one stream)** → Stage 3 is overkill. CLI Claude Code is fine. You can adopt later.

**Do you regularly hit ≥4 parallel sessions or run heavy-compute streams?**

- **Yes** → Stage 4 starts paying off.
- **No** → skip Stage 4. One or two PCs is enough.

**Are you spending ≥3 status-checks per active build day on polling?**

- **Yes** → Stage 5 saves real time.
- **No** → manual polling is cheaper than setup.

**Are you regularly away from the keyboard while builds are in flight?**

- **Yes** → Stage 6 is worth the 5 minutes.
- **No** → skip; revisit if your work patterns change.

---

## Adoption paths

### Path A — Solo greenfield, no production agents yet

Stage 3 (Cowork desktop). That's it. Add Stage 1 when you start shipping agents. Add Stage 6 when you start working away from your desk.

### Path B — Small team, production agents, single project

Stages 1, 2, 3 in order. Add Stage 5 (Routines) once your status files become a noise generator.

### Path C — Multi-project shop with parallel build velocity

All six stages, in numeric order. The 3-PC topology and Routines pay off most when you have multiple repos in flight.

### Path D — Replacing legacy stack incrementally

Start with Stage 1 (OTel) only. Run alongside your existing telemetry. Once you trust it, retire the legacy stack and move to Stage 2 (MAF) for new agents only.

---

## What "done" looks like for each stage

Each stage has a **verification command** at the bottom of its doc. The format mirrors how Steppe Integrations' internal projects gate phase transitions: stage is done when the verify command exits clean.

Examples:

- Stage 1 verify: `curl http://localhost:4318/v1/traces -X POST` returns 2xx.
- Stage 2 verify: an MAF agent run produces at least one span with `gen_ai.agent.name`.
- Stage 3 verify: a Cowork session produces a worktree at `worktrees/<session-name>`.
- Stage 4 verify: PC 1 exports a span; the trace appears in PC 3's Jaeger UI.
- Stage 5 verify: a manual Routine run posts a comment on the dashboard issue.
- Stage 6 verify: scanning the Dispatch QR pairs your phone; status digest renders on phone.

---

## Order rationale

Why this exact order?

- **OTel before MAF** because MAF agents emit OTel spans by default; running MAF without a collector means throwing away free telemetry.
- **Cowork independent of OTel/MAF** because parallel build sessions help even if you're not yet shipping agents. Adopt whenever the project has ≥2 streams.
- **3-PC after Cowork** because you can't usefully scale to 3 PCs without parallel sessions to distribute.
- **Routines after 3-PC** because Routines are most valuable when they have a stable home (PC 3) to query.
- **Dispatch last** because phone-pair is an accelerant for an already-mature workflow, not the entry point.

---

Next: **[`docs/02-otel-foundation.md`](02-otel-foundation.md)**.
