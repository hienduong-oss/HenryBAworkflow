# BA Start Step - Intake

## Checkpoint

Write `plans/{slug}-{date}/_checkpoint.md` as the **first action** before reading any artifact:
```
step: intake
status: running
command: <exact invoked command>
started: <ISO timestamp>
updated: <ISO timestamp>
```
On complete, update `status: completed` and `updated`.
This step requires:

- `core/contract.yaml`
- `core/contract-behavior.md`

## Memory Read Scope

- **Must read:** `core/contract.yaml`, `core/contract-behavior.md`
- **May read:** `paths.project_memory` (compact summary only, when exists)
- **Must NOT read:** memory shards (`hot/`, `warm/`, `cold/`), `log.md`, `paths.memory_index`

## Scope

Run Steps 0-4 only. Step 0 detects prior `/ba-presale` work and branches accordingly.

## Prerequisites

- Requires raw input as a file path or pasted text — unless `/ba-presale` already ran (Step 0 detects and skips input prompt).
- If no input argument is provided and no presale artifacts are detected, prompt the user for either a file path or pasted text.
- `--slug <slug>` may override the derived project slug.

## Step 0 - Detect prior presale work

Before prompting the user, check whether `/ba-presale` already produced artifacts for this project. This prevents re-asking questions the user already answered during presale clarify.

Detection signals (resolve `{slug}-{date}` first, then check):

| Signal | Path | Meaning |
|--------|------|---------|
| `intake_done` | `01_intake/intake.md` exists | Full handoff ran — intake already composed |
| `handoff_sources` | `01_intake/_sources/` exists | Presale handoff mirrored analysis artifacts |
| `proposal_locked` | `00_presale/20-proposal-content.md` exists | Proposal authored — scope is fixed |
| `clarifications_done` | `00_presale/05-clarifications.md` exists with ≥1 `Status=Answered` row | Clarifying questions already asked + answered |
| `domain_primer` | `00_presale/00-domain-primer.md` exists | Domain context captured |
| `raw_inputs` | `00_inputs/` has ≥1 file | Raw inputs already in shared store |

Branch table:

| State | Condition | Action |
|-------|-----------|--------|
| **A. Full presale + handoff** | `intake_done` = true | Skip Steps 1–4. Verify `intake.md` freshness (mtime newer than any `00_inputs/` or `00_presale/*.md`). If stale, re-run Step 2 only (re-parse). Then jump to Step 4.1. |
| **B. Presale analysis done, handoff not run** | `proposal_locked` AND `clarifications_done` AND NOT `intake_done` | Skip Steps 1, 3, 4 (asking). Run Step 2 to compose `intake.md` from presale artifacts + `00_inputs/` (same logic as `/ba-presale handoff` Step 4). Then Step 4.1. |
| **C. Partial presale (clarify done, no proposal)** | `clarifications_done` AND NOT `proposal_locked` | Skip Step 1 (raw already in `00_inputs/`). Run Step 2 normally. Skip Step 4 questions already covered by Answered clarifications; only ask gaps NOT addressed. Then Step 4.1. |
| **D. No presale** | None of above | Run all Steps 1–4 as normal (ask user for input, gap analysis, clarifying questions). |

Print a 2-line summary to the user after detection:

```
Prior work detected: {A|B|C|D} — {short reason}
Plan: {skip N steps | run full intake | run partial intake}
```

For branches A, B, C: do NOT re-ask for the raw input. Use what's already in `00_inputs/` and the presale artifacts.

## Step 1 - Accept input (branch D only)

Ask the user to provide one of:

- A file path (PDF, MD, TXT, image, DOCX)
- Pasted text containing requirements or business context

File reading approach:

- PDF: prefer `ba-kit source-extract <file>` first, then read the cached summary, `chunk-index.md`, and only the relevant chunks
- Markdown or text over 20 KB: run `ba-kit source-extract <file>` first; do not read the raw file directly
- Markdown or text up to 20 KB: may read directly, but prefer source cache when the file is likely to be reused
- Pasted text over roughly 8 KB: stage it as a source file and run `ba-kit source-extract` before normalization
- Images: use multimodal reading
- Word (`.docx`): use multimodal extraction or ask the user to export to PDF or Markdown first

If a staged source cache already exists under `plans/_source-cache/{source_hash}`, reuse it instead of re-reading the raw source.

## Step 1.5 - Persist raw input to shared store

Before parsing, persist the raw input into the shared raw-input store at `paths.raw_inputs` (= `plans/{slug}-{date}/00_inputs/`). This is the same store used by `/ba-presale` — both flows read/write here so no duplication.

Behavior:

- If the user provided a **file path**:
  - Classify by filename keywords (same rules as `/ba-presale` bootstrap Step 4):
    - rfp, scope, brief, business, requirement, spec, sow → `00_inputs/requirements/`
    - meeting, note, email, chat, call, transcript, summary → `00_inputs/discussions/`
    - api, schema, payload, erd, sequence, swagger, openapi, postman, sample → `00_inputs/technical/`
    - otherwise → `00_inputs/references/`
  - **Copy** (not move — user's original file stays put) into the classified subfolder.
  - Skip if an identically named file already exists under `00_inputs/` (idempotent).
- If the user **pasted text**:
  - Write the pasted text to `00_inputs/requirements/_initial-prompt.md` (append a timestamped block if the file exists).
- Create `00_inputs/{requirements,discussions,technical,references}/` if missing.
- **Never modify** the content of copied files.

Skip this step entirely if `00_inputs/` was populated by a prior `/ba-presale` run and the user's input is already reflected there (check file hash or name match).

## Step 2 - Parse and normalize

Source selection depends on the branch detected in Step 0:

- **Branch A** (`intake.md` already fresh): skip this step. Go directly to Step 4.1.
- **Branch B** (presale done, no handoff): compose `intake.md` directly from `00_presale/` artifacts + `00_inputs/` — same template-fill logic as `/ba-presale handoff` Step 4 (Goals from Proposal §1, Stakeholders from Proposal §9.2 + discussions, Scope from WBS phases + Proposal §7, Clarified points from Answered rows in `05-clarifications.md`, Open questions from Draft/Skipped rows). Every fact carries `[src:...]` ref.
- **Branch C** (partial presale): compose `intake.md` from `00_inputs/` + `00_presale/00-domain-primer.md` + Answered rows in `05-clarifications.md`. Missing sections filled via Step 3/4.
- **Branch D** (no presale): read the raw source material directly.

Read the source material and extract content into `~/.claude/templates/intake-form-template.md` (fallback: [../../../templates/intake-form-template.md](../../../templates/intake-form-template.md)):

- Project name, date, requester
- Business context (problem, goals, stakeholders mentioned)
- Raw requirements (extracted verbatim)
- Screens or UI mentioned
- Processes or workflows mentioned
- Constraints, assumptions, compliance needs
- Open questions identified during parsing

When a staged source cache exists:

- read `summary.md` first
- read `chunk-index.md` before selecting chunk files
- open only the relevant chunk files for the current normalization pass
- avoid dumping the entire raw source into context when normalized excerpts are enough

Save to `paths.intake`.

## Step 3 — Gap Analysis (skip for branch A, B; partial for branch C)

For **branch D** (no presale): run full gap analysis below.
For **branch C** (partial presale): run gap analysis BUT exclude categories already covered by Answered clarification rows in `05-clarifications.md`. Only flag genuinely new gaps.
For **branch A, B**: skip entirely — gaps already resolved via presale clarify + proposal.

Review the normalized intake against a BA completeness checklist across 8 categories (Stakeholders, Scope, Success Criteria, Compliance, UI/UX, Business Process, Technical/Integration, Commercial):

- Are stakeholders identified with roles and influence?
- Is there a clear problem statement and measurable goal?
- Are scope boundaries defined (in-scope vs out-of-scope)?
- Are success criteria or KPIs stated?
- Are compliance or regulatory obligations mentioned?
- Are UI screens described enough to prepare mandatory ASCII wireframes?
- Are processes described enough to map?

## Step 4 - Ask clarifying questions and lock scope (skip for branch A, B; partial for branch C)

For **branch A, B**: skip — scope already locked by presale WBS + Proposal.
For **branch C**: only ask questions for gaps NOT already covered by Answered clarifications. Merge presale answers into intake form as clarified points.
For **branch D**: run full clarification pass below.

Present the identified gaps to the user as 3-8 targeted questions. Focus on:

- Output language
- Missing stakeholders or decision makers
- Ambiguous scope boundaries
- Unstated success criteria
- Regulatory or compliance context
- Priority and sequencing preferences
- Engagement mode preference only when the user already knows it; otherwise default to `defaults.mode`

Incorporate the answers back into the intake form.

## Step 4.1 - Recommend direct backbone or optioning

After scope lock, evaluate whether the intake should:

- go direct to `backbone`
- recommend `options`
- strongly recommend `options`

Use the canonical optioning lifecycle statuses `recommended | in-progress | completed | skipped | not-needed`.
Keep `recommend` versus `strongly recommend` in the recommendation summary only; do not create extra status values.

The recommendation must cite signals:

- multiple plausible solution directions
- unresolved solution shape
- meaningful trade-offs across effort, value, and difficulty
- portal/module partitioning ambiguity
- stakeholder decision need

Write `paths.plan` as a decision ledger skeleton with:

- options status: `not-needed` or `recommended`
- recommendation summary, including whether optioning is merely recommended or strongly recommended
- expected next command: `backbone` when status is `not-needed`, otherwise `options`

Also create or refresh `paths.project_home` using `~/.claude/templates/project-home-template.md` (fallback: [../../../templates/project-home-template.md](../../../templates/project-home-template.md)).

Project Home rules:

- write it in Vietnamese unless the user explicitly requested English
- translate technical command names into BA-facing labels using the terminology matrix in `core/contract-behavior.md`
- replace internal terms (`source of truth`, `decision ledger`, `artifact gate`, `canon`, `compile receipt`, `index`) with the approved Vietnamese labels from the wording-layer policy
- show the current lifecycle state, the recommended next step, and decisions the user must make
- include runtime-specific quick prompts for Claude Code, Codex, and Antigravity
- do not treat Project Home as source of truth; it is a navigation dashboard over the contract artifacts

Deliverable selection:

- Always after scope lock: requirements backbone
- Detailed functional spec needed: FRD
- Agile team needs stories: user stories
- System spec with screens, use cases, or test cases: SRS
- UI screens mentioned: prepare `DESIGN.md` plus module-level screen canon ASCII

Mode defaults:

- `lite`: intake + backbone + user stories by default; emit more only on explicit request
- `hybrid`: intake + backbone + user stories, plus targeted FRD/SRS slices when risk or handoff needs justify them
- `formal`: full artifact suite
