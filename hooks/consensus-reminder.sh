#!/usr/bin/env bash
# Injects the consensus rule into context. Full text at SessionStart, one-liner on every prompt.
if [ "$1" = "short" ]; then
  echo "CONSENSUS RULE ACTIVE: before presenting any design proposal or bug-fix solution as final, run the /consensus skill (write context file -> 1-3 consensus-reviewer subagents -> filter findings as intern findings -> final solution). Skip only for trivial one-liners or when user says 'no consensus'."
  exit 0
fi
cat <<'MSG'
CONSENSUS MODE ACTIVE.

Whenever you have produced a proposed solution — a design, an architecture choice, a bug diagnosis + fix, a refactor plan, a non-trivial implementation approach — you MUST run it through the `consensus` skill before presenting it as final:

1. Write the full problem context + your proposed solution to ONE temp file (pointers to files/lines, constraints, what was tried).
2. Spawn 1-3 `consensus-reviewer` subagents (Fable) with that file. They critically review and suggest changes. No over-engineering.
3. Treat their findings as INTERN findings: verify each against the code, reject wrong/over-engineered ones, keep the valid ones.
4. Fold accepted findings into the final solution. Present final solution + short note of what reviewers changed / what you rejected and why.

Skip only for: trivial one-line changes, pure questions with no proposed solution, or when the user explicitly says "no consensus" / "skip review".
MSG
