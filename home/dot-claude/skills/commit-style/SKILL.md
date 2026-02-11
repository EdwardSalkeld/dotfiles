---
name: commit-style
description: Commit message style preferences. Applied automatically when creating git commits.
---

# Commit Style

## Message format

- Prefer a single-line message
- Sentence case (capitalise first word, not every word)
- No conventional commit prefixes (`fix:`, `chore:`, `feat:`, etc.)
- No co-authored-by or co-credit lines

## Length and detail

- Keep it succinct and clear over verbose
- Large commits can have a longer message but focus on the **why** — context you wouldn't get from reading the diff
- Do not list what changed; the diff already shows that

## Examples

Good:
```
Add ADOT collector sidecar to ECS task definitions
```

```
Propagate trace context through SQS messages

Without this, worker traces are disconnected from the web
request that enqueued them.
```

Bad:
```
fix: add tracing support

- Added @opentelemetry/sdk-node dependency
- Created src/lib/tracing.ts
- Modified src/server.tsx to call initTracing()
- Modified src/start-worker.ts to call initTracing()
- Updated package.json

Co-Authored-By: Claude <noreply@anthropic.com>
```
