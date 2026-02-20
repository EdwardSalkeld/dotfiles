---
name: workflow
description: End-to-end ticket workflow — plan, develop, review. Takes a Linear ticket ID.
user_invocable: true
---

# Ticket Workflow

Run the full engineering workflow for a Linear ticket: plan, develop, QA.

The ticket ID is passed as an argument (e.g. `/workflow EMP-1234`).

## Linear MCP

**Only the orchestrator (you) talks to Linear.** Subagents never use Linear MCP.

Use `mcp__linear-server__*` tools (NOT `mcp__claude_ai_Linear__*` — those hang). Key tools:
- `mcp__linear-server__get_issue` — read ticket
- `mcp__linear-server__list_comments` — read comments
- `mcp__linear-server__create_comment` — post comments
- `mcp__linear-server__extract_images` — fetch images from markdown

## Orchestration Steps

### Phase 1: Planning

1. **Read the ticket** yourself using the Linear MCP. Extract: title, description, acceptance criteria, images, existing comments, and `gitBranchName`.
2. **Delegate to the engineering-manager subagent** (use Task tool with `subagent_type: general-purpose`, `model: opus`). Pass it:
   - The full ticket text (title, description, acceptance criteria — copy the text, not a ticket ID)
   - Any existing comments
   - The `gitBranchName` from the ticket
   - The current working directory as the repo root
3. When it returns, check for **unresolved questions**. If any, present them to the user with `AskUserQuestion` and relay answers by re-running the subagent.
4. **Post the plan** as a Linear comment on the ticket using `mcp__linear-server__create_comment`.
5. Capture: **worktree path**, **branch name**, **plan text**.

### Phase 2: Development

1. **Delegate to the developer subagent** (Task tool, `subagent_type: general-purpose`, `model: opus`). Pass it:
   - The full plan text (copy it — the subagent cannot read Linear)
   - The worktree absolute path
   - The branch name
2. When it returns, capture: **completion summary**, **deviations**, **concerns**.
3. **Post the handover summary** as a Linear comment.

### Phase 3: QA Review

1. **Delegate to the qa subagent** (Task tool, `subagent_type: general-purpose`, `model: opus`). Pass it:
   - The original ticket text
   - The plan text
   - The development handover summary
   - The worktree path and branch name
2. **If QA passes:** push the branch and create the PR by **delegating to the `gitops` agent**. You MUST NOT write a PR without using the `pr` skill. Read the `pr` skill file at `/Users/edsalkeld/.claude/skills/pr/skill.md` and include its FULL TEXT verbatim in your prompt to the gitops agent. The gitops agent must follow those rules exactly — do NOT invent your own PR title/body format, do NOT use `## Summary` / `## Test plan` headers, do NOT include testing notes. Then optionally watch CI checks with `gh pr checks --watch`. Capture the PR URL. Post a QA summary as a Linear comment. Done.
3. **If QA fails:** post the issues as a Linear comment. Relay the issue list to the developer subagent for fixes. Re-run QA. Max 3 rounds — then escalate to the user.

### Completion

Report to the user:
- PR URL
- Brief summary of what was done
- Any deviations or concerns worth noting

## Important

- **All Linear reads and writes happen here in the orchestrator.** Subagents receive and return plain text.
- Each subagent has its own context — pass all details explicitly as text.
- If SSH to GitHub fails with `Permission denied (publickey)`, stop and ask the user to add the SSH key.
- Use flat worktree directory names (dashes, no slashes).
- **Worktrees apply to ALL repos involved in a change**, not just the primary repo. If a ticket spans multiple repos (e.g. application code + infrastructure), create a worktree in each. Never commit directly on a main checkout.
- **You MUST NOT create a PR without using the `pr` skill.** Before delegating to the gitops agent, read `/Users/edsalkeld/.claude/skills/pr/skill.md` and include its full text in the gitops prompt. Never write your own PR format.
