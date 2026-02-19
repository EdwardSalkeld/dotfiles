## Writing code

- Do not add lengthy comments explaining what code does.
- Comments added should explain reasons that would not be obvious from reading the code
- Respect existing comments - only remove them if your change means they're no longer true or relevant

## Running code

- please use 'docker compose' instead of docker-compose
- Worktrees are isolated environments for separate tasks. Never use resources (databases, containers, ports) from one worktree in another. Only use the DB/services running for the current checkout.

## Version control

- Always follow the `commit-style` skill when creating git commits.
- Always use the `pr` skill when creating pull requests.
- If you encounter SSH permission errors when accessing GitHub (e.g. `git@github.com: Permission denied (publickey)`), stop immediately and ask the user to add the SSH key. You cannot do this yourself — it requires a password you don't have access to.
- When creating git worktrees, always use flat directory names — no slashes. Flatten branch names with dashes, e.g. `../repo_worktree_feature_branch-name` not `../repo_worktree_feature/branch-name`.

## Remote operations

- **Only the `gitops` agent is allowed to push to remote repositories or open pull requests.** No other agent (developer, qa, engineering-manager, or the orchestrator) may run `git push`, `gh pr create`, or any command that writes to a remote.
- When you need to push a branch or open a PR, always delegate to the `gitops` agent. Pass it the worktree path, branch name, and desired action.
- The `gitops` agent will review commit quality before pushing and will reject branches with poor commit messages.

