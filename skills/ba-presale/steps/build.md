# BA Presale Step — Build (WBS + Proposal + Sync + Render)

Phase 3 of the presale lifecycle. Owner: `presale-lead` (orchestrator, **Opus** for sync arbitration). Dispatches `wbs-builder` and/or `proposal-writer` (both **Sonnet**) based on user selection, runs sync-check inline, then auto-renders.

Triggered by user command `/ba-presale build`. Never auto-advances from `clarify`.

This step requires:
- `plans/{slug}-{date}/00_presale/00-domain-primer.md`
- `plans/{slug}-{date}/00_presale/05-clarifications.md` (no minimum answer threshold — unanswered questions become assumptions)
- `templates/wbs-template.md`, `templates/wbs-template.csv`
- `templates/proposal-template.md`, `templates/proposal-guide.md`
- `templates/output-style-spec.json`
- `rules/ba-presale-standards.md` §3, §4, §5
- Skills: `document-skills:xlsx`, `document-skills:docx`

## Pre-run: Build Target Selection (MANDATORY)

Before any work, present a build target selection using `AskUserQuestion`. Do NOT assume "build all."

**Question:** "What would you like to build?"

**Options:**
1. **Build all** — WBS + Proposal + sync-check + render (both xlsx + docx)
2. **Proposal only** — Proposal markdown + docx render (skip WBS)
3. **WBS only** — WBS markdown + CSV + xlsx render (skip Proposal)

After user selects, print the pre-run description block reflecting the chosen target:

```
────────────────────────────────────────
🔵 /ba-presale build — {target description}
────────────────────────────────────────
Phase 3 — {target-specific summary}

Will:
  1. Pre-flight: confirm Domain Primer + clarifications exist
  2. {dispatch description based on target}
  3. {sync-check if both, skip if single}
  4. AUTO-RENDER {xlsx and/or docx based on target}

Outputs:
  {list only relevant outputs}

Language: English (artifacts are client-facing)
Next gate: USER GATE — review before /ba-presale handoff

Proceed? (reply 'ok' to start, or type a different command)
────────────────────────────────────────
```

Wait for `ok` before continuing.

## Step 1 — Pre-flight checks `[MECHANICAL]`

Boolean checks only — no LLM judgment needed. Block build if any check fails:

1. `00-domain-primer.md` exists.
2. `05-clarifications.md` exists. **No minimum answer threshold** — unanswered questions are carried forward as assumptions with `[src:assumption:A{n}]` refs in WBS/Proposal.
3. Templates exist at expected paths (only check templates relevant to the selected build target).
4. `_output/` directory exists (create if missing).

## Step 2 — Resolve Proposal variant `[JUDGMENT — Opus]`

Determine variant from Domain Primer + answered clarifications:
- **Variant A — Platform/Integration**: vendor-led, discovery-heavy, team-based quotation. Triggered by Tech category answers indicating vendor CIAM / SaaS adoption / heavy integration with established platforms.
- **Variant B — Custom-Build**: full WBS, fixed-price, phase-based modules. Default when scope is greenfield application development.

Record variant decision in state card (Step 6).

## Step 3 — Dispatch `[MECHANICAL]` (based on build target selection)

Dispatch sub-agents based on the user's build target selection from the pre-run step.

**MODEL ENFORCEMENT (CRITICAL):** All Agent calls MUST include explicit `model: "sonnet"` parameter. Do NOT let sub-agents inherit the lead's Opus model. See `presale.model_enforcement` in `contract.yaml`.

### Build target: "Build all" (default)

Dispatch both sub-agents in a single tool-call batch (parallel).

### Build target: "Proposal only"

Dispatch only `proposal-writer`. Skip WBS dispatch entirely. If `10-wbs-content.md` already exists from a prior build, Proposal can reference it for §7/§9 alignment. If not, Proposal stubs §7 and §9.

### Build target: "WBS only"

Dispatch only `wbs-builder`. Skip Proposal dispatch entirely.

### Packet A → `wbs-builder` (model: **sonnet**) — skip if "Proposal only"

```
objective: Author WBS markdown + CSV (English) from Domain Primer + answered clarifications.
target_md:  plans/{slug}-{date}/00_presale/10-wbs-content.md
target_csv: plans/{slug}-{date}/00_presale/10-wbs-content.csv
templates:
  - bakit/templates/wbs-template.md
  - bakit/templates/wbs-template.csv
inputs:
  - plans/{slug}-{date}/00_presale/00-domain-primer.md
  - plans/{slug}-{date}/00_presale/05-clarifications.md (Answered rows only)
  - 00_presale/00-inputs/  (read on demand)
language: English
source_ref_format: see rules/ba-presale-standards.md §5
write_scope: target_md + target_csv only
return_format: ~50-token summary (status, row counts, open flags)
tracker: 00_presale/_state-cards/03a-wbs.md
```

### Packet B → `proposal-writer` (model: **sonnet**) — skip if "WBS only"

```
objective: Author Proposal markdown (English) from Domain Primer + answered clarifications + WBS.
target:    plans/{slug}-{date}/00_presale/20-proposal-content.md
templates:
  - bakit/templates/proposal-template.md
  - bakit/templates/proposal-guide.md
variant:   {A_platform | B_custom}
inputs:
  - plans/{slug}-{date}/00_presale/00-domain-primer.md
  - plans/{slug}-{date}/00_presale/05-clarifications.md (Answered rows only)
  - plans/{slug}-{date}/00_presale/10-wbs-content.md  (may be in-flight; draft §1–§6, §8, §10–§11 first; stub §7, §9)
language: English
source_ref_format: see rules/ba-presale-standards.md §5
write_scope: target only
return_format: ~50-token summary (status, section coverage, flags)
tracker: 00_presale/_state-cards/03b-proposal.md
```

Both dispatched in PARALLEL via single message containing two Agent tool calls (when "Build all" selected).

## Step 4 — Sync-check `[JUDGMENT — Opus]` (lead, inline) — only when "Build all"

**Skip this step entirely if build target is "Proposal only" or "WBS only".** Sync-check only applies when both artifacts are built in the same run.

This is a true judgment point — the lead must read both artifacts, detect semantic conflicts, and anchor resolution to source priority. Opus is justified here.

After both sub-agents return, lead reads both artifacts in full and runs the check matrix:

| Check | WBS source | Proposal source | Action on mismatch |
|-------|------------|-----------------|--------------------|
| Phase rows | §2 (WBS table) | §7.1 (In-Scope) | Conflict |
| Effort totals | §3 (Phase summary) | §9 (WBS & Quotation) | Conflict |
| Deliverables | per WP description | §7.1 (In-Scope items) | Conflict |
| Exclusions | §5 (Exclusions) | §7.2 (Out-of-Scope) | Conflict |
| Timeline | sum effort vs §8 milestones | §8 (Master Schedule) | Conflict if infeasible |
| Assumptions | §4 (Assumptions) | §7.3 (Assumptions & Dependencies) | Conflict |
| Source refs | every row | every commitment | Block render if missing |

### Conflict resolution

For each conflict, anchor decision to source priority:
1. `00-inputs/` client raw
2. Answered clarification (`05-clarifications.md`)
3. Validated Domain Primer
4. Documented assumption (lowest)

Log each decision to `00_presale/_changelog/sync-{YYYYMMDD-HHmm}.md`. Dispatch surgical fix to relevant sub-agent (**model: sonnet** — single-section edit packet, mechanical dispatch). Re-run sync-check after fixes return. Loop until zero conflicts OR escalation needed.

### Escalation

If a conflict cannot be anchored to any source, STOP and present to user. Do NOT proceed to render.

## Step 5 — Auto-render `[MECHANICAL]` (no user prompt)

Deterministic: render only the artifacts that were built. No LLM judgment needed for the dispatch decision.

- **Build all:** render both xlsx + docx (after sync-check passes).
- **Proposal only:** render docx only.
- **WBS only:** render xlsx only.

After sync-check passes (or immediately after dispatch return for single-target builds):

### 5a — WBS xlsx

Invoke `document-skills:xlsx` with:
- Rows: parse `10-wbs-content.csv`
- Style: `templates/output-style-spec.json` `xlsx.sheets.WBS`
- Sheets in `10-wbs-final.xlsx`:
  - `WBS` — main table (from CSV)
  - `Clarifications` — parsed from `05-clarifications.md` table (Status colored)
  - `Summary` — phase totals (from WBS markdown §3)
  - `Assumptions` — from WBS markdown §4
- Apply: header colors, hierarchy levels (level_1 bold + fill), totals row, status_color_map for Clarifications, freeze panes B2

Output: `plans/{slug}-{date}/00_presale/_output/10-wbs-final.xlsx`

### 5b — Proposal docx

Invoke `document-skills:docx` with:
- Input: `20-proposal-content.md`
- Style: `templates/output-style-spec.json` `docx.*`
- Apply: cover page, heading_1/2/3 styles, table styling, header/footer with `{{client_name}}` / `{{project_name}}` substitution
- Watermark: only if `docx.watermark.show = true`

Output: `plans/{slug}-{date}/00_presale/_output/20-proposal-final.docx`

### Render block conditions `[MECHANICAL]`

Boolean checks — block render if any check fails:
- Any WBS row missing `[src:...]`
- Any Proposal commitment in §1.4, §7, §9 missing `[src:...]`
- Source CSV/MD files unreadable

On block, list offending rows/sections, do NOT render, return user to Step 4.

## Step 6 — State card `[MECHANICAL]`

Write `plans/{slug}-{date}/00_presale/_state-cards/03-build.md` (≤300 tokens, Vietnamese):
- variant chosen
- WBS row count, Proposal section count
- conflicts found / resolved / escalated
- changelog refs
- xlsx + docx output paths + sizes
- next gate: USER GATE (review then handoff)

## Step 7 — User Gate (MANDATORY)

Print to user (Vietnamese summary + English next-step cues):

```
✅ Build complete.

Tóm tắt (tiếng Việt):
  - Variant Proposal:  {A_platform | B_custom}
  - WBS:               {N} rows, {N} phases, total {effort} person-days
  - Proposal:          §1–§11 ({complete | partial})
  - Sync conflicts:    {found}/{resolved}/{escalated}

Files (English content, client-ready):
  📊 WBS xlsx:      plans/{slug}-{date}/00_presale/_output/10-wbs-final.xlsx
  📄 Proposal docx: plans/{slug}-{date}/00_presale/_output/20-proposal-final.docx

  Markdown sources (for surgical edits):
  - 10-wbs-content.md
  - 20-proposal-content.md

Bạn có thể:
  • Bare prompt (e.g., "WBS row 2.3 effort should be 5d not 3d")
      → agent thực hiện surgical edit trên markdown source + tự động re-render xlsx/docx
  • "review wbs" / "review proposal"  — agent giải thích nội dung
  • /ba-presale build                  — re-run toàn bộ build (overwrite warning)
  • /ba-presale handoff                — sang phase handoff sang /ba-start
```

### Loop behavior during gate (Optimized — Pattern B)

- **Bare prompts** = surgical edits. Optimized flow:
  1. `[JUDGMENT — Opus]` Lead parses user intent → identifies target artifact + section + exact change.
  2. `[MECHANICAL — Sonnet]` Lead creates narrow edit packet → dispatches to relevant sub-agent with explicit `model: "sonnet"`.
  3. `[MECHANICAL]` Wait for sub-agent return (~50 tokens).
  4. `[JUDGMENT — Opus]` Re-run sync-check on affected slice only (not full matrix).
  5. `[MECHANICAL]` If sync passes → re-render only the changed file (xlsx OR docx) via document-skills.
  6. `[MECHANICAL]` Return 1-line confirm: `Updated. Re-rendered {file}.`
- **NO history tracking** — feedback is not persisted as a separate artifact (per user policy). Only `_changelog/sync-*.md` records arbitration decisions.
- **`/ba-presale handoff`** = advance gate. Pre-check that markdown + rendered files are coherent (mtimes line up).

## Forbidden

- Auto-advancing from `clarify` without user command.
- Proceeding to render with sync conflicts unresolved.
- Rendering when source refs are missing — block with explicit error list.
- LLM-generating xlsx/docx XML directly. Always go through document-skills.
- Workers writing outside their target paths.
- Workers resolving conflicts with each other — flag upward to lead.
- Persisting feedback history (per user policy — surgical edits only, no log).
- Cross-project recall.
- **Spawning sub-agents without explicit `model: "sonnet"` parameter.** Silent model escalation (sub-agent inheriting Opus) is a cost multiplier. See `presale.model_enforcement` in `contract.yaml`.
- **Using Opus for mechanical steps** (dispatch, render, file ops). See `presale.orchestration_mode.mechanical_steps` in `contract.yaml`.
