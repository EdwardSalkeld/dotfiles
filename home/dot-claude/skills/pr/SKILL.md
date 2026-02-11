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
2. Draft a **single-sentence title** (under 72 chars) that says what the change does.
3. Draft a **short description** — lead with the **why** in plain, human language (the motivation, not the implementation), then optionally a second sentence on the how. Only use bullet lists if the change is genuinely multifaceted. No testing notes, no co-author lines.
4. If args were passed (e.g. a Linear issue ID), include a link to it in the description.
5. Push the branch if needed, then create the PR:

```
gh pr create --draft --title "<title>" --body "<body>"
```

Return the PR URL when done.
