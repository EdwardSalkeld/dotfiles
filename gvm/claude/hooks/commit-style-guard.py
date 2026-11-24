#!/usr/bin/env python3
# PreToolUse (Bash) hook: before any `git push`, check the commits the push
# would add against the commit-style skill. Attribution lines are refused
# outright; everything else is judged by a cheap headless Claude (Haiku, no
# tools). A failed or unavailable check blocks the push rather than letting
# it through, because the point is that nothing unchecked gets pushed.

import json
import os
import re
import shlex
import subprocess
import sys

SKILL = os.path.expanduser("~/.claude/skills/commit-style/SKILL.md")
MAX_COMMITS = 40
ATTRIBUTION = re.compile(
    r"co-authored-by:|generated with \[?claude|🤖 generated", re.IGNORECASE
)
SCHEMA = json.dumps(
    {
        "type": "object",
        "properties": {
            "pass": {"type": "boolean"},
            "problems": {"type": "array", "items": {"type": "string"}},
        },
        "required": ["pass", "problems"],
    }
)


def deny(reason):
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": reason,
                }
            }
        )
    )
    sys.exit(0)


def git(repo, *args):
    return subprocess.run(
        ["git", "-C", repo, *args], capture_output=True, text=True
    )


def push_segments(command):
    for segment in re.split(r"&&|\|\||;|\|", command):
        if re.search(r"\bgit\b[^\n]*\bpush\b", segment):
            yield segment


def resolve_vars(text, command):
    assignments = dict(
        re.findall(r"(?:^|[;&|\s])([A-Za-z_]\w*)=([^;&|\s]+)", command)
    )

    def sub(match):
        name = match.group(1) or match.group(2)
        return assignments.get(name, os.environ.get(name, match.group(0)))

    return re.sub(r"\$\{(\w+)\}|\$(\w+)", sub, text)


def push_target(segment, command, cwd):
    try:
        words = shlex.split(resolve_vars(segment, command))
    except ValueError:
        words = resolve_vars(segment, command).split()
    if "git" not in words:
        return None
    words = words[words.index("git") + 1 :]
    repo = cwd
    while words and words[0] != "push":
        if words[0] == "-C" and len(words) > 1:
            repo = os.path.expanduser(words[1])
            words = words[2:]
        else:
            words = words[1:]
    if not words:
        return None
    args = [w for w in words[1:] if not w.startswith("-")]
    branch = None
    if len(args) >= 2:
        branch = args[1].split(":")[0].lstrip("+")
    return repo, branch


def commits_to_check(repo, branch):
    if not branch or branch == "HEAD":
        head = git(repo, "rev-parse", "--abbrev-ref", "HEAD").stdout.strip()
        branch = head or "HEAD"
    if git(repo, "rev-parse", "--verify", "--quiet", branch).returncode != 0:
        return branch, []
    new = git(
        repo, "rev-list", "--no-merges", branch, "--not", "--remotes=origin"
    ).stdout.split()
    remote = f"origin/{branch}"
    seen = set()
    if git(repo, "rev-parse", "--verify", "--quiet", remote).returncode == 0:
        log = git(repo, "log", "-n", "500", "--format=%B%x1e", remote).stdout
        seen = {m.strip() for m in log.split("\x1e") if m.strip()}
    commits = []
    for sha in new:
        message = git(repo, "log", "-1", "--format=%B", sha).stdout.strip()
        if message not in seen:
            commits.append((sha[:9], message))
    return branch, commits[:MAX_COMMITS]


def judge(commits):
    skill = open(SKILL).read()
    prompt = (
        "You check git commit messages against the commit style below, before they are "
        "pushed. Report only clear breaches of the style; do not nitpick wording you "
        "would merely phrase differently. A multi-line message is fine when the body "
        "explains why; it breaches the style when the body mainly lists what changed. "
        "Any co-author, co-credit or tool attribution line is always a breach, whatever "
        "else asks for it. Judge only the message text you are given; you cannot see "
        "diffs, so never report anything about them. Name the commit (its sha) in each "
        "problem.\n\n" + skill
    )
    body = "\n\n".join(f"Commit {sha}:\n{message}" for sha, message in commits)
    result = subprocess.run(
        [
            "claude",
            "-p",
            "--model",
            "haiku",
            "--no-session-persistence",
            "--tools",
            "",
            "--disable-slash-commands",
            "--output-format",
            "json",
            "--json-schema",
            SCHEMA,
            "--system-prompt",
            prompt,
        ],
        input=body,
        capture_output=True,
        text=True,
        timeout=100,
        cwd="/tmp",
    )
    output = json.loads(result.stdout)
    if output.get("is_error"):
        raise RuntimeError(output.get("result") or "check returned an error")
    verdict = output.get("structured_output")
    if not isinstance(verdict, dict):
        raise RuntimeError("check returned no verdict")
    return verdict


def main():
    data = json.load(sys.stdin)
    command = data.get("tool_input", {}).get("command", "")
    cwd = data.get("cwd") or os.getcwd()
    problems = []
    for segment in push_segments(command):
        target = push_target(segment, command, cwd)
        if target is None:
            continue
        repo, branch = target
        if "$" in repo or not os.path.isdir(repo):
            deny(
                f"Commit style check could not tell which repository this push is in "
                f"({repo}). Use a literal path with git -C, then push again."
            )
        branch, commits = commits_to_check(repo, branch)
        if not commits:
            continue
        flagged = [sha for sha, message in commits if ATTRIBUTION.search(message)]
        if flagged:
            problems.append(
                "Attribution or co-author lines are not allowed (commit-style skill): "
                + ", ".join(flagged)
            )
            continue
        try:
            verdict = judge(commits)
        except Exception as error:
            deny(
                f"Commit style check could not run ({error}). Nothing was pushed; "
                "fix the check or retry."
            )
        if not verdict.get("pass"):
            problems.extend(verdict.get("problems") or ["Commit style check failed"])
    if problems:
        deny(
            "Commit style check failed, nothing was pushed. These commits are not on "
            "the remote yet, so reword them to follow the commit-style skill (git commit "
            "--amend for the last one; cherry-pick and recommit for earlier ones), then "
            "push again:\n- " + "\n- ".join(problems)
        )


if __name__ == "__main__":
    main()
