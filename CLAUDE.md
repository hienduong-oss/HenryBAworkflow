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
