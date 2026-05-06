# Orchestrator discipline (parallel-build)

Condensed durable rules for an orchestrator running parallel build streams. Distilled from multiple successful parallel builds; preserve across sessions.

## Rules

1. **Status files are the comm channel.** If a decision isn't written back to the relevant status file, it didn't happen. Chat history is ephemeral.

2. **Design-ack is a hard gate.** A builder that runs ahead of `[DESIGN-ACK]` risks rework. Make them wait. Trade clock time for less re-do.

3. **Merge one at a time.** Never two parallel merges. Always re-run verify on the merge commit, not just the branch tip. After each merge, push immediately so other streams see new main.

4. **Hotfix during merge, don't roll back.** If integration tests fail post-merge, spawn a hotfix session in a new worktree. Land the fix as a separate commit on top. Keep the merge sequence linear.

5. **Integration is orchestrator-owned.** Builders own their stream's branch. Integration belongs to the orchestrator — including the verify-pass requirement.

6. **`[NEEDS-HUMAN]` is a stop sign.** When a decision exceeds the orchestrator's authority, surface to the human. Do not paper over it with a guess.

7. **Re-read before commit in concurrent sessions.** Multiple sessions can edit shared files (memory, plans, ADRs). Re-read pre-commit if you've been idle. Respect any "file modified externally" notice as a hard checkpoint.

8. **Status file signals are append-only.** Never delete or edit prior signals. The history is the audit trail.

## Anti-patterns

- Acking a design without reading the design doc.
- Merging because a builder said `[COMPLETE]` without re-running verify on the merge commit.
- Multi-merging "to save time."
- Letting a `[BLOCKED]` linger past one orchestrator pass.
- Editing a status file (vs appending) — destroys audit.

## Watch for

- Orchestrator becoming a bottleneck (acking slower than builders produce). Signal: streams pile up at `[DESIGN-READY]`. Fix: orchestrate fewer streams in parallel.
- Builders running ahead of acks. Signal: code commits that predate `[DESIGN-ACK]`. Fix: stricter kickoff prompts.
- Status file signal dilution. Signal: people inventing new gate signals. Fix: stick to the canonical alphabet.
