---
name: changes
description: Summarise recent changes merged across the brightnetwork GitHub org. Defaults to yesterday (Friday on Mondays).
user_invocable: true
allowed-tools: Bash, Read
---

# Summarise Recent Changes

Gather merged PRs across the `brightnetwork` GitHub org for a time period and produce a grouped summary.

## Arguments

An optional timeframe. Examples:

- `/changes` — yesterday (Friday if today is Monday)
- `/changes today` — today
- `/changes last week` — Monday to Friday of last week
- `/changes 2025-02-20` — that specific day
- `/changes 2025-02-17..2025-02-21` — date range

## Steps

### 1. Calculate date range

Work out the `merged:` date filter for the GitHub search API.

- No argument: use yesterday's date. If today is Monday, use last Friday.
- "today": today's date.
- "last week": Monday–Friday of the previous week.
- A single date: that date.
- A range (`YYYY-MM-DD..YYYY-MM-DD`): use as-is.

Express the range as a GitHub search qualifier: `merged:YYYY-MM-DD` (single day) or `merged:YYYY-MM-DD..YYYY-MM-DD` (range).

### 2. Fetch merged PRs

```bash
gh api search/issues --method GET --paginate \
  -f q="type:pr org:brightnetwork is:merged ${MERGED_FILTER} -author:app/dependabot -author:app/renovate" \
  -f per_page=100 \
  --jq '.items[] | {
    number: .number,
    title: .title,
    body: .body,
    repo: (.repository_url | split("/") | .[-1]),
    user: .user.login,
    url: .html_url
  }'
```

This excludes dependabot and renovate. Include all other authors (including bot accounts like `gaston-p9f`).

### 3. Fetch branch names for grouping

For each PR, fetch the branch name (which often contains a Linear ticket ID like `emp-1234`):

```bash
gh api repos/brightnetwork/{repo}/pulls/{number} --jq '.head.ref'
```

Run these in parallel batches to avoid being slow. If there are many PRs (>50), batch into groups of ~20.

### 4. Group and summarise

Group PRs intelligently:

- **By Linear ticket**: PRs whose branch names share a ticket ID (e.g. `emp-1234-frontend` and `emp-1234-terraform`) are part of the same change. Group them.
- **By theme**: PRs without ticket IDs but doing the same kind of thing across repos (e.g. "AWS provider v6 upgrade" in three terraform repos) should be grouped.
- **Dependabot/renovate are already excluded**, but if other automated PRs are obvious (e.g. "Sync X from Y"), note them briefly without detail.
- **Solo PRs** that don't fit a group stand alone.

### 5. Write the summary

Output a concise summary. For each group or standalone change:

- **One line** saying what changed and why. Summarise at the level someone would care about in a standup — not implementation details like constant names, exact thresholds, or specific field types. If the body adds useful *why* context beyond the title, use it; otherwise the title is enough.
- **Repos affected** in parentheses (e.g. `terraform-bright-apply#142`), if more than one.
- **No author names.** The audience already knows who works on what.

Keep it scannable. Bullet points, not headers. A group of related PRs gets one bullet with the PR refs listed together.

If the PR title and description aren't enough to understand a change, you may fetch the diff — but prefer not to.

### 6. Present

End with a count: "X changes across Y repos."
