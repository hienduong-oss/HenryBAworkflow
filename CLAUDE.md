# BA-kit Instructions For Claude Code

## What is BA-kit

BA-kit là lifecycle engine cho solo IT BA. Nhận raw requirements → normalize → lock scope → build requirements backbone → emit downstream artifacts theo gate.

## Canonical Sources

1. `core/contract.yaml` — paths, prerequisites, defaults, state enums
2. `core/contract-behavior.md` — shared runtime-neutral behavior; plus the command shard in `core/behavior/` listed by `core/contract.yaml.behavior_shards`
3. `skills/ba-start/SKILL.md` — lifecycle stub that dispatches into the active step file
4. `skills/{skill}/steps/{step}.md` — chỉ đọc step đang active

For lifecycle work, read `contract.yaml`, then shared behavior, then only the selected command behavior shard and step file.

## Language & Communication

- BA deliverables viết bằng **Vietnamese** trừ khi user yêu cầu English.
- Artifact client-facing (Clarifications, WBS, Proposal) luôn bằng **English**.
- Giao tiếp với user: mix English/Vietnamese tự nhiên — technical terms và tên artifact giữ nguyên tiếng Anh, giải thích và tóm tắt bằng tiếng Việt.
- Xưng hô: **Tôi** (Claude) và **Bạn** (user). Không dùng "anh/em".

## Core Defaults

- Default mode: `hybrid` — backbone + targeted FRD + stories + selective SRS + critical wireframes.
- Exact slug/date/module matching only. Không chọn bằng mtime.
- `plans/{slug}-{date}/02_backbone/project-memory.md` là persisted project memory — không dùng Claude chat memory làm system of record.
- Route requirement changes qua `impact` trước khi mutate downstream artifacts (trừ wording-only edits).
- Rerun step đã được user approve → giữ locked, không reopen.
- Large artifacts → incremental section-by-section writes để tránh output token truncation.
- Apply runtime-neutral HITL behavior: granular artifact intervention, active push-back on material ambiguity, fail-closed routing instead of plausible guessing.

## Runtime Guardrails

If a wrapper or operator supplies a guardrail preflight packet for `frd`, `stories`, `package`, `status`, or `next`, treat that packet as the authoritative runtime constraint.

- Honor `status`, `message`, `guardrail_mode`, `allow_reads`, `deny_reads`, `indexes`, and `refresh_command` exactly as supplied.
- If `status=block`, stop before lifecycle work and surface `refresh_command` instead of proceeding.
- Treat an index as truly current only when the packet already reflects producer-side validation; do not assume a freshly generated index is trusted before `validated_at` and `validated_by` exist.
- When the packet says an index is current, use only the allowlisted files for discovery and prefer any generated excerpt files over reopening the full source artifact.
- Do not discovery-read a full artifact that appears in `deny_reads` unless you first emit `READ_ESCALATION: {command} read {path} due to {reason}.`
- If an `action_guardrail` or `ACTION_GUARDRAIL` reminder is present, obey it on that action even if earlier turns already mentioned the same backbone route.
- For `status` and `next`, `PROJECT-HOME.md` may help explain state to the user but must not override canonical artifact resolution.
- Keep the runtime payload compact; do not ask for the full guardrail policy again when the packet already supplies the verdict and exact path hints.

### Output Modes

Adapters and wrappers emit one of three output modes. Use the smallest mode that satisfies the action:

| Mode | When to use | Required fields |
| --- | --- | --- |
| `probe` | no-op, clarification, or block verdict | `output_mode`, `status`, `command`, `resolved_slug`, `message` |
| `delta` | index-first action with changed state | probe fields + `indexes.<name>.state`, `action_guardrail` (if present), `allow_reads`, `excerpt_path` (if built) |
| `full` | escalation, broad read, or first-run with no index | delta fields + `deny_reads`, `canonical_state_summary`, `canonical_next_command`, `refresh_command` (if block) |

Rules:
- `probe` is the default for `status=block` and no-op responses; do not add delta or full fields.
- `delta` is the default for `status=ok` or `status=warn` when an index is current.
- `full` is required only when `READ_ESCALATION` is emitted or no current index exists.
- Receipt contracts (`impact_receipt`, `options_receipt`, `index_validation_receipt`) are separate artifacts; do not embed their content in the runtime packet.

## Artifact Model

- Project root: `plans/{slug}-{date}/`
- Project Home: `PROJECT-HOME.md`
- Intake and plan: `01_intake/`
- Backbone and memory: `02_backbone/`
- Module artifacts: `03_modules/{module_slug}/`
- Compiled HTML: `04_compiled/`
- Delegation: `delegation/`, `delegation/packets/`
- Collaboration: `COLLAB-HOME.md`, `MODULE-HOME.md`, `delegation/review-packets/`
- Presale artifacts (nếu có): `00_presale/`

## Skills & Commands

```
/ba-presale          ← upstream presale (trước /ba-start)
/ba-start intake     ← Steps 1-4: normalize + scope lock
/ba-start backbone   ← Step 5: build backbone
/ba-start frd        ← Step 6: FRD per module
/ba-start stories    ← Step 7: user stories
/ba-start srs        ← SRS router
/ba-start wireframes ← Step 9: wireframe constraints
/ba-start impact     ← analyze change impact
/ba-start package    ← Step 12: package deliverables
/ba-next             ← recommend next step
```

## Delegation

Agents trong `agents/`:
- `requirements-engineer` — backbone, FRD, stories, selective SRS
- `ui-ux-designer` — wireframe constraint pack + handoff checklist
- `ba-documentation-manager` — validation, quality review, packaging
- `ba-researcher` — domain research

Narrow packets only: exact path, write scope, trace IDs, targeted excerpts. Không attach full merged artifacts. Không delegate assembly/merge.

## BA-Friendly UX

Resume từ `PROJECT-HOME.md`. Commands tắt:
- tạo dự án mới → `/ba-start intake`
- tiếp tục → `/ba-next`
- thay đổi → `/ba-start impact`
- handoff UI → `/ba-start wireframes`
- bàn giao → `/ba-start package`

Route module collaboration NLP to `ba-collab`. Commit/push/PR/merge yêu cầu explicit approval từ user.

## Methodology Alignment Gate

**Before executing any change to BA-kit** — merge, implement, update, refactor, or add a new skill/script/rule — run the methodology alignment checklist at `docs/methodology-alignment-checklist.md`.

The checklist has 5 checks:
1. **Methodology Coverage** — does `METHODOLOGY.md` cover the BA standard this change implements? If not, draft a new section first.
2. **Artifact Traceability** — does the change preserve frontmatter, `[src:...]` refs, and `[ ]` OQ markers?
3. **Quality Gate Impact** — does the change affect UC/story/screen artifacts? Verify `qc-uc-review` gate still fires.
4. **Reverse Mode Boundary** — does the change touch reverse commands? Verify Snapshot Truth and As-Built Separation.
5. **Local Customization Preservation** — does the change risk overwriting local-only sections (Memory Governance, `presale_detection`, `.claude/rules/ba-kit/`)?

**If any check fails or is uncertain → surface to user before proceeding.**

Include `methodology-check: pass` sign-off in commit message for every BA-kit change. See checklist for full sign-off format.
