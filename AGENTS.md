# Consensus review loop (agent-agnostic instructions)

This file is for agents other than Claude Code (Codex, Cursor, Gemini CLI, etc.) that cannot load the plugin natively. Copy it into your project's agent instructions file or point your agent at it.

Rule: whenever you have formed a proposed solution (design, architecture choice, bug diagnosis + fix, refactor plan, non-trivial implementation approach), run it through this loop BEFORE presenting it as final.

1. Write the full problem context and the proposed solution to ONE temp file. Use `templates/context.md` as the structure. Pointers (`path:line`) plus targeted snippets, not whole files.
2. Spawn 1 to 3 independent reviewer agents (strongest model available; in Claude this is Fable). Give each the file and this prompt:

   "Critically review the solution to the problem suggested by our intern. Be critical: review it, verify it against the code, and suggest changes to the solution if it is not good enough. Do not over-engineer."

   Reviewer output format and rules are in `agents/consensus-reviewer.md`. 1 reviewer for small contained fixes, 2 for design decisions / cross-cutting refactors, 3 for architecture / data model / security / irreversible changes.
3. Treat reviewer findings as INTERN findings. Verify each against the code yourself. Reject wrong, out-of-scope, over-engineered, or constraint-violating findings. Accept verified findings that change the outcome. Code decides disagreements, not majority vote.
4. Fold accepted findings into the final solution. Present it, followed by a short "Consensus" receipt: reviewers spawned, accepted findings (one line each), rejected findings (one line each, with why), open questions for the user.

Skip for trivial one-line edits, pure informational answers, or when the user says "no consensus".
