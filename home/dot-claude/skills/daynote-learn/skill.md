---
name: daynote-learn
description: Read daynotes from personal/notes and condense knowledge into work-brain journal and learning notes.
user_invocable: true
---

# Daynote Learn

Read daynotes and extract workstream context, decisions, and learnings into work-brain.

## Arguments

- `/daynote-learn` — last 7 days of daynotes
- `/daynote-learn 2 weeks` — custom timeframe
- `/daynote-learn 2026-03-10 2026-03-14` — explicit date range

## Steps

### 1. Determine timeframe and read daynotes

**Timeframe:** Default to 7 days back from today. Parse relative timeframes ("2 weeks", "1 month") into a start date.

**Find notes:** Glob for `daynotes/*.md` in `/Users/edsalkeld/personal/notes/`. Filter to files whose date prefix (`YYYYMMDD`) falls within the timeframe. **Exclude today's daynote** — it's always a work in progress. Read all matching notes.

### 2. Check what's already been captured

Read the tracking file at `/Users/edsalkeld/personal/work-brain/journal/daynote-learn-log.md`. This file records which daynote dates have been processed and when. If it doesn't exist, create it.

Skip dates that have already been processed **unless** the user explicitly re-requests them ("re-process", "again", etc.).

### 3. Identify workstreams and threads

Daynotes are daily todo lists grouped by workstream — typically a ticket (e.g. `EMP-3786`) or a topic (e.g. `Misc`, `Docs Tasks`). The same workstream appears across multiple days with tasks progressing (unchecked → checked).

For each workstream that appears in the timeframe:

1. **Track progress** — which tasks moved from `[ ]` to `[x]` across days? What new tasks appeared? What got dropped or deferred?
2. **Spot decisions** — look for tasks with annotations like "answer is no", or tasks that change shape between days.
3. **Spot context** — abbreviations, ticket IDs, people, tools, and systems mentioned.

### 4. Ask clarifying questions

If something in the notes is ambiguous or seems important but you can't tell what it means, **ask the user**. Good reasons to ask:

- An abbreviation or name you can't resolve (e.g. "AN-ML", "G meeting")
- A decision that was made but the reasoning isn't captured
- A workstream that suddenly appears or disappears without explanation
- Technical context needed to write a useful note (e.g. what "BA Anon batch env OS change" means)

**Batch questions together** — ask all your questions in one go, not one at a time.

**Important:** After getting answers, write them into work-brain immediately (as part of the relevant task or adhoc note). The goal is that you never need to ask the same question twice — if someone runs this skill again on overlapping dates, the answers should already be in work-brain.

### 5. Write work-brain notes

For each workstream with meaningful activity in the timeframe, create or update notes in work-brain:

#### Task notes (for ticket-referenced workstreams)

If the workstream references a ticket (e.g. `EMP-3786`):

1. Check if `journal/tasks/<ticket-id>.md` exists. Read it if so.
2. **Update** it with what happened during this timeframe — progress, decisions, blockers, context learned from questions.
3. **Create** it if it doesn't exist, using the standard task frontmatter.

When updating existing task notes, merge new information into the appropriate section. Don't just append a dated log — keep the note coherent as a reference document.

#### Adhoc notes (for non-ticket workstreams)

For workstreams without tickets that contain anything worth capturing:

1. Check if a relevant adhoc note already exists (search by topic).
2. Update or create as appropriate at `journal/adhoc/<YYYY-MM-DD-topic>.md`. Use the date the workstream first appeared in this processing batch.

#### Learning notes

If you spot reusable learnings (non-obvious behaviour, gotchas, useful patterns), create or update notes in `learning/`. Follow the same rules as the `/distill` skill — atomic, context-first, no fluff.

#### Repo knowledge notes

If daynotes reveal information about how a specific repo works, update `repos/<owner>-<repo>/<area>.md` as per the work-brain CLAUDE.md format.

### 6. Update tracking log

Append to `/Users/edsalkeld/personal/work-brain/journal/daynote-learn-log.md`:

```markdown
## YYYY-MM-DD (processing date)

Processed daynotes: 20260310, 20260311, 20260312, 20260313
Workstreams updated: EMP-3786, EMP-3788, LLM Resilience
Notes created/updated:
  - journal/tasks/EMP-3786.md (updated)
  - journal/adhoc/2026-03-10-llm-resilience.md (created)
```

### 7. Commit and push

Stage all changes in the work-brain repo. Commit following the `commit-style` skill. Push to origin.

Use `git -C /Users/edsalkeld/personal/work-brain` for git operations.

### 8. Report

Output a brief summary:
- How many daynotes were processed
- Which workstreams were identified
- Which notes were created or updated
- Any questions that remain unanswered (for the user to address next time)

## Important

- **Never modify daynotes.** The source notes in `personal/notes/daynotes/` are read-only. All output goes to work-brain.
- **Merge, don't replace.** Existing work-brain notes should be refined and extended, not overwritten.
- **Don't force it.** If a workstream is just a stale todo item with no progress, skip it. Only capture meaningful activity or context.
- **Persist answers.** When the user answers a clarifying question, write that answer into the relevant work-brain note immediately. This is critical — the whole point is building up context so the same questions don't need re-asking.
- **Recurring items are signal.** If a task appears unchecked across many days (e.g. "Tailscale chase Kaizen"), that's a deferred/blocked item — note it as such rather than ignoring it.
- **Daynotes are shorthand.** They're personal notes, not documentation. Expect abbreviations, incomplete sentences, and implicit context. Ask rather than guess.
