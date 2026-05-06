# ADR Templates

Architecture Decision Record templates for the load-bearing decisions in this stack.

When you make a decision worth preserving — picking Jaeger over Tempo, choosing single-PC vs 3-PC, deciding on a specific MAF middleware tier ordering — write an ADR. Future-you will thank present-you.

## Files

- **[`0001-template.md`](0001-template.md)** — generic ADR template. Copy + rename for each new decision.

## Numbering

ADRs are numbered sequentially within a project: `0001-`, `0002-`, etc. Don't skip; don't renumber. Numbers are stable references.

## Tooling

Optional but useful: [adr-tools](https://github.com/npryce/adr-tools) automates `adr-new "Title"` to scaffold the next-numbered file.

## What's worth an ADR

- Stack choices (telemetry backend, agent framework, runtime).
- Topology choices (single-PC vs 3-PC, sync vs async A2A).
- Naming conventions (status file paths, branch patterns, gate alphabet additions).
- Sourcing decisions (vendor X vs Y, build vs buy).

## What's NOT worth an ADR

- Trivial code style.
- Implementation details below the contract.
- Decisions that won't survive a year.

If you find yourself unsure: lean toward writing one. They're cheap; the cost of *not* having one when a future session needs to understand a decision is much higher.
