---
name: consensus
description: >
  Run a proposed solution (design, architecture choice, bug diagnosis + fix, refactor plan)
  through a critical consensus review by 1-3 Fable subagents before presenting it as final.
  Use automatically whenever you have just formed a solution proposal and before you
  present or implement it. Also on "/consensus", "run consensus", "get this reviewed",
  "second opinion". Skip for trivial one-liners or when the user says "no consensus".
---

# Consensus review loop

Goal: catch wrong, incomplete, or over-engineered solutions before they reach the user, without blindly trusting the reviewers either.

Roles:
- **You (main agent)** = the lead. You wrote the proposal. You also judge the reviews.
- **consensus-reviewer subagents** = senior critics, but you treat their output as **intern findings**: plausible, must be verified, can be wrong.

## Step 1 — Write the context file

Write ONE file to the scratchpad directory (or `/tmp/consensus-<timestamp>.md` if no scratchpad). Use the template in `templates/context.md` (relative to this plugin). It must be self-contained: a reviewer with zero conversation history must be able to judge the proposal from this file plus the repo.

Include:
- Problem statement, in your own words. What the user actually asked.
- Symptoms / error text verbatim if any.
- Pointers: `path:line` for every relevant piece of code, config, or doc. Short quoted snippets where the reviewer would otherwise have to hunt.
- Constraints: performance, compatibility, style, "do not touch X", deadlines, user preferences stated in the conversation.
- What was already tried or ruled out, and why.
- **The proposed solution**, concrete: which files change, how, and why. Diff-level detail where you have it.
- Your own open doubts (one or two lines). Reviewers focus better when told where you are unsure.

Do not paste whole files. Pointers plus targeted snippets.

## Step 2 — Spawn reviewers

Pick the number of reviewers by stakes:

| Situation | Reviewers |
|---|---|
| Small bug fix, contained change, low blast radius | 1 |
| Design decision, cross-cutting refactor, unclear root cause | 2 |
| Architecture, data model, security, migrations, irreversible changes | 3 |

Spawn them **in parallel, in one message**, each with `subagent_type: "consensus-reviewer"` and this prompt (adapt the path):

```
Critically review the solution to the problem suggested by our intern. Be critical: review it, verify it against the code, and suggest changes to the solution if it is not good enough. Do not over-engineer.

Context file: <absolute path>
```

When spawning 2-3, give each a slightly different lens so they do not converge on the same finding:
- Reviewer A: correctness and root cause.
- Reviewer B: edge cases, side effects, blast radius.
- Reviewer C: simplicity — is there a materially simpler way; is anything over-built.

Never do the review yourself instead of spawning. The point is independent eyes.

## Step 3 — Filter the findings (intern rule)

Read every finding. For each one:

1. **Verify it against the code yourself.** Open the file. A reviewer that says "unverified" or cites a line that does not say what they claim gets no credit.
2. **Reject** findings that are: factually wrong, out of scope, over-engineering, style-only, or contradict a user constraint.
3. **Accept** findings that are verified and change the outcome (correctness, missed case, real simplification).
4. Where reviewers **disagree**, the code decides, not majority vote. If you cannot decide from the code, say so to the user as an open question.
5. If a reviewer proposes an ALTERNATIVE that is genuinely simpler and meets the requirements, adopt it. Do not defend your original out of pride.

Do not blindly accept. Do not blindly dismiss. Every accepted or rejected finding must have a reason you could state in one line.

## Step 4 — Final solution

Present the final solution to the user. Then a short "Consensus" section:

- Reviewers spawned: N.
- Accepted: bullet per finding, one line each, what changed because of it.
- Rejected: bullet per finding, one line each, why.
- Open questions: anything the review surfaced that only the user can decide.

Keep this section short. It is a receipt, not a transcript. Then delete or leave the context file; it is disposable.

## When NOT to run

- Trivial edits (typo, rename, one obvious line).
- Pure informational answers with no proposed solution.
- User said "no consensus", "skip review", or is clearly iterating fast and asked for speed.
- You already ran consensus on this exact proposal and nothing changed.
