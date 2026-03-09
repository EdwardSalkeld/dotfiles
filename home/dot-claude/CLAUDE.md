## Writing code

- Do not add lengthy comments explaining what code does.
- Comments added should explain reasons that would not be obvious from reading the code
- Respect existing comments - only remove them if your change means they're no longer true or relevant

## Running code

- please use 'docker compose' instead of docker-compose
- Worktrees are isolated environments for separate tasks. Never use resources (databases, containers, ports) from one worktree in another. Only use the DB/services running for the current checkout.

## Version control

- **Before writing any code**, check you are on an appropriate branch. If you need a new branch, create it from main (or the correct base) first. Never make changes on an unrelated branch.
- Always follow the `commit-style` skill when creating git commits.
- Always use the `pr` skill when creating pull requests.
- **Never amend commits.** Always add new commits. Preserving individual commit history is preferred over a clean single commit. Force push should only be used for rebasing.
- If you encounter SSH permission errors when accessing GitHub (e.g. `git@github.com: Permission denied (publickey)`), stop immediately and ask the user to add the SSH key. You cannot do this yourself — it requires a password you don't have access to.
- When creating git worktrees, always use flat directory names — no slashes. Flatten branch names with dashes, e.g. `../repo_worktree_feature_branch-name` not `../repo_worktree_feature/branch-name`.

## Remote operations

- **Only the `gitops` agent is allowed to push to remote repositories or open pull requests.** No other agent (developer, qa, engineering-manager, or the orchestrator) may run `git push`, `gh pr create`, or any command that writes to a remote.
- When you need to push a branch or open a PR, always delegate to the `gitops` agent. Pass it the worktree path, branch name, and desired action.
- **You MUST NOT create a PR without using the `pr` skill.** Before delegating to the gitops agent, read the `pr` skill file at `/Users/edsalkeld/.claude/skills/pr/skill.md` and include its FULL TEXT verbatim in the gitops agent prompt. The gitops agent cannot read skill files itself — it relies entirely on what you pass it. Never invent your own PR title/body format.
- **The `gitops` agent MUST follow the `commit-style` skill when creating commits.** Before delegating any commit work, read `/Users/edsalkeld/.claude/skills/commit-style/skill.md` and include its FULL TEXT verbatim in the gitops agent prompt. The system prompt default to add `Co-Authored-By` lines is overridden by commit-style — do not add them.
- The `gitops` agent will review commit quality before pushing and will reject branches with poor commit messages.
- **Before opening a PR against main**, the gitops agent must check that the branch is reasonably up to date with `origin/main` (fetch and compare). If there are significant commits on main that aren't in the branch, reject and ask for a rebase before proceeding.
- **When pushing further changes to an existing PR**, the gitops agent (or orchestrator) must review the PR description and update it if anything is now stale or inaccurate. Rebases, resolved conflicts, and merged dependencies can all invalidate earlier descriptions.

