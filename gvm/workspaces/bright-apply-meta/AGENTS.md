# Bright Apply workspace

- `bright-apply/`: the Bright Apply app (TanStack Start, Postgres, SQS worker).
- `terraform-bright-apply/`: its AWS infrastructure (VPC, ECS, RDS, Redis, WAF, SQS, alarms).

Changes that cross both: new env vars or config, queues, CloudWatch metric filters
and alarms for `logProductMetric` counters (see `bright-apply/docs/PRODUCT_METRICS.md`),
WAF/CloudFront rules, maintenance mode. Infra changes usually have to deploy before
the app code that relies on them.

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
