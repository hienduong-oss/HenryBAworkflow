# BA-kit

BA-kit là playbook Business Analysis cho môi trường AI agents (Claude Code, Codex, Antigravity). Biến agent thành một BA có quy trình rõ ràng, artifact có cấu trúc, và handoff đủ chuẩn để không phải "nhắc prompt thủ công" ở mỗi dự án.

## Hai lifecycle

```text
/ba-presale (upstream)                    /ba-start (downstream)
┌─────────────────────────┐              ┌──────────────────────────────┐
│ Phase 0: Bootstrap      │              │ Intake                       │
│ Phase 1: Domain Study   │              │ Backbone                     │
│ Phase 2: Clarify        │──handoff──>  │ FRD / Stories / SRS          │
│ Phase 3: Build          │              │ Wireframe Handoff            │
│ Phase 4: Handoff        │              │ Package                      │
└─────────────────────────┘              └──────────────────────────────┘
```

### `/ba-presale` — Upstream (client-facing deliverables)

Chạy từ client project folder. Auto-derive slug/date từ cwd.

| Phase | Xử lý | Output |
|-------|--------|--------|
| 0 — Bootstrap | Tạo skeleton, classify files | `00_presale/00-inputs/` |
| 1 — Domain Study | Research domain, synthesize primer | `00-domain-primer.md` (VN) |
| 2 — Clarify | Gap analysis, 8-15 questions + suggested answers | `05-clarifications.md` (EN) |
| 3 — Build | WBS + Proposal (parallel), sync-check, auto-render | `.xlsx` + `.docx` |
| 4 — Handoff | Compose intake.md, continuity check | `01_intake/intake.md` |

### `/ba-start` — Downstream (BA artifacts)

| Step | Xử lý | Output |
|------|--------|--------|
| Intake | Parse, normalize, scope lock | `01_intake/intake.md` |
| Backbone | Requirements backbone, portal matrix | `02_backbone/backbone.md` |
| FRD | Functional requirements per module | `03_modules/{module}/frd.md` |
| Stories | User stories + acceptance criteria | `03_modules/{module}/user-stories.md` |
| SRS | Use cases, screen specs, Screen Contract Plus | `03_modules/{module}/srs.md` |
| Wireframes | DESIGN.md + constraint pack + handoff checklist | Manual wireframe handoff |
| Package | Validate + compile HTML | `04_compiled/` |

## Cấu trúc thư mục (trong client project)

```text
plans/
  {slug}-{date}/
    00_presale/           ← /ba-presale output
      00-inputs/
      00-domain-primer.md
      05-clarifications.md
      10-wbs-content.md + .csv
      20-proposal-content.md
      _output/            ← rendered xlsx + docx
      _state-cards/
      _changelog/
    01_intake/            ← handoff bridge
    02_backbone/
    03_modules/
      {module_slug}/
        frd.md
        user-stories.md
        srs.md
        wireframe-input.md
        wireframe-map.md
    04_compiled/

designs/
  {slug}/
    DESIGN.md
```

## Cấu trúc repo BA-kit

```text
bakit/
  core/           ← contract.yaml + contract-behavior.md (canonical)
  rules/          ← workflow, quality, presale standards, diagram style
  agents/         ← agent definitions (presale-lead, wbs-builder, etc.)
  skills/         ← skill + step files (ba-presale, ba-start, ba-do, etc.)
  templates/      ← artifact templates + style spec
  scripts/        ← CLI (ba-kit), utilities, sync scripts
  docs/           ← onboarding docs
  designs/        ← placeholder for DESIGN.md examples
  platform/
    codex/
      CODEX.md    ← entry point for Codex
      agents/     ← Codex agent definitions
      skills/     ← Codex skill definitions
      scripts/    ← Codex installer + asset generator
    gemini/
      GEMINI.md   ← entry point for Antigravity
      scripts/    ← Antigravity installer
  CLAUDE.md       ← entry point for Claude Code
  install.sh      ← Claude Code installer
```

## Cài đặt

### Claude Code

```bash
git clone https://github.com/anhdam2/bakit.git
cd bakit
./install.sh
```

Sau đó restart Claude Code. Assets được sync vào `~/.claude/`.

### Codex

Mở repo trực tiếp trong Codex — dùng ngay qua `platform/codex/CODEX.md`.

Hoặc cài bundle:
```bash
bash platform/codex/scripts/install-codex-ba-kit.sh
```

### Antigravity

```bash
bash platform/gemini/scripts/install-antigravity-ba-kit.sh
```

## Sử dụng

### Presale (từ client project folder)

```text
/ba-presale              ← bootstrap + domain study
/ba-presale clarify      ← gap analysis + questions
/ba-presale build        ← WBS + Proposal (chọn: all / proposal only / WBS only)
/ba-presale handoff      ← bridge sang /ba-start
```

### BA lifecycle

```text
/ba-start backbone
/ba-start frd --module auth
/ba-start stories --module auth
/ba-start srs --module auth
/ba-start wireframes --module auth
/ba-start package
```

### Utilities

```text
/ba-do          ← route freeform BA text
/ba-impact      ← analyze requirement changes
/ba-next        ← detect next step
```

## Nâng cấp

```bash
ba-kit update    # pull + reinstall all runtimes
ba-kit sync      # quick-sync source → ~/.claude/ (no reinstall)
ba-kit doctor    # check runtime readiness
```

## Tài liệu thêm

- [Getting Started](docs/getting-started.md)
- [Codex Setup](docs/codex-setup.md)
- [Skill Catalog](docs/skill-catalog.md)
- [BA Methodology Guide](docs/ba-methodology-guide.md)
