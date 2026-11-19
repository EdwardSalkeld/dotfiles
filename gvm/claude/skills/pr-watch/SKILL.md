---
name: pr-watch
description: Watch a GitHub pull request for reviews, comments, failed checks, merge-queue removals and merge/close, via Gaston's webhook feed (mouette). Use instead of T3's watch_pull_request, which stops after ~16 minutes with a fine-grained PAT (pingdotgg/t3code#22966).
---

# Watching a pull request

`pr-wait` blocks until the PR has something to act on, prints it, and exits. It reads GitHub webhooks from Gaston's Prunelle feed through `mouette`, so it needs no GitHub API calls and isn't affected by what the token can read.

## Arm it

Run it as a **background** Bash command with the 2-hour timeout. Don't run it in the foreground, under Monitor or in a loop:

```
Bash(command: "~/.claude/skills/pr-watch/pr-wait brightnetwork/bright-apply#1234",
     run_in_background: true, timeout: 7200000)
```

Then end your turn. You are re-invoked when it exits. It accepts `owner/repo#N` or a PR URL.

## When it wakes you

It prints one line per event, after 20 quiet seconds so a burst (a review plus its inline comments) arrives together:

- `review <state> by <login>`: a submitted review, with its body.
- `inline comment by <login> on <path>`: a review comment.
- `comment by <login>`: a top-level comment. `(you)` marks Ed's own, which are usually instructions.
- `check failure|timed_out|…: <name>`: a failed check run.
- `removed from merge queue: <reason>`.
- `PR merged|closed`: stop watching. Don't re-arm.
- `no activity … in 110m`: nothing happened. Re-arm.
- `the mouette stream … ended unexpectedly`: check the PR with `gh` yourself, then re-arm.

The output is a pointer, not the whole story: snippets are cut at 200 characters. Read the full reviews and comments with `gh api` before acting.

After acting (pushing fixes, replying on threads), **re-arm it**. Each PR keeps a cursor in `~/.local/state/pr-wait/`, so events that arrived while you were working come out straight away. Your own reviews and thread replies never wake it.

Left out on purpose: passing checks, check runs starting, Linear and Depot success comments, and pushes.

## Options

- `--settle S`: seconds of quiet to wait after the first event (default 20).
- `--max-minutes M`: give up quietly after M minutes (default 110, under the 2-hour background limit).
- `--reset`: drop the cursor and only report events from now on.
