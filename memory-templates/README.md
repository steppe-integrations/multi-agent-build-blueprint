# Memory Templates

Starter `feedback_*.md` and `reference_*.md` files for your project's memory directory.

These don't go in *this* repo when you adopt — they go in your project's per-project Claude memory directory, typically `~/.claude/projects/<your-project-mangled-path>/memory/`, or in a `.claude/memory/` directory inside your repo if your tooling reads from there.

The four files in this directory cover the conventions assumed throughout the docs:

| File | Tier | Purpose |
|---|---|---|
| `reference_powershell_51_gotchas.md` | reference | Warns future sessions about PS 5.1 quoting, `Start-Process -ArgumentList`, lack of ternary/`??`/`&&`. |
| `feedback_phase_discipline.md` | feedback | Reinforces the refine → plan → build sequence. |
| `feedback_orchestrator_discipline.md` | feedback | Condensed durable rules for parallel-build orchestrators. |
| `reference_3pc_pattern.md` | reference | Pointer to the 3-PC topology canon. |

---

## How to use

1. Pick the templates that match your stack and patterns.
2. Copy them to your project's memory directory.
3. Edit the project-specific bits (paths, commit conventions, team names).
4. Add a one-line entry per file to your `MEMORY.md` index so they auto-load.

The `MEMORY.md` index format is:

```markdown
- [Short title](filename.md) — one-line summary of why this matters.
```

---

## What's intentionally NOT here

- **`user_*.md`** files — those describe the operator's personal context (background, preferences). Build those yourself based on your own situation; templates would be misleading.
- **`project_*.md`** files — those describe a specific project's identity. Write them when you have a project to describe.

The templates here cover the *patterns* this repo teaches; the user/project-specific files are yours to author.
