# Stage 5 — Routines

**Goal:** schedule a cloud Routine that polls active phase-stream branches, reads status files, optionally joins with OTel data, and posts a state digest as a comment on a pinned GitHub issue.

**Time:** ~30 minutes.

**Depends on:** an Anthropic plan that supports Routines (Pro / Max / Team / Enterprise as of writing). Stage 4 (PC 3 reachable) is recommended but not strictly required for the basic digest.

---

## Why Routines

You're spending ≥3 status-checks per active build day asking "what's everyone up to?" Polling is friction. A Routine replaces it with ambient awareness:

- Runs every 20 minutes (or whatever cadence you pick).
- Reads status files from each active stream branch.
- Posts a unified digest as a comment on a pinned GitHub issue.
- You read the comment in 30 seconds on your phone.

Routines launched as a research preview April 14, 2026, and are GA on most Anthropic plans now.

---

## Steps

### 1. Pick a dashboard issue

Create (or pick an existing) GitHub issue in your repo. Label it `phase-orchestration-dashboard`. The Routine posts comments here.

### 2. Pin the issue

Manual one-click in the GitHub issue UI. Pinned issues stay visible.

### 3. Create the Routine in the Cowork UI

`Cowork → Routines → New Routine`. Paste the configuration from [`prompts/routine-status-digest.md`](../prompts/routine-status-digest.md). Key fields:

- **Schedule:** `*/20 * * * *` (every 20 min) for active build phases. Switch to `0 * * * *` (hourly) when no phase is in progress.
- **Repo connector:** your repo. Read access for branches/commits/files; write access for issue comments.
- **Optional Jaeger connector:** if PC 3 is reachable from Anthropic's runners. Skip this for the basic version.
- **Prompt:** see the prompts file. It describes the procedure in detail.

### 4. Run it manually once

In the Routines UI, hit "Run now." Verify a comment appears on the dashboard issue with a state table. Adjust cadence/prompt if needed.

### 5. Subscribe yourself to the issue

GitHub issue subscribe button. Phone notifications fire when the Routine posts a new comment.

### 6. (Optional) Add a slash command for on-demand digests

[`prompts/slash-dispatch-summarize.md`](../prompts/slash-dispatch-summarize.md) is a paste-ready slash command (`/dispatch-summarize`) that produces the same digest on demand from any Cowork session.

---

## Pause / stop

- **Pause:** Routines UI → toggle off.
- **Tighten cadence** during heavy build days (`*/10 * * * *`).
- **Loosen** on quiet days (`0 * * * *` or pause entirely).
- **Delete:** only after archiving the dashboard issue. The issue is durable; the Routine is the publisher.

---

## Cost / quota

Routines run on Anthropic's web infrastructure with daily caps that scale by plan. A 20-minute cadence is ~72 runs/day. Verify against your plan's current limit in the Routines UI before activating; reduce cadence if you hit caps.

---

## Verification command

After the first scheduled run:

- Check `https://github.com/<your-org>/<your-repo>/issues?q=label:phase-orchestration-dashboard`.
- It should have at least one comment from the Routine.
- The comment table should reflect actual stream branches.
- Push a status-file update to a branch; the next run should reflect the new gate signal.

---

## Common pitfalls

- **Routine posts duplicate comments.** Step 6 of the prompt (in `prompts/routine-status-digest.md`) compares to the previous comment and skips if identical. If you see dupes, the comparison logic isn't kicking in — check the prompt verbatim.
- **Routine fails silently.** Open the Routines UI run log. Common causes: connector permissions, missing labels, branch naming pattern mismatch.
- **Cadence too aggressive.** 20-min during quiet periods burns quota for no signal. Pause or loosen during downtime.
- **Wrong dashboard issue.** Make sure exactly one issue has the `phase-orchestration-dashboard` label. The prompt picks the first match.

---

## What you have now

Ambient awareness: a self-updating dashboard for parallel build streams. Phone notifications on state change. Replaces the human poll-and-ask loop.

Next: **[`docs/07-dispatch-phone.md`](07-dispatch-phone.md)** to pair your phone for direct Cowork interaction.
