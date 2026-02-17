## Writing code

- Do not add lengthy comments explaining what code does.
- Comments added should explain reasons that would not be obvious from reading the code
- Respect existing comments - only remove them if your change means they're no longer true or relevant

## Running code

- please use 'docker compose' instead of docker-compose

## Version control

- Always follow the `commit-style` skill when creating git commits.
- Always use the `pr` skill when creating pull requests.
- If you encounter SSH permission errors when accessing GitHub (e.g. `git@github.com: Permission denied (publickey)`), stop immediately and ask the user to add the SSH key. You cannot do this yourself — it requires a password you don't have access to.
- When creating git worktrees, always use flat directory names — no slashes. Flatten branch names with dashes, e.g. `../repo_worktree_feature_branch-name` not `../repo_worktree_feature/branch-name`.

