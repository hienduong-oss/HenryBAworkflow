# BA Presale Standards

Upstream presale lifecycle (`/ba-presale`). Apply BEFORE handoff to `/ba-start`.
No cross-project recall. Per-project knowledge does not leak across engagements.

Related rules: [BA Workflow](./ba-workflow.md) | [BA Quality Standards](./ba-quality-standards.md)

## Lifecycle Gates

| Phase | Owner | Model | Gate |
|-------|-------|-------|------|
| 0 Bootstrap | presale-lead | Sonnet | auto-chain |
| 1 Domain Study | presale-lead + WebSearch | **Opus** | USER GATE → `/ba-presale clarify` |
| 2 Clarify | presale-lead | **Opus** | USER GATE → `/ba-presale build` |
| 3 Build (WBS ‖ Proposal + sync + render) | wbs-builder ‖ proposal-writer + lead | Sonnet×2 + Opus (sync) | USER GATE → `/ba-presale handoff` |
| 4 Handoff | presale-lead | Sonnet + Bash | continuity check pass |

**Non-negotiable rules:**
- Auto-derive workspace từ cwd. Never ask `--slug` / `--date`.
- User gates Phase 1/2/3 không thể bỏ qua.
- Phase 3 tích hợp sync-check + auto-render. Không có lệnh `render` riêng.
- Locked artifacts stay locked. Post-handoff → route qua `/ba-start impact`.
- Mọi `Agent()` call đến sub-agents PHẢI có `model: "sonnet"` explicit.
- Classify sub-steps: `[JUDGMENT]` (Opus) vs `[MECHANICAL]` (Bash/Sonnet). Không route mechanical qua Opus.

## Bootstrap

Fully automatic — agent không hỏi user tổ chức file.
Scan top-level + 1 deep (exclude `plans/`, `.git/`, `.claude/`, `node_modules/`):
- `00_inputs/requirements/` — RFP, business docs, scope docs
- `00_inputs/discussions/` — meeting notes, emails, chat logs
- `00_inputs/technical/` — API specs, schemas, tech docs
- `00_inputs/references/` — anything else

Empty folder → capture user prompt vào `00_inputs/requirements/_initial-prompt.md`.

## Multi-Agent Roles

- **presale-lead** (Opus): orchestration, domain synthesis, clarify, sync-check, conflict resolution, handoff. KHÔNG delegate assembly/merge/render/arbitration.
- **wbs-builder** (Sonnet): WBS markdown + CSV.
- **proposal-writer** (Sonnet): Proposal v4.0 §1–§11.
- Sub-agents return ~50-token summary. Output to disk only.
- Parallel dispatch = single message, hai `Agent` tool calls.

## Traceability (CRITICAL)

Mọi fact trong WBS/Proposal/clarifications phải có inline source ref:
- `[src:client:<file>§<sec>]` — client raw input
- `[src:domain:§<n>]` — Domain Primer
- `[src:clarify:Q<n>]` — Answered clarification
- `[src:assumption:A<n>]` — explicit assumption
- `[src:wbs:<id>]` — WBS row (dùng trong Proposal)

Row/section không có source ref → blocked khỏi auto-render.

## Conflict Resolution (Phase 3)

Khi WBS và Proposal mâu thuẫn:
1. Identify conflict chính xác (cite cả hai phía + row ID / section).
2. Anchor theo priority: client raw > answered clarifications > domain primer > assumption.
3. Log vào `_changelog/sync-{YYYYMMDD-HHmm}.md`.
4. Dispatch surgical fix packet cho phía sai. Loop đến khi zero conflicts.

## Handoff to `/ba-start` (CRITICAL)

1. Compose `01_intake/intake.md` từ source-of-truth bundle.
2. Mirror 4 presale analysis files vào `01_intake/_sources/`. `00_inputs/` không mirror — cả hai flows access trực tiếp.
3. Produce `01_intake/handoff-manifest.md` — map mọi fact → source ref.
4. **Continuity check (BLOCKING):** mọi WBS phase, Proposal commitment, answered clarification phải xuất hiện trong `intake.md`. Missing → block với explicit error.

## Language

| Artifact | Language |
|---|---|
| Domain Primer, State cards | Vietnamese |
| Clarifications, WBS, Proposal | English |
| `intake.md`, `plan.md` | Vietnamese |

## What NOT to do

- Không recall past projects, không dùng cross-project examples.
- Không auto-render mọi edit — chỉ render sau surgical-edit completion.
- Không pass full templates vào delegation packets — reference by path.
- Không resolve conflicts bằng "stronger side" — chỉ bằng requirement source priority.
- Không skip user gate.
- Không re-ask thông tin đã có trong Domain Primer / Clarifications / WBS / Proposal.
