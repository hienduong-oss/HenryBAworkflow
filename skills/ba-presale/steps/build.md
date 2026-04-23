# BA Presale Step — Build (WBS + Proposal + Sync + Render)

Phase 3 of the presale lifecycle. Owner: `presale-lead` (orchestrator, **Opus** for sync arbitration). Dispatches `wbs-builder` and `proposal-writer` (both **Sonnet**) in parallel, runs sync-check inline, then auto-renders xlsx + docx.

Triggered by user command `/ba-presale build`. Never auto-advances from `clarify`.

This step requires:
- `plans/{slug}-{date}/00_presale/00-domain-primer.md`
- `plans/{slug}-{date}/00_presale/05-clarifications.md` (≥80% answered)
- `templates/wbs-template.md`, `templates/wbs-template.csv`
- `templates/proposal-template.md`, `templates/proposal-guide.md`
- `templates/output-style-spec.json`
- `rules/ba-presale-standards.md` §3, §4, §5
- Skills: `document-skills:xlsx`, `document-skills:docx`

## Pre-run description block (MANDATORY)

Before any work, print this block in English (short, concise):

```
────────────────────────────────────────
🔵 /ba-presale build — WBS + Proposal + Render
────────────────────────────────────────
Phase 3 — Generate scope/effort + commercial deliverables.

Will:
  1. Pre-flight: confirm Domain Primer + ≥80% clarifications answered
  2. Dispatch wbs-builder + proposal-writer in PARALLEL (Sonnet ×2)
  3. Run sync-check inline (Opus): WBS ↔ Proposal alignment
  4. Resolve conflicts via requirement source priority; loop until clean
  5. AUTO-RENDER xlsx (WBS + Clarifications sheets) and docx (Proposal)

Outputs:
  plans/{slug}-{date}/00_presale/10-wbs-content.md  (+ .csv)
  plans/{slug}-{date}/00_presale/20-proposal-content.md
  plans/{slug}-{date}/00_presale/_output/10-wbs-final.xlsx
  plans/{slug}-{date}/00_presale/_output/20-proposal-final.docx

Language: English (artifacts are client-facing)
Next gate: USER GATE — review xlsx + docx before /ba-presale handoff

Proceed? (reply 'ok' to start, or type a different command)
────────────────────────────────────────
```

Wait for `ok` before continuing.

## Step 1 — Pre-flight checks

Block build if any check fails:

1. `00-domain-primer.md` exists.
2. `05-clarifications.md` exists AND `Status=Answered` ≥ 80% of total rows.
   - On fail, print:
     ```
     ⚠️ Cannot build: only {answered}/{N} clarifications answered ({pct}%).
        Run /ba-presale clarify and answer remaining questions or use
        "accept all suggestions" then retry /ba-presale build.
     ```
3. Templates exist at expected paths.
4. `_output/` directory exists (create if missing).

## Step 2 — Resolve Proposal variant

Determine variant from Domain Primer + answered clarifications:
- **Variant A — Platform/Integration**: vendor-led, discovery-heavy, team-based quotation. Triggered by Tech category answers indicating vendor CIAM / SaaS adoption / heavy integration with established platforms.
- **Variant B — Custom-Build**: full WBS, fixed-price, phase-based modules. Default when scope is greenfield application development.

Record variant decision in state card (Step 6).

## Step 3 — Parallel dispatch (single message, two Agent calls)

Dispatch both sub-agents in a single tool-call batch.

### Packet A → `wbs-builder` (Sonnet)

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

### Packet B → `proposal-writer` (Sonnet)

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

Both dispatched in PARALLEL via single message containing two Agent tool calls.

## Step 4 — Sync-check (lead, inline, Opus)

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

Log each decision to `00_presale/_changelog/sync-{YYYYMMDD-HHmm}.md`. Dispatch surgical fix to relevant sub-agent (single-section edit packet). Re-run sync-check after fixes return. Loop until zero conflicts OR escalation needed.

### Escalation

If a conflict cannot be anchored to any source, STOP and present to user. Do NOT proceed to render.

## Step 5 — Auto-render (no user prompt)

After sync-check passes (zero conflicts):

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

### Render block conditions

Block render if any check fails:
- Any WBS row missing `[src:...]`
- Any Proposal commitment in §1.4, §7, §9 missing `[src:...]`
- Source CSV/MD files unreadable

On block, list offending rows/sections, do NOT render, return user to Step 4.

## Step 6 — State card

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

### Loop behavior during gate

- **Bare prompts** = surgical edits. Lead parses intent, dispatches narrow edit packet (one section / one row) to relevant sub-agent. After edit returns, re-run sync-check on affected slice, then re-render only the changed file (xlsx or docx). Return 1-line confirm: `Updated. Re-rendered {file}.`
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
