export const meta = {
  name: 'pr-review',
  description: 'Review a PR by area, adversarially verify each area, then check the PR description and docs against the verified result',
  phases: [
    { title: 'Review', detail: 'one reviewer per area of the diff' },
    { title: 'Verify', detail: 'one skeptic per area tries to refute its findings' },
    { title: 'Description & docs', detail: 'check the PR body and docs agree with the code' },
  ],
}

// args: {
//   repo: 'owner/name', pr: 1234,
//   worktree: '/abs/path', base: '<merge-base sha>', head: '<branch or sha>',
//   context: 'what the PR does, which entry points are live, what you already ruled out',
//   ciPassed: true | false,
//   docPaths: ['README.md', ...],   // changed docs/markdown, reviewed only in the last phase
//   areas: [{ key: 'short-slug', prompt: 'files and questions for this area' }, ...],
// }
const A = args

const CONTEXT = `You are reviewing GitHub PR ${A.repo}#${A.pr}.
A git worktree of the PR head is at ${A.worktree} (${A.head}). The merge base with the target branch is ${A.base}.
Use \`git -C ${A.worktree} diff -M30% ${A.base} ${A.head} -- <paths>\` for the diff, \`git -C ${A.worktree} show ${A.base}:<path>\` for old versions, and read files in the worktree for new versions. \`git -C ${A.worktree} log ${A.base}..${A.head}\` lists the commits; a single commit's diff can help isolate a change.
Scope: CODE ONLY. Ignore commit messages, the PR description and docs/markdown; they are checked separately later. Do not modify files, and do not post anything to GitHub.
${A.ciPassed ? 'CI has passed on this head commit, so do not run the test suite, linters or type checkers: we know they pass. Run a small snippet or targeted grep only when it settles a specific question.' : 'CI has not passed (or its state is unknown). Where it helps settle a finding, you may run targeted tests or linters in a scratch venv; never install into the worktree.'}

PR context: ${A.context}

Goal: (1) describe precisely what changed in your area, flagging every change in runtime behaviour on live code paths, as distinct from pure moves or removal of dead code; (2) find real defects: broken references, semantics changed by a move, removed branches that are still reachable, changed ordering, changed defaults, changed names or shapes that something else reads (log/event names, payload and file formats, storage keys, metrics), removed tests that covered live behaviour, tests patching paths where the name is no longer looked up. Cite file:line in the new tree and the old location. Report a finding only after checking it against the code. No style nits.`

const FINDINGS = {
  type: 'object',
  properties: {
    whatChanged: { type: 'array', items: { type: 'string' } },
    findings: { type: 'array', items: { type: 'object', properties: {
      title: { type: 'string' },
      file: { type: 'string' }, line: { type: 'integer' },
      severity: { type: 'string', enum: ['high', 'medium', 'low'] },
      detail: { type: 'string', description: 'What is wrong, old vs new evidence, concrete failure scenario' },
    }, required: ['title', 'file', 'severity', 'detail'] } },
  },
  required: ['whatChanged', 'findings'],
}

const VERDICTS = {
  type: 'object',
  properties: { verdicts: { type: 'array', items: { type: 'object', properties: {
    title: { type: 'string' },
    verdict: { type: 'string', enum: ['confirmed', 'plausible', 'refuted'] },
    reasoning: { type: 'string' },
    correctedDetail: { type: 'string' },
  }, required: ['title', 'verdict', 'reasoning'] } } },
  required: ['verdicts'],
}

const DOC_CHECK = {
  type: 'object',
  properties: {
    disagreements: { type: 'array', items: { type: 'object', properties: {
      source: { type: 'string', description: 'PR description, or the doc file path and line' },
      claim: { type: 'string' },
      reality: { type: 'string', description: 'What the code actually does, with file:line' },
      why_it_matters: { type: 'string' },
    }, required: ['source', 'claim', 'reality', 'why_it_matters'] } },
    summary: { type: 'string', description: 'One or two sentences: does the description broadly agree with the code?' },
  },
  required: ['disagreements', 'summary'],
}

const areas = await pipeline(
  A.areas,
  a => agent(`${CONTEXT}\n\nYour area: ${a.prompt}`, { label: `review:${a.key}`, phase: 'Review', schema: FINDINGS }),
  async (r, a) => {
    if (!r) return null
    if (!r.findings.length) return { area: a.key, ...r, verdicts: [] }
    const v = await agent(`${CONTEXT}\n\nAnother reviewer reported the findings below for area "${a.key}". Try to REFUTE each one by reading the code at the base and in the worktree, and by reading any out-of-repo consumer the finding depends on (search the org with \`gh search code\`). A finding is refuted if the path is unreachable in live use, behaviour did not actually change, the referenced name exists, the claim misreads the code, the consumer already handles it, or it is a nit. Mark confirmed only if you reproduced the reasoning yourself. Default to refuted when the evidence does not hold up.\n\nFindings:\n${JSON.stringify(r.findings, null, 2)}`, { label: `verify:${a.key}`, phase: 'Verify', schema: VERDICTS })
    return { area: a.key, ...r, verdicts: v ? v.verdicts : null }
  },
)
const reviewed = areas.filter(Boolean)
const dropped = A.areas.length - reviewed.length
if (dropped) log(`${dropped} area(s) returned nothing; their code is unreviewed`)

// Barrier on purpose: the description check needs the whole verified picture.
const verified = reviewed.map(r => {
  const v = Object.fromEntries((r.verdicts || []).map(x => [x.title, x]))
  return {
    area: r.area,
    whatChanged: r.whatChanged,
    findings: r.findings
      .map(f => ({ ...f, verdict: v[f.title]?.verdict ?? 'unverified', detail: v[f.title]?.correctedDetail || f.detail }))
      .filter(f => f.verdict !== 'refuted'),
  }
})

const docs = await agent(`You are checking whether the description and docs of PR ${A.repo}#${A.pr} agree with what the code actually does.
Read the PR description with \`gh pr view ${A.pr} -R ${A.repo} --json title,body\`. Read the changed docs in the worktree ${A.worktree} (diff against ${A.base}): ${JSON.stringify(A.docPaths || [])}.
Below is the verified account of what the code changed, produced by an independent code review. Treat it as the reference, but check the code yourself (worktree ${A.worktree}) before reporting any disagreement.

Report ONLY substantive disagreements: places where a reader who trusted the description or docs would misunderstand what ships or how the system behaves. Examples that count: the description says a change is a pure refactor or "removes dead code" but it changes live behaviour; it claims a guarantee, migration, rollout order or safety check that the code does not provide; docs describe a command, entry point, config, flag or flow that no longer exists or now works differently; a material change (new filter, changed data format, removed safeguard) is left out entirely.
Do NOT report: missing mentions of renames, file moves, refactors or minor details; wording or style; incomplete lists where the omission does not mislead; anything you would have to stretch to call misleading. An empty list is a good answer when they broadly agree.

Verified code changes:
${JSON.stringify(verified, null, 2)}`, { label: 'description-and-docs', phase: 'Description & docs', schema: DOC_CHECK })

return { areas: verified, docs }
