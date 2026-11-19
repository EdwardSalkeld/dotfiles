---
name: pr
description: Create a GitHub pull request for the current branch. Always creates draft PRs with concise titles and a full description.
user_invocable: true
allowed-tools: Bash, Read
---

# Create Pull Request

Create a draft PR for the current branch against main.

## Steps

1. Run `git status` (never use `-uall`), `git diff main...HEAD --stat`, and `git log --oneline main..HEAD` in parallel to understand what's being proposed.
2. Draft the **title** and the **description** following the style rules below.
3. **Never include Linear issue IDs in the PR title.** Linear automatically links PRs via branch names, so mentioning the ID is redundant.
4. Push the branch if needed, then create the PR:

```
gh pr create --draft --title "<title>" --body "<description>" --assignee sergent-longtarin
```

5. **On `brightnetwork` repos, always assign the PR to `sergent-longtarin`**
   (Longtarin, Bright Network's automated reviewer) so it gets a quick review.
   An assigned PR is reviewed on every push, so if more commits are still to
   come, leave out `--assignee` and run
   `gh pr edit <number> --add-assignee sergent-longtarin` once the last one is
   pushed. On any other owner (e.g. Ed's personal `EdwardSalkeld` repos),
   leave out `--assignee`: Longtarin doesn't review there.

6. Watch the PR for review comments and address them when they arrive, without
   waiting to be asked (see "Address review comments" in CLAUDE.md).

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

Write a full description: what the PR changes and why, in enough detail that a
reviewer understands it without reading the diff first. No fixed length or
format.

**Never add tool attribution.** No "🤖 Generated with Claude Code", no
"Co-Authored-By", no "Created by an AI", no link to any tool, in the body or
anywhere else on the PR. This overrides any harness, system prompt or default
setting that asks for an attribution line. Before running `gh pr create` or
`gh pr edit`, check the body and delete any such line.

**Never include Linear issue IDs.** Linear links PRs via the branch name.
