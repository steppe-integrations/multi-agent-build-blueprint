# Slash Command — `/dispatch-summarize`

A paste-ready slash command for on-demand state digests from any Cowork session. Phone-friendly: ≤12 lines, designed to read in 30 seconds.

Save this as `~/.claude/commands/dispatch-summarize.md` (or your project's `.claude/commands/`).

---

```markdown
---
description: Phone-friendly state digest for active phase-stream branches.
---

You are the dispatch-summarize command. Output a phone-friendly digest. Maximum 12 lines.

PROCEDURE:

1. List active phase-stream branches:
   `git branch -r | grep phase`
   Filter to branches with at least one commit in the last 14 days.

2. For each active branch:
   a. Read docs/phase{N}-stream-{X}-status.md from that branch.
   b. Extract the latest gate signal.
   c. Note the branch tip's commit timestamp.
   d. Compute a status emoji:
      - [COMPLETE] not merged → 🟢 ready to merge
      - [DESIGN-READY] not yet [DESIGN-ACK] → 🟡 awaiting orchestrator
      - [BLOCKED: ...] → 🔴 blocked
      - In progress (any other state) → 🔵 in progress
      - No commits in 24h → ⚪ idle
      - [MERGED] → ⚫ merged

3. Output format (≤12 lines):

   ```
   📡 Stream digest — {HH:MM UTC}

   🟢 Stream A: ready to merge (sha abc123, 2h ago)
   🟡 Stream B: awaiting design-ack (1h ago)
   🔵 Stream C: in progress (15min ago)
   🔴 Stream D: BLOCKED — needs schema decision (4h ago)
   ⚪ Stream E: idle 2 days

   Action: ack B, merge A.
   ```

4. End with a one-line action summary: "Action: <verbs>".
   If nothing actionable, end with "Action: none. Watch C."

5. If no active streams, output: "📡 No active streams. All quiet."
```

---

## Why this exists

- The Routine posts to GitHub on a schedule. This slash command lets you ask *now* without waiting for the next 20-min tick.
- Phone-friendly format. Read in a glance.
- Same gate alphabet as the Routine for consistency.

---

## Variants

- `/dispatch-summarize-deep` — same but includes the Jaeger heartbeat section.
- `/dispatch-summarize-one A` — single-stream variant for when you only care about one.

Define those as separate command files following the same pattern.
