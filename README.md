# interns-review

Claude Code plugin. Every proposed solution the agent forms — a design, an architecture choice, a bug diagnosis + fix, a refactor plan — is critically reviewed by 1-3 Fable subagents before it is presented as final. The main agent treats reviewer output as intern findings: verifies each, keeps the valid ones, discards the rest.

## Flow

1. Main agent writes full problem context + proposed solution to one temp file (`templates/context.md`).
2. Spawns 1-3 `consensus-reviewer` subagents (model: fable) with: *"Critically review the solution to the problem suggested by our intern. Be critical, review, and suggest changes to the solution if it is not good enough. Do not over-engineer."*
3. Main agent verifies every finding against the code. No blind trust.
4. Accepted findings folded into the final solution, with a short receipt of what was accepted / rejected.

## What is in the box

| Path | Purpose |
|---|---|
| `skills/consensus/SKILL.md` | The workflow. Auto-triggers when the agent has a proposal; also `/consensus`. |
| `agents/consensus-reviewer.md` | Reviewer subagent definition (Fable, read-only tools, strict output format). |
| `hooks/hooks.json` + `hooks/consensus-reminder.sh` | Injects the rule at SessionStart and a one-line reminder on every prompt so the agent does not forget after long sessions. |
| `commands/consensus.md` | `/consensus` slash command. |
| `templates/context.md` | Template for the context file. |
| `AGENTS.md` | Same workflow written for non-Claude agents (Codex, Cursor, Gemini CLI...). |

## Install (Claude Code)

```bash
claude plugin marketplace add alpbahadur/interns-review-plugin
claude plugin install interns-review@interns-review --scope user
```

Private repo: `git` must be able to clone it (gh credential helper or SSH).

## Skip

Say "no consensus" or "skip review" in the prompt. Trivial one-line edits and pure Q&A skip automatically.

## Tuning

- Reviewer count table lives in `skills/consensus/SKILL.md` Step 2.
- Reviewer model: `model:` in `agents/consensus-reviewer.md`.
- Hook reminder text: `hooks/consensus-reminder.sh`.
