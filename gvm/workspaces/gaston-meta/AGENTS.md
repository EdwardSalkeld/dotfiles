# Gaston workspace

- `gaston/`: the code. Bun workspace with `protocol/`, `gvm/` (shared CLIs, skills,
  local VM provisioning), `gaston/` (runner), `fantasio/` (control plane, Prunelle),
  `longtarin/` (PR reviewer) and `infra/` (terraform).
- `tech-gaston/`: Gaston's configuration: runner machines and accounts, sops/age
  encrypted secrets (`.enc.*`), skills, control-plane routing config.

Changes that cross both: a new tool, skill or MCP server that needs a secret or
machine config, new runner settings, control-plane routing. Never decrypt secrets
into tracked files or print them; edit encrypted files with `sops`. Code that reads
new config should handle it being absent until tech-gaston is synced to the machines.

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
