# Routine — `status-digest` (paste-ready spec)

**Purpose:** scheduled cloud Routine that polls every active phase-stream's status file + branch tip, optionally joins with the cross-PC OTel collector's recent traces, and posts a unified state digest as a comment on a pinned GitHub issue. Replaces the human poll-and-ask loop with ambient awareness.

**Where to create:** Cowork's Routines UI (Pro / Max / Team / Enterprise plans).

---

## Routine configuration

### Name

`status-digest`

### Description (for the routine list)

Polls active phase-stream status files + branches, posts a state digest comment on the pinned dashboard issue.

### Schedule

`*/20 * * * *` (every 20 minutes) for active build phases. Switch to `0 * * * *` (hourly) when no phase is in progress, or pause via the Routines UI.

### Repository connectors

- **Primary:** `<your-org>/<your-repo>` — read access for branches, commits, files; write access for issue comments.

### Optional connectors

- **Jaeger HTTP API** at `http://<pc3-host>:16686` — only useful if PC 3 is reachable from Anthropic's Routines runners (likely requires Tailscale on PC 3 + a static reachable address). If unreachable, the routine degrades gracefully: it skips the OTel section.

### Prompt (paste verbatim into the Routine's prompt field)

```
You are the status-digest Routine. Run this procedure. Output exactly
one markdown block as the issue comment. Do not chat; do not ask questions;
do not produce additional commentary outside the comment.

PROCEDURE:

1. Find the pinned dashboard issue. Search issues with label
   "phase-orchestration-dashboard". If none exists, create one with that
   label, title "Phase orchestration dashboard", and body
   "Posted by Routine status-digest. Latest state appears as comments
   below."

2. List active phase-stream branches: `git branch -r | grep phase`. Filter
   to branches with at least one commit in the last 14 days. (For inactive
   branches, skip — they're stale or merged.)

3. For each active stream branch:
   a. Read the matching status file from THAT branch (not main). Path
      conventions: docs/phase{N}-stream-{X}-status.md.
   b. Extract the latest gate signal. Recognized signals:
      [RESEARCH-DONE], [DESIGN-READY], [DESIGN-ACK], [BLOCKED: reason],
      [UNBLOCK-X], [COMPLETE] <sha>, [MERGED]. Take the LAST occurrence.
   c. Note the branch tip commit message and timestamp.
   d. If the gate signal is [COMPLETE] but the branch is not merged into
      main, mark the stream as "ready to merge."
   e. If the gate signal is [BLOCKED: reason], capture the reason string.

4. (Optional, only if Jaeger connector is configured) Query Jaeger for
   services in the last 30 minutes. Note any service that has not emitted a
   span in 15+ minutes — that may indicate a stuck session.

5. Build the comment. Use this exact shape:

   ## Phase orchestration dashboard — {ISO-8601 UTC timestamp}

   **Active streams:** N

   | Stream | Branch | Latest gate | Last commit | Action |
   |---|---|---|---|---|
   | A | <branch> | <gate signal> | <sha> (Nh ago) | <none/needs-ack/merge-ready/blocked-reason> |
   | ... | ... | ... | ... | ... |

   **Needs orchestrator:** {list streams flagged needs-ack or blocked-reason, or "none"}.

   **Ready to merge:** {list streams flagged merge-ready, or "none"}.

   {If Jaeger connector configured:}
   **Observability heartbeat:**
   - <service>: <last span timestamp> ({ok/silent-15m+/silent-60m+})
   - ...

   ---
   *Posted by Routine `status-digest`. Source: status files on each
   stream branch. Edit cadence in the Routine config.*

6. If the comment content is identical to the previous comment posted by
   this routine within the last 60 minutes, skip — do not create noise.
   Compare by canonical-form (drop the timestamp from the title row).
```

### Trigger flags

- **Pause when no active streams.** If step 2 returns zero streams, do not post a comment for this run; just exit.
- **Skip identical posts.** Step 6 prevents stale-state spam.
- **Auto-pin the dashboard issue.** Manual on first run; the Routine doesn't auto-pin.

---

## First-run setup

1. Create the routine via the Cowork UI. Paste the prompt verbatim.
2. Run it once manually to verify it creates the dashboard issue with the correct label.
3. Pin the dashboard issue in the GitHub repo (one click in the issue UI).
4. Confirm the schedule is `*/20 * * * *` for active build phases.
5. Subscribe yourself to the issue so phone notifications fire on update.

---

## Verification

After the first scheduled run:

- Issue exists at `https://github.com/<your-org>/<your-repo>/issues?q=label%3Aphase-orchestration-dashboard`.
- It has at least one comment from the routine.
- Comment table accurately reflects active stream branches.
- If you pushed a status-file update to a stream branch within the last 20 min, the next run reflects the new gate signal.
