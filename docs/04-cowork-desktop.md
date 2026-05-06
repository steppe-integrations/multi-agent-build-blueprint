# Stage 3 — Cowork Desktop

**Goal:** run parallel build sessions in one Cowork desktop client. Each session = its own auto-created git worktree.

**Time:** ~15 minutes (mostly download + first-run setup).

**Depends on:** nothing. (Stage 3 is independent of Stages 1–2 from a tooling standpoint.)

---

## Why Cowork desktop

Three things in one place:

1. **Parallel sessions in the sidebar.** Each session = own git worktree. Filesystem partitioned; no edit collisions.
2. **Integrated terminal + editor.** Agents that need to verify what they just built can do it in-place, in the same conversation.
3. **Phone pair via QR.** Dispatch turns the phone into a remote control.

Cowork desktop launched on Windows in early April 2026. Mac/Linux available earlier. Phone pairing (Dispatch) shipped shortly after.

---

## Steps

### 1. Install Cowork desktop

Download from [claude.com/code/cowork](https://claude.com/code) (or wherever Anthropic ships the installer for your platform). Sign in with your Pro/Max/Team/Enterprise account. Cowork is a paid feature.

### 2. Open your project

`File → Open Project → <your project root>`. Cowork detects your repo, reads `CLAUDE.md` if present, and loads any `.claude/` directory contents (skills, slash commands, project memory).

### 3. Spawn your first session

Click **New Session** in the sidebar. Name it (e.g., `feature-x`). Cowork creates a worktree at `worktrees/feature-x` (path may vary by version). The session opens in its own pane with terminal + editor + chat.

### 4. Run a kickoff prompt

Paste a prepared kickoff prompt. See [`prompts/kickoff-template.md`](../prompts/kickoff-template.md) for the canonical shape. The session takes it from there.

### 5. Spawn a second session in parallel

Click **New Session** again. Name it differently. New worktree. The two sessions run in parallel without touching each other's files.

### 6. Set up status files for orchestrator-style coordination

If your project uses status files (recommended for ≥2 parallel streams), see [`docs/orchestration-pattern.md`](orchestration-pattern.md) for the gate alphabet and status-file conventions.

---

## How sessions communicate

Sessions don't talk directly. They communicate through:

- **Status files** in the repo (typically `docs/phase{N}-stream-{X}-status.md`).
- **Branch tips** (each session pushes its own branch).
- **The orchestrator** — usually you, the human — who reads status files and merges.

This is intentional. Direct session-to-session communication would create a coordination nightmare. Async-via-git is the simpler model.

---

## Verification command

After spawning a session named `feature-x`:

```powershell
if (Test-Path "worktrees\feature-x\.git") { "COWORK-WORKTREE-OK" } else { exit 1 }
```

(Adjust path if your Cowork version uses a different worktree location.)

---

## Common pitfalls

- **No worktree appears.** Cowork may have failed to create it. Check Cowork's output panel for git errors. Sometimes a stale worktree from an earlier session blocks creation; clean up with `git worktree prune`.
- **Two sessions edit the same file.** They shouldn't, but if you accidentally checkout the same branch in two sessions, edits will conflict on merge. Always one branch per session.
- **Sessions lose context on restart.** Cowork persists conversation history per session. If history is lost, check Cowork's data directory (`%LOCALAPPDATA%/Cowork/sessions/`).
- **Memory not loading.** Check that your project's `.claude/` directory and `CLAUDE.md` are in the project root. Cowork loads from project root, not from the worktree.

---

## When to grow into Stage 4 (3-PC)

Stay on one PC until:
- Parallel-session count regularly exceeds 4–5.
- A heavy-compute session blocks orchestrator responsiveness for >30s at a time.
- You want telemetry to survive your laptop sleeping.

When any of those is true, see **[`docs/05-3pc-topology.md`](05-3pc-topology.md)**.

---

## What you have now

A Cowork desktop client that can run multiple parallel sessions, each in its own worktree, without filesystem collisions. The substrate for everything that follows.

Next: **[`docs/05-3pc-topology.md`](05-3pc-topology.md)** when you're ready to scale, or **[`docs/06-routines.md`](06-routines.md)** to add ambient awareness on a single PC.
