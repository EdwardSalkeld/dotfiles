# Website workspace

- `website/`: the main Bright Network platform (brightnetwork.co.uk).
- `terraform-website/`: its infrastructure (ECS, RDS, Cognito, Batch).

Changes that cross both: new env vars or secrets, services and tasks, queues and
scheduled jobs, alarms. Infra changes usually have to deploy before the app code
that relies on them.

## How this workspace works

This folder is a meta repo: a tiny local git repo whose only job is to let T3 give
each session its own worktree. Each repo above sits in its own folder here, as a
git worktree of the clone in `~/workspace/<repo>`, on the same branch name as this
meta worktree. If a folder is missing, run `~/personal/dotfiles/gvm/workspaces/setup-worktree`.

- Each folder is a separate git repo. Commit, push and open PRs from inside it
  (`git -C <repo> ...`, `gh` run with `<repo>` as the working directory), one PR per repo.
- Before working in a repo, read its own `CLAUDE.md` / `AGENTS.md` and follow it.
- Rename a repo's branch to something descriptive before pushing, as you would in
  a single-repo session. The repos' branches don't need to match each other.
- When a change spans both repos, open both PRs and link each from the other's description.
- Don't commit in this meta repo. Its files come from
  `~/personal/dotfiles/gvm/workspaces/`; change them there.
- Never use another session's folders, databases, containers or ports.
