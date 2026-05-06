# ADR-NNNN — {{Title}}

**Status:** {{Proposed | Accepted | Superseded by ADR-XXXX | Deprecated}}
**Date:** {{YYYY-MM-DD}}
**Stream / Phase:** {{e.g., Phase 2 — Stream B, or "cross-cutting"}}

---

## Context

What's the situation? What forces are at play? What constraints are non-negotiable?

Keep this section factual. Don't argue for the decision yet — just describe the territory.

---

## Decision

The decision in one or two sentences. Bold the key choice.

**We will {{do specific thing}} because {{driving reason}}.**

Then expand: what does "do specific thing" actually mean concretely? Reference contracts, schemas, code paths, tooling.

---

## Consequences

### Positive

- What gets easier?
- What previously hard problem becomes tractable?
- What's the leverage we gain?

### Negative

- What gets harder?
- What did we give up?
- What new failure modes do we accept?

### Neutral

- Things that change shape but aren't strictly better or worse.

---

## Alternatives considered

### Alternative 1 — {{name}}

What was it? Why didn't we pick it? Be honest — if it was a close call, say so.

### Alternative 2 — {{name}}

Same shape.

---

## Verification

How would you check that this ADR is being followed? Ideally an executable command:

```powershell
# Some test or grep that fails if the decision is violated
```

If a verification command isn't possible, describe the human checkpoint: "code reviews must confirm X."

---

## References

- Related ADRs: ADR-XXXX, ADR-YYYY
- External docs / specs / RFCs
- Discussion thread (if any)
