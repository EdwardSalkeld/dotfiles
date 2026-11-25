## How this workspace works

This folder is not a git repo: it holds a clone of each repo above, and T3 treats it
as one project covering all of them. A worktree thread gets its own copy of this
folder with a git worktree of each repo you picked, on the thread's branch. Files
outside the repos (like this one) are links to the originals, so don't edit them.

- Each folder is a separate git repo. Commit, push and open PRs from inside it
  (`git -C <repo> ...`, `gh` run with `<repo>` as the working directory), one PR per repo.
- Before working in a repo, read its own `CLAUDE.md` / `AGENTS.md` and follow it.
- Rename a repo's branch to something descriptive before pushing, as you would in
  a single-repo session. The repos' branches don't need to match each other.
- When a change spans both repos, open both PRs and link each from the other's description.
- This file is rebuilt from `~/personal/dotfiles/gvm/workspaces/` on every `gvm up`;
  change it there.
- Never use another session's folders, databases, containers or ports.
