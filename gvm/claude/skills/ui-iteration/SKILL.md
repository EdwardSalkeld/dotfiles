---
name: ui-iteration
description: Iteratively improve an existing UI with a design agent, parallel implementers and independent scored reviews, looping until every score reaches a target. Use when asked to improve, redesign or iterate on a UI/page/app, including "make it better", "review and fix the UI" or "iterate until it scores well".
---

# UI iteration loop

A fresh reviewer scores the current UI against a fixed rubric. That reviewer then designs the improvement, implementers build it, a fresh reviewer with the identical prompt scores the result, and a fixer acts on the review. This repeats until every score reaches the target or the round limit is hit. One reviewer prompt and one rubric run from baseline to the last round, so every score can be compared with every other. The output is better UI plus before and after screenshots.

## 1. Fix scope, target and rubric from the request, and only from the request

Scope, target and rubric are decided before any agent runs, and none of them change during the run.

### Scope

Scope decides everything downstream: what the designer may propose, what the rubric measures, what the implementers may touch, and which review notes the fixer may act on. Take it from what the user actually asked for. Never widen it because an agent thinks something would help.

Classify the request into tiers. Each tier includes the ones above it and is a much bigger job than the one before:

| Tier | Covers | Typically touches |
|---|---|---|
| **Visual** | typography, colour, spacing, icons, contrast, theme | CSS and tokens, component markup |
| **Usability** | layout, information architecture, density, navigation, scrolling, keyboard, URL state, responsive behaviour, loading/empty/error states | frontend components and routing |
| **Features (read)** | showing data the UI doesn't show yet | frontend, gateway/proxy routes, new read-only backend endpoints, fixtures |
| **Features (write)** | new actions the operator can take: replay, cancel, trigger, override | backend behaviour, new mutating endpoints, permissions |

Rules:

- "Make it look better" or "fix the design" is **Visual**, plus Usability only if the user mentions layout, navigation or usability. It is never Features.
- Features only come into scope when the user asks for them ("what more can we show", "add functionality"). Read features do not imply write features: each tier needs its own mandate.
- If the request is ambiguous between tiers, ask once before starting with AskUserQuestion, giving the tiers as options. Don't guess upward.
- Write the agreed scope into every agent prompt as a hard boundary, e.g. "Scope: Visual + Usability. Do not add endpoints, data or actions."
- Reviewers will suggest work outside scope; good reviewers always do. The fixer must **not** implement it. Report it to the user as "out of scope, needs your call", and implement it only after they say yes. In round 2 of the first run, a reviewer marked down the lack of write actions. That was a real gap, but it only went ahead once the user approved it.

### Target and stopping rule

Take these from the request as well:

- **Target:** e.g. "8 out of 10" means every dimension at least 8. A target on the total or the average is weaker, because one strong area can hide a weak one; apply it only if that's what the user said.
- **Round limit:** default 5.
- **Pause points:** e.g. "stop after the first review".

If no target is given, ask together with any scope question. If there's nothing else to ask, use "every dimension ≥ 8, no high-severity issues" and say so up front.

### Rubric

Build the rubric yourself from the scope: 6–10 dimensions, each scored 1–10 with a line saying what an 8 looks like. Choose dimensions only from the tiers in scope:

| Tier | Candidate dimensions |
|---|---|
| Visual | hierarchy & typography, colour & contrast (light and dark), visual consistency, accessibility |
| Usability | information density, navigation & usability (scrolling, keyboard, URL state), responsiveness/mobile, states & feedback |
| Features (read) | operator usefulness / feature completeness, plus one for the app's key view (e.g. live session fidelity) |
| Features (write) | actionability: can the operator fix the common problems from the UI? |

Dimensions from tiers outside scope are left out. Scoring a Visual job on feature completeness would push the loop into building features nobody asked for. Write the rubric to a file and show it to the user with the scope and target before the baseline review.

## 2. Baseline

1. Check out a working branch from the target (e.g. the PR branch). Don't commit to the PR branch itself.
2. Get the app running locally with realistic data. Sparse fixtures hide density and layout problems. If the data is too thin, enriching the fixtures is in scope for every tier because it is test data, but keep it behind a flag (e.g. `--rich`) so default behaviour doesn't change.
3. Write a reusable Playwright screenshot script in the scratchpad:
   - every route at desktop 1440x900, plus dark theme if the app has one, plus mobile 390 wide full page
   - print any route where `scrollWidth > clientWidth`
4. Take the **before** set now, before any code changes. Note which fixture it used: if the after set uses richer data, say so when presenting the comparison.
5. If several agents will run the app at once, give each one isolated ports and state, e.g. a `stack.sh restart <base-port>` helper. Watch for build outputs written into a shared directory (an embedded `dist/`, for example). Parallel agents should use the dev server against a running backend rather than each running a build.

## 3. Baseline review (round 0)

Run the reviewer from section 5, with the exact prompt every later round will use, against the before state. Its scores are the baseline. Because the same prompt and rubric score every round, any difference between rounds comes from the UI and not from a different judge or measure.

## 4. Design (the baseline reviewer)

Continue the baseline reviewer with SendMessage rather than starting a new designer. It has already used the app, measured it and scored it against the rubric, so its design starts from the same evidence. Send it:

- the agreed scope, stated as a boundary
- the user's goals in their words
- the repo path, and how to re-shoot

Ask it to write a spec file covering:

1. A critique, per page, ranked by severity, starting from its own review issues and measured where possible (row heights, contrast ratios, overflow widths).
2. Features, only if they are in scope. List each with its data source and a cost class: (a) frontend only, (b) a new proxy route to an existing endpoint, (c) a new backend endpoint plus its size.
3. A design system: fonts bundled locally, type scale, spacing, colour tokens for light and dark with contrast checked, status-to-colour map, icon rules, table style, density targets.
4. Layouts per page, with ASCII wireframes.
5. Usability rules: scrolling model, keyboard, URL state, loading/empty/error/stale states.
6. An ordered implementation plan, with the files each step touches, aimed at moving every dimension to the target.

It doesn't write a rubric, because the rubric is already fixed. If it ends early while its own sub-agents are still running, SendMessage it to finish and write the file.

The designer later reviewing its own work would be biased. That doesn't arise here, because every later round uses a fresh reviewer.

## 5. Implement (workflow)

When the user has opted into workflows (ultracode or an explicit ask), run implementation as a Workflow. Otherwise use sequential Agent calls in the same shape:

1. **Foundation** runs in parallel, and each agent owns its own files:
   - **Frontend system** (tokens/theme/fonts, app shell, shared primitives, keyboard). It does every dependency install up front so no other agent touches `package.json`. It moves old page CSS into a legacy file so pages keep rendering.
   - **Backend + gateway**, only if a Features tier is in scope. It also owns the API types and hooks.
   - **Fixtures**, if the data needs enriching.
2. **Restack and commit**: rebuild, restart with rich data, commit the foundation in logical commits.
3. **Pages**: one agent per page group, each owning only its page files and its own stylesheet. Pass each one the foundation agents' summaries of the primitive APIs verbatim. They report gaps in the shared primitives rather than editing shared files.
4. **Integrate**: one agent that owns everything. It closes the primitive gaps, deletes dead legacy CSS, runs the full checks, re-shoots, fixes visual problems and commits. It reports remaining weaknesses honestly.

Every agent prompt states:

- the scope boundary
- the spec path (as the authority)
- the files that agent owns
- "do not git commit unless told to"
- its dev server port
- the check commands to run (typecheck, tests, formatter, plus backend tests and linters when it touches the backend)
- an instruction to look at its own screenshots before finishing

## 6. Review and fix loop

**Reviewer.** Use a fresh `model: fable` agent every round, built from one prompt template that is also used for the baseline in section 3. Only the screenshot folder changes between rounds. Give it:

- the user's brief and the scope
- the fixed rubric file
- the screenshot folder and the live URL, and a Playwright path for it to interact with the app: keyboard, palette, filters, details, live views, dark mode, phone width
- an instruction to measure rather than guess (contrast, row heights, nested scroll containers, overflow)
- no repo edits, scratch work only

Don't give it the spec, your conclusions or the earlier reviews. Use a structured schema: `scores[{dimension, score, justification}]`, `issues[{severity, page, problem, suggestion}]`, `summary`. It scores exactly the rubric's dimensions and may not add any. Anything else it thinks matters goes into `issues`, where it gets sorted into in scope or out of scope like any other issue. In the first run, reviewers who were allowed an extra dimension picked a different one in each round, so the totals couldn't be compared between rounds.

**Fixer.** One agent per round, owning all files. Give it:

- the scores and issues, and the history of earlier rounds
- the scope boundary, with an explicit "skip anything outside scope and list it"
- an instruction to fix every high and medium issue and the cheap low ones, to push back on factually wrong issues with reasons, and to put the lowest dimensions first

It then rebuilds, re-shoots to `round-N/`, leaves the app running for the next reviewer and commits.

**Stopping.** Stop when the target from section 1 is met and no high in-scope issues remain, or at the round limit. Honour pause points and later requests ("one more round") exactly. If the only thing holding a score down is out of scope, stop and ask the user rather than looping.

To change a running workflow:

1. Edit its persisted script.
2. Wait for the preceding step's `result` line in `journal.jsonl`.
3. `TaskStop` the run, then resume with `resumeFromRunId`.

Completed agents replay from the cache. To add instructions for later rounds only, put them behind a condition such as `${round >= 2 ? '…' : ''}` so earlier prompts are byte-identical and still hit the cache.

## 7. Report

After each pause or the end:

- A table of scores per dimension, from the baseline (round 0) through each round, against the target.
- The reviewer's high issues, and a short list of the mediums.
- What the fixer changed, and anything it pushed back on.
- Out-of-scope suggestions, as a decision for the user.
- Before and after images side by side. Use `ffmpeg … hstack`, cropping tall mobile pages from the top (`crop=iw:H:0:0`); the default crop is centred and cuts off the top of the page. Show a few inline and link the folder.
- The branch, commits and check results. Push or open a PR only when asked.

Keep a work-brain journal note updated with the scores per round and any gotchas.
