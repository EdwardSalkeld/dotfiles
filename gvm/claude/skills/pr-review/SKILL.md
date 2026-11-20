---
name: pr-review
description: Review someone's GitHub pull request in depth - what changed, real defects, and whether the PR description and docs agree with the code. Scouts the diff, splits it into areas, runs one reviewer per area with an adversarial verifier, then checks the description and docs against the verified result. Use when asked to review a PR by URL or number.
---

# Reviewing a pull request

The output answers two questions: **what changed** (especially runtime behaviour on live paths, as distinct from moves and dead-code removal) and **what is wrong with it**. Description and docs are checked last, against the verified code review, so they can't anchor it.

Invoking this skill is the opt-in to run the bundled workflow.

## 1. Check out the PR

Work in a throwaway worktree in the scratchpad, from the existing clone if there is one:

```
R=~/workspace/<repo>       # else: git clone --filter=blob:none into the scratchpad
W=<scratchpad>/<repo>-pr<N>
git -C $R fetch -q origin <base-branch> pull/<N>/head:pr<N>-review
git -C $R worktree add -q $W pr<N>-review
git -C $W merge-base origin/<base-branch> pr<N>-review
```

Get the base branch and head SHA from `gh pr view <N> -R <owner/repo> --json baseRefName,headRefOid,files`.

## 2. Check CI

If CI passed on the head SHA, don't run tests, linters or type checkers: they pass. `gh pr checks` can fail on the fine-grained PAT, so try `gh api repos/<owner>/<repo>/commits/<sha>/check-runs --jq '.check_runs[] | [.name,.conclusion] | @tsv'`. If CI failed, or its state can't be read, say so in the report, and the reviewers may run targeted tests in a scratch venv.

## 3. Scout inline

Before the workflow, build enough of a picture to write a good brief:

- `git -C $W diff -M30% --stat=200 <base> <head>`: renames and splits show up as moves.
- `git -C $W log --oneline <base>..<head>`: the commits (useful for isolating changes, but don't take their messages as truth).
- Find the live entry points: Dockerfile, entrypoint, CI and infra that run the code. Read them.
- For anything deleted or renamed that something outside the repo could call (scripts, modules, env vars, job names), run `gh search code "<name>" --owner <org>`. Note what you rule out.
- Separate the doc and markdown files from the code; they go to the last phase only.

## 4. Run the workflow

Split the code into 4-7 areas that can be reviewed independently: for example, a big file split, models and serialisation, pipeline wiring and entry points, a subsystem, logging and observability, tests and CI. Each area's prompt names its files (old and new paths) and the specific questions worth answering, such as "diff every moved function body" or "compare the ordered step list before and after".

```
Workflow({
  scriptPath: "/home/<user>/.claude/skills/pr-review/review-workflow.js",   // absolute path
  args: {
    repo: "owner/name", pr: 1234,
    worktree: "<W>", base: "<merge-base sha>", head: "pr1234-review",
    context: "<what the PR does, live entry points, what you already ruled out>",
    ciPassed: true,
    docPaths: ["README.md", "..."],
    areas: [{ key: "models", prompt: "..." }, ...]
  }
})
```

The script runs one reviewer per area, piped straight into a skeptic that tries to refute that area's findings, including by reading out-of-repo consumers. It then runs one agent that compares the PR description and changed docs against the verified result. That agent reports only substantive disagreements: places where trusting the description would mislead someone about what ships. It doesn't report missed renames, wording, or details that aren't mentioned.

While it runs, tell the user briefly what is happening and end the turn.

## 5. Report

Read the result (the journal file if the summary is truncated). Write:

- **Verdict up front**: blocking or not, and what you ran or relied on (CI passed, or the tests you ran).
- **What changed**: the restructure in a few bullets, then a numbered list of **live behaviour changes**, each with file:line.
- **Findings**: confirmed and plausible ones, most severe first, each with a concrete consequence. Drop the refuted ones, but name any notable claim that was refuted so the user knows it was checked.
- **Description & docs**: one line if they broadly agree, else the substantive disagreements.

Don't post anything to the PR unless asked.

## 6. Clean up

```
git -C $R worktree remove --force $W && git -C $R branch -D pr<N>-review
```
