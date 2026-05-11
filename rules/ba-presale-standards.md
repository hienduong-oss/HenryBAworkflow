# BA Presale Standards

Standards for the upstream presale lifecycle (`/ba-presale`). Sit alongside [BA Workflow](../../.claude/rules/ba-kit/ba-workflow.md) and [BA Quality Standards](../../.claude/rules/ba-kit/ba-quality-standards.md). Apply BEFORE handoff to `/ba-start` intake.

> Engine = single source of truth. **No cross-project recall.** Per-project knowledge does not leak across engagements.

---

## 1. Lifecycle Gates (presale)

| State | Owner | Model | Step Type | Gate to next |
|-------|-------|-------|-----------|--------------|
| 0 — Bootstrap | presale-lead | Sonnet | MECHANICAL | auto-chain → Domain Study |
| 1 — Domain Study | presale-lead + WebSearch | **Opus** | JUDGMENT | **USER GATE** — `/ba-presale clarify` |
| 2 — Clarify | presale-lead | **Opus** | JUDGMENT | **USER GATE** — `/ba-presale build` (no minimum answer threshold) |
| 3 — Build (WBS ‖ Proposal + sync + auto-render) | wbs-builder ‖ proposal-writer + lead | Sonnet ×2 + Opus (sync only) | MIXED | **USER GATE** — `/ba-presale handoff` |
| 4 — Handoff | presale-lead | Sonnet (compose) + Bash (file ops) | MOSTLY MECHANICAL | continuity check pass |

**Rules:**
- Auto-derive workspace from cwd. Never ask user for `--slug` / `--date`.
- User gates at Phase 1/2/3 are non-negotiable. Agent must explicitly instruct the next command.
- Phase 3 integrates sync-check + auto-render. No separate `render` command exists.
- Locked artifacts stay locked. Post-handoff corrections route through `/ba-start impact`.
- **Model enforcement:** Every Agent() call to sub-agents MUST include explicit `model: "sonnet"`. See `presale.model_enforcement` in `contract.yaml`.
- **Orchestration optimization:** Classify sub-steps as `[JUDGMENT]` or `[MECHANICAL]`. Mechanical steps use Bash/Sonnet, never Opus. See `presale.orchestration_mode` in `contract.yaml`.

---

## 2. Bootstrap (folder organization)

- Fully automatic. Agent NEVER asks user to organize files.
- Scan project folder (top-level + 1 deep, exclude `plans/`, `.git/`, `.claude/`, `node_modules/`), classify each file into one of:
  - `00_inputs/requirements/` — RFP, business docs, scope docs
  - `00_inputs/discussions/` — meeting notes, emails, chat logs
  - `00_inputs/technical/` — API specs, schemas, sample payloads, tech docs
  - `00_inputs/references/` — anything else useful
- `00_inputs/` lives at project root (`plans/{slug}-{date}/00_inputs/`), shared across presale and ba-start flows.
- Empty folder + text-only requirement → still proceed; capture originating user prompt as `00_inputs/requirements/_initial-prompt.md`.
- Do NOT modify file contents. Move/copy only.

---

## 3. Multi-Agent (orchestrator-worker)

- **presale-lead** (Opus) — orchestration, domain synthesis, clarify authoring, sync-check, conflict resolution, render dispatch, handoff composition.
- **wbs-builder** (Sonnet) — WBS markdown + CSV (English).
- **proposal-writer** (Sonnet) — Proposal markdown v4.0 §1–§11 (English).
- Lead NEVER delegates: assembly, merge, render dispatch, conflict arbitration, gap analysis, handoff.
- Sub-agents return ~50-token summary. Output goes to disk only.
- Parallel WBS+Proposal dispatch = single message, two `Agent` tool calls. Delegation packets reference template/rule paths only — never inline template content.

---

## 4. Conflict Resolution

When WBS and Proposal disagree during Phase 3 sync-check:
1. Lead identifies the conflict precisely (cite both sides + WBS row ID / Proposal §).
2. Anchor decision to **requirement source of truth**, in priority order:
   - `00_inputs/` client raw (shared across presale + ba-start)
   - Answered clarifications (`05-clarifications.md`)
   - Domain primer (validated)
   - Documented assumption (lowest)
3. Never resolve by "stronger side" or recency.
4. Log decision in `_changelog/sync-*.md` with `[src:...]` ref justifying the choice.
5. Dispatch surgical fix packet to whichever side is wrong. Loop until zero conflicts.

### Sync Changelog Schema

Each entry in `_changelog/sync-{YYYYMMDD-HHmm}.md` MUST follow this structure:

```markdown
# Sync Changelog — {YYYYMMDD-HHmm}

| # | Conflict | WBS side | Proposal side | Resolution | Source anchor | Fixed in |
|---|----------|----------|---------------|------------|---------------|----------|
| 1 | Effort mismatch P2 | 8 PD [src:wbs:P2] | 10 PD [src:proposal:§9] | Use WBS value | [src:client:RFP§3.2] | proposal §9 |
```

Fields:
- **Conflict**: short description of the disagreement
- **WBS side**: WBS value + row ID
- **Proposal side**: Proposal value + section
- **Resolution**: which side was corrected and to what value
- **Source anchor**: the `[src:...]` ref that justified the decision
- **Fixed in**: which artifact received the surgical edit

---

## 5. Traceability (CRITICAL)

Every fact in WBS, Proposal, and every clarification answer must carry an inline source ref using one of:
- `[src:client:<file>§<sec>]` — client raw input
- `[src:domain:§<n>]` — Domain Primer section
- `[src:clarify:Q<n>]` — Answered clarification
- `[src:assumption:A<n>]` — explicit assumption
- `[src:wbs:<id>]` — used in Proposal to reference WBS row
- `[src:intake:§<n>]` — used in backbone/downstream artifacts to reference a fact in `01_intake/intake.md`

Rules:
- A row/section with no source ref → blocked from auto-render.
- Assumption-sourced facts must be flagged for client validation in the clarifications sheet.
- Source refs must survive render to xlsx/docx (kept in a "Source" column / appendix / footnote).

---

## 6. Compaction Discipline

- After each phase, lead writes a state-card to `_state-cards/{NN}-{phase}.md` (≤300 tokens, Vietnamese):
  - phase id, output paths, key decisions, open issues, next gate
- Sub-agents heartbeat to delegation tracker every milestone or 5 min.
- Stalled slice (>5 min, no artifact change) → lead recovers (re-spawn or repartition), does not wait blindly.
- Templates referenced by path, never inlined into delegation packets.

---

## 7. Build Phase — Auto-Render (integrated)

- `/ba-presale build` auto-renders xlsx + docx AFTER sync-check passes. No separate `render` command.
- xlsx sheets: WBS | Clarifications | Summary | Assumptions.
- docx: Proposal v4.0 §1–§11 applying variant rules (A_platform / B_custom).
- Style: `templates/output-style-spec.json`. Render blocked if style spec missing, source refs missing, or sync-check unresolved.
- Surgical edits during Phase 3 gate auto re-render only the affected file (xlsx OR docx), not both.
- Render must NOT mutate content files. Renders are derived artifacts.

---

## 8. Handoff to `/ba-start` (CRITICAL)

The handoff must:

1. Compose `plans/{slug}-{date}/01_intake/intake.md` directly from the source-of-truth bundle:
   - `00_inputs/*` (client raw — shared across presale + ba-start, no mirror needed)
   - `00_presale/00-domain-primer.md`
   - `00_presale/05-clarifications.md` (Answered rows)
   - `00_presale/10-wbs-content.md` (LOCKED)
   - `00_presale/20-proposal-content.md` (LOCKED)
2. **Never re-ask the user** for scope, stakeholders, goals, or commitments already captured in presale artifacts.
3. Mirror the 4 presale analysis files into `01_intake/_sources/` so backbone can re-read originals. `00_inputs/` is NOT mirrored — both flows access it directly at project root.
4. Produce `01_intake/handoff-manifest.md` — table mapping every fact in `intake.md` to its source ref.
5. Structure `intake.md` so `/ba-start backbone` can extract:
   - Business goals ← Proposal §1 + Domain Primer §1 + client raw
   - Scope items ← WBS phases / work packages + Proposal §7
   - Constraints ← Proposal §5/§6 commitments + technical inputs
   - Clarified points ← Answered clarifications
   - Open questions ← Draft/Skipped clarifications
   - Stakeholders ← client raw + discussions + Domain Primer §2
6. **Continuity check (BLOCKING)** before declaring handoff complete:
   - Every WBS phase appears in `intake.md` scope.
   - Every Proposal commitment appears in `intake.md` (constraint or scope).
   - Every Answered clarification is reflected in `intake.md`.
   - Every Draft/Skipped clarification appears in open questions.
   - Missing item → block handoff with explicit error. Do not paper over.
7. **Locked authority:** post-handoff, WBS + Proposal are source of truth. If `/ba-start backbone` produces something contradicting them → flag for user review, never silently overwrite.

---

## 9. Language & Conventions

| Artifact | Language |
|----------|----------|
| Domain Primer (`00-domain-primer.md`) | **Vietnamese** (internal BA) |
| Clarifications (`05-clarifications.md`) | **English** (client-facing) |
| WBS md + csv + xlsx | **English** (client-facing) |
| Proposal md + docx | **English** (client-facing) |
| State cards (`_state-cards/*`) | **Vietnamese** (internal) |
| Agent summaries to user | **Vietnamese** |
| Command pre-run blocks | **English** |
| `intake.md` + `plan.md` (post-handoff) | **Vietnamese** (matches `/ba-start` defaults) |

Other conventions:
- Effort unit: Person-Day (PD).
- Date format per `output-style-spec.json` `variables.date_format` (default `DD/MM/YYYY`).
- Currency per `variables.currency_symbol` (default VND).
- File naming: NN-prefix + kebab-case slug, exactly as declared in `core/contract.yaml`.

---

## 10. What NOT to do

- Do NOT recall past projects, do NOT use cross-project examples.
- Do NOT ask user for `--slug` / `--date` — auto-derive from cwd.
- Do NOT auto-render on every edit during Phase 3 — only on surgical-edit completion.
- Do NOT pass full templates into sub-agent delegation packets — reference by path.
- Do NOT delegate assembly / merge / render / conflict arbitration / gap analysis / handoff.
- Do NOT resolve conflicts by "stronger side" — only by requirement source priority.
- Do NOT skip any user gate.
- Do NOT persist feedback history — apply surgical edits immediately; log only sync-check arbitrations in `_changelog/`.
- Do NOT re-ask user for information already captured in Domain Primer / Clarifications / WBS / Proposal during handoff.
- Do NOT modify locked WBS/Proposal during `/ba-start` backbone without flagged review.

---

## 11. Orchestration Optimization (Pattern B)

Minimize token spend by separating judgment from mechanical steps. Reference: `presale.orchestration_mode` in `contract.yaml`.

### Model Enforcement
- Every `Agent()` call to sub-agents MUST include explicit `model: "sonnet"`.
- Sub-agents must NEVER inherit the lead's Opus model (prevents silent 3x cost escalation).
- Validation: if delegation target is `wbs-builder` or `proposal-writer`, the call must pass `model: "sonnet"`.

### Judgment vs Mechanical
- **Judgment** (Opus justified): domain synthesis, gap analysis, sync-check comparison, conflict resolution anchoring, surgical edit intent parsing, cross-artifact consistency check.
- **Mechanical** (Bash/Sonnet/conditional): auto-chain routing, parallel dispatch, render dispatch, file mirror/copy, continuity grep, template-fill composition, edit packet creation.
- Step files mark each sub-step with `[JUDGMENT]` or `[MECHANICAL]`.
- Do NOT route mechanical steps through Opus context.

### Surgical Edit Loop (Optimized)
1. `[JUDGMENT — Opus]` Parse user intent.
2. `[MECHANICAL — Sonnet]` Create + dispatch edit packet.
3. `[MECHANICAL]` Wait for return.
4. `[JUDGMENT — Opus]` Sync-check affected slice.
5. `[MECHANICAL]` Re-render affected file.
6. `[MECHANICAL]` Confirm.
