---
name: pr
description: Create a GitHub pull request for the current branch. Always creates draft PRs with concise titles and a fixed placeholder description (the author writes the real description).
user_invocable: true
allowed-tools: Bash, Read
---

# Create Pull Request

Create a draft PR for the current branch against main.

## Steps

1. Run `git status` (never use `-uall`), `git diff main...HEAD --stat`, and `git log --oneline main..HEAD` in parallel to understand what's being proposed.
2. Draft the **title** following the style rules below. Do NOT write a description — use the fixed placeholder (see Description).
3. **Never include Linear issue IDs in the PR title.** Linear automatically links PRs via branch names, so mentioning the ID is redundant.
4. Push the branch if needed, then create the PR with the placeholder body:

```
gh pr create --draft --title "<title>" --body "_Description to follow._"
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

**Never write a PR description.** Always create the PR with this exact placeholder body, verbatim:

```
_Description to follow._
```

The author rewrites every PR description themselves, so a drafted one is wasted effort. Do not summarise the change, explain the why, list commits, call out blast radius, or reference related PRs in the body — none of it. Just the placeholder. Put all your effort into the **title** instead (it's the only part that ships as-is).

If context genuinely needs to reach the author (e.g. "this depends on #123"), it goes in your report back to the caller, not in the PR body.

**Never flag or caveat the placeholder in your report back.** Leaving the body as `_Description to follow._` is the expected, correct outcome of this skill, not a gap or something skipped — do not mention it, apologize for it, or offer to write a real one. Report just the PR URL and title.
