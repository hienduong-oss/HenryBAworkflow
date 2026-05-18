# BA-kit Instructions For Claude Code

## What is BA-kit

BA-kit là lifecycle engine cho solo IT BA. Nhận raw requirements → normalize → lock scope → build requirements backbone → emit downstream artifacts theo gate.

Canonical sources (đọc theo thứ tự khi cần):
1. `core/contract.yaml` — paths, prerequisites, defaults, state enums
2. `core/contract-behavior.md` — routing, recovery, execution locking, delegation policy
3. `skills/ba-start/SKILL.md` — lifecycle stub, dispatch vào step files
4. `skills/{skill}/steps/{step}.md` — chỉ đọc step đang active

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
- HITL behavior: push back on material ambiguity, fail-closed routing, không plausible guessing.

## Artifact Model

```
plans/{slug}-{date}/
  00_presale/          ← presale artifacts (nếu có)
  01_intake/intake.md  ← normalized requirements
  01_intake/plan.md
  02_backbone/backbone.md     ← source of truth
  02_backbone/project-memory.md
  03_modules/{module_slug}/   ← frd.md, srs.md, user-stories.md
  04_compiled/
  delegation/
PROJECT-HOME.md        ← BA-facing dashboard
designs/{slug}/DESIGN.md
```

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

Commit/push/PR/merge yêu cầu explicit approval từ user.

## Updating BA-kit

Khi cần sửa bất kỳ file nào trong BA-kit (rules, steps, agents, templates, contract):
1. Edit file trong `~/bakit/` (source of truth, git-controlled)
2. Sau khi edit xong, chạy `bash ~/bakit/scripts/ba-kit-sync` để sync vào `~/.claude/`
3. Không edit trực tiếp `~/.claude/skills/` hay `~/.claude/rules/` — những file đó là installed copy, sẽ bị overwrite khi update

## Feedback Routing — BA-kit vs Project Memory

Khi user correct hoặc confirm một cách làm, phân loại trước khi lưu:

**Apply vào `~/bakit/` (không save memory) khi feedback liên quan đến:**
- BA workflow behavior: routing rules, artifact gates, step logic
- Proposal/WBS/SRS/FRD structure hoặc content rules
- Agent behavior, delegation rules, description
- Template content, pitfalls, style guide
- Contract behavior, token discipline, execution locking

**Save vào project memory khi feedback liên quan đến:**
- Facts cụ thể của project: scope, stakeholders, decisions, tech stack
- Client preferences hoặc constraints của engagement cụ thể
- Reference paths, external URLs, Jira/Confluence IDs

**Không save vào memory và không update bakit khi:**
- Nội dung đã có trong `CLAUDE.md` (global hoặc bakit)
- Đây là one-off instruction chỉ áp dụng cho task hiện tại

Khi apply vào bakit: edit đúng file nguồn trong `~/bakit/`, sau đó chạy `bash ~/bakit/scripts/ba-kit-sync`. Không cần hỏi lại nếu file đích rõ ràng.
