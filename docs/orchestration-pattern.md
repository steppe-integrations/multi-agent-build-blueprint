# The Orchestration Pattern

The async coordination pattern that makes parallel build sessions work without merge conflicts or scope drift. Status files as comms, gate signals as state, design-acks as humans-in-the-loop.

This page is referenced from [`04-cowork-desktop.md`](04-cowork-desktop.md). It's not a stage in itself — it's the *discipline* you bring to whatever stage you're at.

---

## The problem this solves

Multiple Cowork sessions running in parallel will:
- Edit the same files if you let them.
- Make conflicting design decisions if they don't see each other.
- Drift from the plan if no one's watching.

You need a way for sessions to coordinate *without* talking to each other directly. The answer: status files committed to git, with a small alphabet of gate signals.

---

## The gate alphabet

| Signal | Meaning | Who emits | Who reads |
|---|---|---|---|
| `[RESEARCH-DONE]` | Session has explored the problem space and is ready to propose a design. | Builder session | Orchestrator |
| `[DESIGN-READY]` | Builder has a concrete proposal. Orchestrator should review. | Builder | Orchestrator |
| `[DESIGN-ACK]` | Orchestrator approves the design. Builder may proceed to implementation. | Orchestrator | Builder |
| `[BLOCKED: <reason>]` | Builder cannot proceed; needs unblock. | Builder | Orchestrator |
| `[UNBLOCK-X]` | Orchestrator's unblock instruction (X is freeform). | Orchestrator | Builder |
| `[COMPLETE] <sha>` | Builder finished and tested. Branch ready to merge. | Builder | Orchestrator |
| `[NEEDS-HUMAN]` | Decision exceeds the orchestrator agent's authority. | Anyone | The user |
| `[MERGED]` | Orchestrator merged the branch into main. | Orchestrator | Everyone |

The signals are intentionally short and unambiguous. Routines, slash commands, and humans all parse them the same way.

---

## Status file convention

Path: `docs/phase{N}-stream-{X}-status.md`.

Shape:

```markdown
# Phase {N} — Stream {X} status

## Goal
<one paragraph describing what this stream produces>

## Gates
- 2026-05-01 14:32 [RESEARCH-DONE] Researched X, Y, Z. Recommend approach A.
- 2026-05-01 16:18 [DESIGN-READY] See docs/phase{N}-stream-{X}-design.md.
- 2026-05-01 17:45 [DESIGN-ACK] (orchestrator)
- 2026-05-02 09:11 [BLOCKED: need decision on schema for Foo]
- 2026-05-02 09:30 [UNBLOCK-X] Use the schema from ADR-014.
- 2026-05-02 14:22 [COMPLETE] abc123def
- 2026-05-02 14:35 [MERGED]

## Notes
<freeform notes for next session, links to artifacts, etc.>
```

The signals are *appended* — never edited or deleted. The full history is the audit trail.

---

## The orchestrator role

There's exactly one orchestrator per phase. It can be:
- **A human** (you, reading status files and merging by hand).
- **A dedicated Cowork session** (an agent reading and acking status files, with the human supervising).
- **A scheduled Routine** (limited — Routines can comment but shouldn't merge unsupervised).

Most teams start with a human orchestrator and graduate to an agent orchestrator as the discipline matures.

---

## Common patterns

### Pattern A — Hotfix during a merge

Builder finishes a stream → emits `[COMPLETE] <sha>`. Orchestrator starts merging. Mid-merge, integration test fails because of a regression in shared code.

Resolution: orchestrator does *not* roll back the merge. Instead, it spawns a *hotfix session* in a new worktree from the merge point, lands the fix, merges that on top, then continues with the original merge integration. This keeps the merge sequence linear and the audit trail clean.

### Pattern B — Design-ack gates protect velocity

A builder session that runs ahead of design-ack risks doing work that needs to be redone. Make `[DESIGN-READY]` → `[DESIGN-ACK]` a hard gate: the builder *waits* (literally idles or works on a small adjacent task) until the orchestrator acks.

This trades a bit of clock time for much less rework.

### Pattern C — Re-read before commit

When multiple agents are editing memory files or shared docs simultaneously (this happens more than you'd think), a builder should *re-read* any file it's about to commit, after pulling latest. If the file changed since the agent's last read, treat that as a hard checkpoint and reconcile before committing.

This catches silent clobbers in parallel-agent sessions.

---

## When to use this pattern

- ≥2 parallel build sessions on the same project. Mandatory.
- Solo, single-stream session. Skip — it's overhead with no upside.
- Distributed team with multiple humans driving parallel agents. Same pattern, just more orchestrators (each owning a phase).

---

## Failure modes to watch for

- **Status file ignored.** Builder doesn't update it; nobody knows the state. Fix: add a hard rule to the kickoff prompt that the first action is to write the initial status block.
- **Gate signal soup.** Too many one-off signals dilute the alphabet. Stick to the eight above; add only with explicit team agreement.
- **Orchestrator becomes bottleneck.** The orchestrator is acking faster than the builders are producing, or slower. If slower, you have too many parallel streams; if faster, you have idle orchestrator capacity (consider running a second phase in parallel).
- **No phase boundary.** When everything is one big phase, status files grow unbounded. Force phase boundaries — they're free organizational hygiene.

---

## Further reading

- [Five Layers article](https://steppeintegrations.com/articles/five-layer-build-blueprint/) — the methodology piece this pattern is part of.
- [`prompts/orchestrator-kickoff.md`](../prompts/orchestrator-kickoff.md) — paste-ready orchestrator agent prompt.
- [`prompts/builder-kickoff-template.md`](../prompts/builder-kickoff-template.md) — paste-ready builder agent prompt.
