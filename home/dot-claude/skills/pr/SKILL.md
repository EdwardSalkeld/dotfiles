---
name: pr
description: Create a GitHub pull request for the current branch. Always creates draft PRs with concise titles and descriptions.
user_invocable: true
allowed-tools: Bash, Read
---

# Create Pull Request

Create a draft PR for the current branch against main.

## Steps

1. Run `git status` (never use `-uall`), `git diff main...HEAD --stat`, and `git log --oneline main..HEAD` in parallel to understand what's being proposed.
2. Draft the title and description following the style rules below.
3. **Never include Linear issue IDs in the PR title or description.** Linear automatically links PRs via branch names, so mentioning the ID is redundant.
4. If args were passed (e.g. a Linear issue ID), include a link in the description only if it is NOT already in the branch name.
5. Push the branch if needed, then create the PR:

```
gh pr create --draft --title "<title>" --body "<body>"
```

Return the PR URL when done.

## Title

- Sentence case. Start with a verb or noun.
- Describe the **what**, concretely. Name the thing being changed.
- Under 72 characters. Specific enough to be useful without opening the PR.
- No conventional-commit prefixes (`feat:`, `fix:`, `chore:`).
- No ticket/issue references.
- OK to say "WIP" when genuinely work-in-progress.
- Reverts quote the original title: `Revert "Enable Authenticated Origin Pulls"`.

Good: `Fix cross-account S3 uploads so staging can read anonymised data`
Good: `Persist job recommendations cache to database`
Bad: `feat: add tracing`
Bad: `[EMP-123] Implement feature`

## Description

### Lead with why

The title says what. The body explains **why** this change exists and **why it works this way**. Jump straight in — no "## Summary", no "This PR does X".

> `Old recommendations are pointless. So let them drop out of the cache.`

> `The Drizzle connection pool stays open after anonymisation, so deleting the temporary RDS instance crashes the process.`

### Keep it short

1–3 sentences is the norm. A paragraph at most. Only go longer when the context genuinely demands it (multi-step infra, data model design, tricky sequencing).

### Explain the mechanism when non-obvious

If the fix has a trick to it, explain briefly. Don't assume the reviewer knows the internals.

> `S3 lifecycle rules can only filter on fixed key prefixes — so we tag snapshots with type=webcam-snapshot and expire tagged objects after 90 days.`

> `DB constraint forces email_opt_out=True to require all individual emails are false. But you can resubscribe to one without unsetting opt out, so the save fails.`

### Call out blast radius

State which environment is affected, whether it's been tested, how easy it is to roll back. Especially for infra.

> `No prod plan changes cause its all staging.`

> `Quick to rollback via AWS console.`

### Say what it does and doesn't do yet

When a PR is one step in a sequence, be explicit about scope.

> `Gets employer_url into the API. There's more to come to make it conditional in another PR.`

> `It won't start sending yet (there's a switch in the lambda code).`

### Reference related PRs

Use `#N` or `repo#N` shorthand for dependencies and sequences.

> `Depends on terraform-modules#80.`

> `Builds on #16332.`

### Be honest

Uncertainty, frustration, hackiness — say so. Credit AI tools when relevant.

> `This is Claude's best guess. It seems reasonable but I'm not optimistic.`

> `It's a bit nasty. The whole button wants some serious re-writing.`

### What to omit

- No `## Summary` / `## Test plan` / `## Changes` section headers
- No bullet-point changelogs restating the diff
- No co-authored-by lines
- No emoji
- No "Generated with" footers
- Empty body is fine when the title says everything

### Voice

Conversational and direct. First person. Talking to teammates, not writing docs.
