# Phase discipline — refine → plan → build

The three-phase discipline is sequential and explicit. Don't propose code or MVPs while refining or planning; wait for explicit phase transition.

## The three phases

1. **Refining.** Defining the problem. What are we even building, and why? Outputs: thesis docs, scoping docs, decision rationale. No code.
2. **Planning.** Designing how to build it. ADRs, schema definitions, stream decomposition, kickoff prompts, status-file conventions. No code yet — but the plan is concrete enough that code could start.
3. **Building.** Code. Tests. Verification. Status-file gate signals. The plan is the spec; deviations require [NEEDS-HUMAN] and explicit re-planning.

## Why this matters

Skipping refining produces solutions to the wrong problem. Skipping planning produces parallel sessions that drift into incompatible designs. Skipping building... well, then you haven't built anything.

The most common failure is *premature building*: an agent gets excited mid-refining and starts proposing code. This burns trust and forces rework.

## How to enforce it

- Each phase produces a named artifact: `thesis.md`, `plan.md`, source code + tests.
- The transition between phases is explicit: the human says "we're done refining, start planning" or commits a `[PHASE-PLANNING]` marker.
- Agents should *not* unilaterally move phases. If an agent thinks the current phase is done, it should say so and wait for explicit transition.

## When the rule bends

Tiny tasks (typo fixes, doc edits, single-file refactors) don't need three-phase discipline. The rule applies to changes substantial enough that getting the design wrong would be expensive.
