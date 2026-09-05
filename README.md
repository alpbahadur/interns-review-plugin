<p align="center">
  <img src="docs/hero.png" alt="interns-review: your agent's first idea is a draft. interns-review makes it a decision." width="100%">
</p>

<h1 align="center">interns-review</h1>

<p align="center">
  <b>Adversarial review for every solution your coding agent proposes.</b><br>
  1–3 independent Fable reviewers tear the idea apart. The lead agent verifies their findings against the code, keeps what's real, and ships the rest.
</p>

<p align="center">
  <a href="#install">Install</a> ·
  <a href="#how-it-works">How it works</a> ·
  <a href="#why">Why</a> ·
  <a href="#other-agents">Other agents</a> ·
  <a href="#tuning">Tuning</a>
</p>

---

## Why

Coding agents are confident. Their first proposal is usually *plausible*, often *incomplete*, and sometimes *wrong* in a way you only discover after it ships.

The usual fix is "ask it to double-check". That doesn't work: the same model, in the same context, with the same blind spots, reviewing its own idea.

**interns-review** changes the shape of the loop:

| Without | With interns-review |
|---|---|
| One model, one pass, one opinion | Lead proposes, independent reviewers attack, lead judges |
| Reviewer sees the whole conversation and inherits its assumptions | Reviewers see only a clean context file and the repo |
| "Looks good to me" | Severity-tagged findings, verified against actual code, or explicitly marked `unverified` |
| Every suggestion gets applied | Findings are **intern findings**: wrong ones are rejected with a reason |
| Reviews drift into refactor proposals | "Do not over-engineer" is a rule for the reviewers *and* the lead |

Result: you get a solution that survived contact with three critics, plus a two-line receipt of what they changed and what was thrown out.

## How it works

Triggered automatically whenever the agent has formed a proposal (design, architecture choice, bug diagnosis + fix, refactor plan). Also manual via `/consensus`.

1. **Context file.** The lead writes one self-contained file: problem, verbatim errors, `path:line` pointers with targeted snippets, constraints, what was already ruled out, the proposed solution, and its own doubts. No conversation history leaks in. Reviewers never see the chat, so they cannot inherit the lead's framing, its half-remembered assumptions, or the user's earlier hints. Pointers instead of pasted files force the reviewers to open the real code rather than trust a summary. The lead's own doubts go in on purpose: a reviewer told where the lead is unsure spends its effort where it matters.
2. **Reviewers.** 1–3 `consensus-reviewer` subagents (model: `fable`, read-only tools) run in parallel with the prompt:
   > *Critically review the solution to the problem suggested by our intern. Be critical: review it, verify it against the code, and suggest changes to the solution if it is not good enough. Do not over-engineer.*

   Each gets a different lens: correctness & root cause / edge cases & blast radius / simplicity & over-engineering. Read-only tools mean a reviewer can grep, read, and run checks but cannot touch the tree. Output is a fixed shape: verdict, severity-tagged findings with `path:line`, an optional simpler alternative, and a verification suggestion, capped at roughly sixty lines. Anything a reviewer could not confirm in the code must be marked `unverified` rather than asserted.
3. **Filter.** The lead opens the code for every finding. Wrong, out-of-scope, style-only, or over-engineered findings are rejected. Disagreements are settled by the code, not by majority vote. A genuinely simpler alternative from a reviewer wins over the lead's original. This is the step that makes the loop honest: reviewers are strong models but they are still guessing from a cold start, so their output is treated as intern work, not gospel. Every accept and every reject must have a one-line reason the lead could defend. If the code cannot settle a disagreement, it is escalated to the user as an open question instead of being quietly decided.
4. **Final solution + receipt.** Reviewers spawned, accepted findings, rejected findings with reasons, open questions only the user can answer. The receipt is short by design: a few lines, not a transcript of three reviews. It lets you see at a glance what changed because of review and what was thrown out, so you can override either. The context file is disposable and can be deleted once the receipt is written.

Reviewer count scales with stakes:

| Situation | Reviewers |
|---|---|
| Contained bug fix, low blast radius | 1 |
| Design decision, cross-cutting refactor, unclear root cause | 2 |
| Architecture, data model, security, migrations, irreversible changes | 3 |

Skips automatically for trivial one-liners and pure Q&A. Say **"no consensus"** or **"skip review"** to skip on demand.

## Install

```bash
claude plugin marketplace add alpbahadur/interns-review-plugin
claude plugin install interns-review@interns-review --scope user
```

`--scope user` enables it for every Claude Code session on the machine. Restart open sessions to load it.

## What's in the box

| Path | Purpose |
|---|---|
| `skills/consensus/SKILL.md` | The workflow. Auto-triggers on a proposal; also `/consensus`. |
| `agents/consensus-reviewer.md` | Reviewer subagent: Fable, read-only tools, strict `VERDICT / FINDINGS / ALTERNATIVE` output, ≤60 lines. |
| `hooks/` | Injects the rule at session start and a one-line reminder on every prompt, so long sessions don't forget it. |
| `commands/consensus.md` | `/consensus` slash command. |
| `templates/context.md` | Skeleton for the context file. |
| `AGENTS.md` | The same workflow written for non-Claude agents. |
| `docs/hero.html` | The banner above. Open in a browser and screenshot. |

## Other agents

Not on Claude Code? `AGENTS.md` describes the identical loop in agent-agnostic terms. Drop it into your Codex / Cursor / Gemini CLI instructions and point the reviewer role at the strongest model you have.

## Tuning

- **Reviewer count table:** `skills/consensus/SKILL.md`, Step 2.
- **Reviewer model / tools:** frontmatter in `agents/consensus-reviewer.md`.
- **Reminder wording / skip words:** `hooks/consensus-reminder.sh`.
- **Update after editing:** push, then `claude plugin update interns-review@interns-review`.

## Status

Early. Private for now. Open-sourcing once it has survived a few weeks of real use.
