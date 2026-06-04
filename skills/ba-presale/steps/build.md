# BA Presale Step — Build (WBS + Proposal + Sync + Render)

Phase 3 of the presale lifecycle. Owner: `presale-lead` (orchestrator, **Opus** for sync arbitration). Dispatches `wbs-builder` and/or `proposal-writer` (both **Sonnet**) based on user selection, runs sync-check inline, then auto-renders.

## Checkpoint

Write `paths.presale_checkpoint` as the **first action**:
```
step: build
status: running
command: /ba-presale build
started: <ISO timestamp>
updated: <ISO timestamp>
progress: ""
last_write: ""
resume_hint: ""
```
After each sub-agent completes (wbs-builder, proposal-writer), update `progress` (e.g., "WBS done, Proposal running") and `last_write`.
After sync-check and render, update `progress: "sync-check done, rendering"`.
On complete, update `status: completed` and `updated`.
Triggered by user command `/ba-presale build`. Never auto-advances from `clarify`.

This step requires:
- `paths.presale_domain_primer`
- `paths.presale_clarifications` (no minimum answer threshold — unanswered questions become assumptions)
- `templates/wbs-template.md`, `templates/wbs-template.csv`
- `templates/proposal-template.md`, `templates/proposal-guide.md`
- `templates/output-style-spec.json`
- `rules/ba-presale-standards.md` §3, §4, §5
- Skills: `document-skills:xlsx`, `document-skills:docx`

## Pre-run: Build Target Selection (MANDATORY)

Before any work, present build target + WBS mode selection. Do NOT assume "build all" or default mode.

**Step A — Build target question:**

**Question:** "What would you like to build?"

**Options:**
1. **Build all** — WBS + Proposal + sync-check + render (both xlsx + docx)
2. **Proposal only** — Proposal markdown + docx render (skip WBS)
3. **WBS only** — WBS markdown + CSV + xlsx render (skip Proposal)

**Step B — WBS mode question (ask ONLY when build target includes WBS — "Build all" or "WBS only"):**

**Question:** "Which WBS break mode?"

**Options:**
1. **Mode A — feature-ui** — break by actor action. Best for: stakeholder review, requirements traceability, UC/AC authoring. Output: `# | Category | Function | Sub-Function | Actor | Notes | Web/mobile (day) | Backend (day)`
2. **Mode B — epic-component** — break by deliverable task, FE/BE separated, BE complexity exposed as individual rows, cross-cutting EPICs (Infra/SC/QA) mandatory. Best for: sprint planning, dev task assignment, delivery tracking. Output: `# | Phase | Epic | Task Name | Layer | Notes | PM | BA | SC | BE | DevOps | Mobile | FE | QC | Total MD`

Ask Step A and Step B in a **single `AskUserQuestion` call** with 2 questions. Do NOT ask sequentially.

After user selects, print the pre-run description block reflecting the chosen target and mode:

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

WBS Mode: {A — feature-ui | B — epic-component | N/A (Proposal only)}

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
target_md:  paths.presale_wbs
target_csv: paths.presale_wbs_csv
wbs_mode:   {A | B}  ← REQUIRED — pass the mode selected by user in Pre-run Step B
templates:
  - bakit/templates/wbs-template.md
  - bakit/templates/wbs-template.csv
inputs:
  - paths.presale_domain_primer
  - paths.presale_clarifications (Answered + Assumed rows)
  - 00_inputs/  (read on demand)
language: English
source_ref_format: see rules/ba-presale-standards.md §5
write_scope: target_md + target_csv only
return_format: ~50-token summary (status, mode used, row counts, open flags)
tracker: paths.presale_state_cards/03a-wbs.md

WBS MODE A — feature-ui (8 columns for Google Sheets xlsx output):
  # | Category | Function | Sub-Function | Actor | Notes | Web/mobile (day) | Backend (day)
  Style spec: output-style-spec.json xlsx.sheets.WBS
  Break rules: see bakit/templates/wbs-template.md §MODE A rules

WBS MODE B — epic-component (15 columns for Google Sheets xlsx output):
  # | Phase | Epic | Task Name | Layer | Notes | PM | BA | SC | BE | DevOps | Mobile | FE | QC | Total MD
  Style spec: output-style-spec.json xlsx.sheets.WBS_mode_b
  Break rules: see bakit/templates/wbs-template.md §MODE B rules
  CRITICAL for Mode B:
    - Every Task Name MUST start with [Layer] tag
    - BE complexity = separate rows, never hidden in Notes
    - Cross-cutting EPICs (Infra, SC, QA) are mandatory — never fold into feature EPICs
    - Effort: fill only the column matching the row's layer tag; all others = 0

Common column roles (both modes):
  - # (col A): WBS ID — integer for EPIC rows, decimal for task rows
  - Notes: full behavioral spec (Mode A) or technical scope boundary (Mode B) + [src:...] refs

Note: Milestone and Dependencies are markdown-WBS fields only — omit from xlsx output.

EPIC row rules (both modes):
  - Col A = integer only (1, 2, 3, 4)
  - EPIC name ALL CAPS
  - All other columns = LEAVE EMPTY

Clarification confidence:
  - Assumed rows (Status=Assumed) = agent-inferred, lower confidence — flag in Notes if scope-impacting
  - Answered rows (Status=Answered) = client-confirmed, use as facts

Content rules: see bakit/templates/wbs-template.md §WBS Content Rules — single canonical source.
```

### Packet B → `proposal-writer` (model: **sonnet**) — skip if "WBS only"

```
objective: Author Proposal markdown (English) from Domain Primer + answered clarifications + WBS.
target:    paths.presale_proposal
templates:
  - bakit/templates/proposal-template.md
  - bakit/templates/proposal-guide.md
variant:   {A_platform | B_custom}
inputs:
  - paths.presale_domain_primer
  - paths.presale_clarifications (Answered rows only)
  - paths.presale_wbs  (may be in-flight; draft §1–§6, §8, §10–§11 first; stub §7, §9)
language: English
source_ref_format: see rules/ba-presale-standards.md §5
write_scope: target only
return_format: ~50-token summary (status, section coverage, flags)
tracker: paths.presale_state_cards/03b-proposal.md
```

Both dispatched in PARALLEL via single message containing two Agent tool calls (when "Build all" selected).

### Sub-agent write size limit (CRITICAL)

Each delegation packet MUST NOT require a sub-agent to write >150 lines in a single Write call. Long writes exceed connection timeout (~3 min) and produce truncated files.

- **Proposal dispatch:** Split into at minimum 2 packets — Packet B1 (§1–§6, ~150 lines) and Packet B2 (§7–§11, ~150 lines). **B2 MUST NOT be dispatched until B1 returns successfully AND the target file exists on disk with >30 lines.** Verify B1 output before dispatching B2.
- **WBS dispatch:** If WBS >100 rows, split into 2 write passes (rows 1–N/2, then append rows N/2+1–end).
- Sub-agents must use incremental Write + Edit/append pattern, not a single large Write call.

### Socket error recovery (MANDATORY check after each sub-agent returns)

After each sub-agent returns:
1. Check target file exists on disk.
2. Check line count: >50 for Proposal, >20 for WBS.
3. If file missing or truncated → dispatch surgical completion packet:
   - Pass exact last section written (from sub-agent ~50-token summary)
   - Instruction: "append to existing file starting from §X" or "continue from row N"
   - `model: "sonnet"`
4. Do NOT proceed to sync-check until both files pass the line count check.

## Step 4 — Sync-check `[JUDGMENT — Opus]` (lead, inline) — only when "Build all"

**Skip this step entirely if build target is "Proposal only" or "WBS only".** Sync-check only applies when both artifacts are built in the same run.

This is a true judgment point — the lead must detect semantic conflicts and anchor resolution to source priority. Opus is justified here.

**Token-optimized read:** After both sub-agents return, read the sync-payload files first — NOT the full artifacts:
- `paths.presale_state_cards/03a-wbs-sync-payload.md`
- `paths.presale_state_cards/03b-proposal-sync-payload.md`

Run the check matrix against the structured payloads. Only open the full `10-wbs-content.md` or `20-proposal-content.md` when a conflict requires reading the exact surrounding context (e.g., ambiguous wording, multi-row dependency).

| Check | WBS source (payload) | Proposal source (payload) | Action on mismatch |
|-------|------------|-----------------|--------------------|
| Phase rows | Phase rows table | §7.1 In-Scope items | Conflict |
| Effort totals | Effort totals | §9 Effort totals | Conflict |
| Deliverables | Phase rows → Deliverables col | §7.1 In-Scope items | Conflict |
| Exclusions | Exclusions list | §7.2 Out-of-Scope items | Conflict |
| Timeline | sum effort vs payload §8 milestones | §8 Milestones | Conflict if infeasible |
| Assumptions | Assumptions table | §7.3 Assumptions table | Conflict |
| Source refs | Source ref coverage | Source ref coverage | Block render if missing |

### Conflict resolution

For each conflict, anchor decision to source priority:
1. `00_inputs/` client raw
2. Answered clarification — client-confirmed (`05-clarifications.md`, Status=Answered)
3. Assumed clarification — agent-inferred (`05-clarifications.md`, Status=Assumed) — treat as low-confidence; client raw overrides without escalation
4. Validated Domain Primer
5. Documented assumption (lowest)

**Assumed vs Answered in conflict resolution:**
- Client answer conflicts with `Assumed` → NOT a real conflict. Expected override. Update Assumed → Answered, log change, no escalation needed.
- Client answer conflicts with `Answered` (client-confirmed) → REAL conflict. Escalate to user.

Log each decision to `paths.presale_changelog/sync-{YYYYMMDD-HHmm}.md`. Dispatch surgical fix to relevant sub-agent (**model: sonnet** — single-section edit packet, mechanical dispatch). Re-run sync-check after fixes return. Loop until zero conflicts OR escalation needed.

**Max 2 dispatch cycles.** If conflicts remain after 2 rounds of surgical fixes, stop and escalate to user — do not dispatch a third time.

### Escalation

If a conflict cannot be anchored to any source, OR if 2 dispatch cycles have completed and conflicts remain: STOP and present to user with exact conflict list and which source anchor is missing. Do NOT proceed to render.

## Step 5 — Auto-render `[MECHANICAL]` (no user prompt)

Deterministic: render only the artifacts that were built. No LLM judgment needed for the dispatch decision.

- **Build all:** render both xlsx + docx (after sync-check passes).
- **Proposal only:** render docx only.
- **WBS only:** render xlsx only.

After sync-check passes (or immediately after dispatch return for single-target builds):

### 5a — WBS xlsx

Invoke `document-skills:xlsx` with:
- Rows: parse `paths.presale_wbs_csv`
- Style: `templates/output-style-spec.json` `xlsx.sheets.WBS`
- Sheets in `10-wbs-final.xlsx`:
  - `WBS` — main table (from CSV)
  - `Clarifications` — parsed from `paths.presale_clarifications` table (Status colored)
  - `Summary` — phase totals (from WBS markdown §3)
  - `Assumptions` — from WBS markdown §4
- Apply: header colors, hierarchy levels (level_1 bold + fill), totals row, status_color_map for Clarifications, freeze panes B2

Output: `paths.presale_wbs_xlsx`

### Render isolation (CRITICAL)

Render MUST be dispatched as a sub-agent (`model: "sonnet"`), NOT executed inline by the lead. Before dispatching render, the lead MUST NOT re-read proposal or WBS content — doing so inflates context and can corrupt pending tool call state (empty parameter errors).

Lead passes to render sub-agent only:
- `input_path` — path to the markdown source
- `output_path` — path for the rendered file
- `style_spec_path` — `templates/output-style-spec.json`

### 5b — Proposal docx

Invoke `document-skills:docx` with:
- Input: `paths.presale_proposal`
- Style: `templates/output-style-spec.json` `docx.*`
- Apply: cover page, heading_1/2/3 styles, table styling, header/footer with `{{client_name}}` / `{{project_name}}` substitution
- Watermark: only if `docx.watermark.show = true`

Output: `paths.presale_proposal_docx`

### Render block conditions `[MECHANICAL]`

Boolean checks — block render if any check fails:
- Any WBS row missing `[src:...]`
- Any Proposal commitment in §1.4, §7, §9 missing `[src:...]`
- Source CSV/MD files unreadable

On block, list offending rows/sections, do NOT render, return user to Step 4.

## Step 6 — State card `[MECHANICAL]`

Write `paths.presale_state_cards/03-build.md` (≤300 tokens, Vietnamese):
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
  📊 WBS xlsx:      paths.presale_wbs_xlsx
  📄 Proposal docx: paths.presale_proposal_docx

  Markdown sources (for surgical edits):
  - paths.presale_wbs
  - paths.presale_proposal

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

## Memory Capture

After Build is approved by user (before `/ba-presale handoff`), promote to project memory:

| What to capture | Target shard | Trigger |
|---|---|---|
| Proposal variant decision (A_platform vs B_custom) and rationale | Global memory (`project` type) | After variant is resolved |
| Scope boundaries confirmed in WBS (in-scope phases, out-of-scope exclusions) | Global memory (`project` type) | After sync-check passes |
| Commercial constraints confirmed (budget range, timeline anchor, engagement type) | Global memory (`project` type) | After Answered clarifications are locked |
| Conflict resolution decisions (which source won, why) | `_changelog/sync-{YYYYMMDD-HHmm}.md` | After each sync-check cycle |

**Note:** Presale has no project memory shard yet — use global Claude memory (`project` type) for presale-phase captures. Project memory shard is initialized during `/ba-start backbone`. Set `Confidence: high` for client-confirmed facts, `medium` for agent-inferred decisions.
