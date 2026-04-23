---
name: ba-presale
description: Upstream presale lifecycle that runs BEFORE /ba-start. Auto-bootstraps the project folder from cwd, synthesizes a Domain Primer, generates 8-15 clarifying questions with agent-suggested answers, builds WBS + Proposal in parallel (auto-rendered to xlsx + docx), then hands off a locked source-of-truth bundle to /ba-start. No --slug/--date flags needed — everything auto-derives from cwd.
argument-hint: "[clarify|build|handoff|status]"
---

# BA Presale

Use this skill for presale work — before requirements are clear enough to start `/ba-start`. Input: raw client material in the project folder. Output: a client-ready WBS (xlsx) + Proposal (docx) + intake.md ready for `/ba-start backbone`.

## Required Read Order

1. Read [../../core/contract.yaml](../../core/contract.yaml) for exact paths, prerequisites, defaults, presale states, and command metadata (`commands.presale_*`, `paths.presale_*`, `presale.*`).
2. Read [../../core/contract-behavior.md](../../core/contract-behavior.md) for shared LLM policy.
3. Read [../../rules/ba-presale-standards.md](../../rules/ba-presale-standards.md) for presale-specific rules.
4. Resolve the selected subcommand.
5. Read only the matching file under `steps/`.
6. Read templates and upstream artifacts only when the active step actually needs them.

## Invocation

All commands auto-derive `slug = basename(cwd)` and `date = today`. No flags required.

```text
/ba-presale            # Bootstrap + Domain Research (auto-chains Phase 0 → 1)
                       # Phase 0: scan cwd, classify into 00-inputs/, create skeleton
                       # Phase 1: read inputs, WebSearch if domain unfamiliar,
                       #          synthesize Domain Primer (Vietnamese)
                       # STOPS at USER GATE for research review.

/ba-presale clarify    # Gap Analysis + Clarifying Questions
                       # Phase 2: run gap analysis across 8 BA categories,
                       #          generate 8-15 English clarifying questions,
                       #          agent auto-suggests best-guess answer per question,
                       #          interactive loop to review/edit/answer.
                       # STOPS at USER GATE (≥80% answered to advance).

/ba-presale build      # WBS + Proposal + Auto-Render
                       # Phase 3: dispatch wbs-builder + proposal-writer in parallel,
                       #          run sync-check inline (Opus), resolve conflicts,
                       #          auto-render xlsx (WBS + Clarifications + Summary)
                       #          and docx (Proposal v4.0 §1-§11).
                       # Content: English. STOPS at USER GATE for xlsx/docx review.

/ba-presale handoff    # Bridge to /ba-start
                       # Phase 4: compose intake.md + plan.md directly from presale
                       #          artifacts (no re-ask), mirror sources into _sources/,
                       #          run continuity check (WBS ↔ Proposal ↔ intake),
                       #          block on any inconsistency.

/ba-presale status     # Read-only inspection (phase, artifact freshness, next command)
```

### Bare prompts during a user gate

- After `/ba-presale` (Phase 1 gate) — bare prompts probe findings or edit the Domain Primer in place. Explicit `/ba-presale clarify` advances.
- After `/ba-presale clarify` (Phase 2 gate) — bare prompts edit clarifications (inline answer / edit suggested / add / remove). "accept all suggestions" mass-accepts. Explicit `/ba-presale build` advances.
- After `/ba-presale build` (Phase 3 gate) — bare prompts trigger surgical edits on WBS or Proposal markdown source + auto re-render affected output. No feedback history tracked.

## Step Dispatch

| Command | Read next | Notes |
| --- | --- | --- |
| no subcommand | `steps/bootstrap.md`, then auto-chain `steps/domain-study.md` | stops at user gate after domain study |
| `clarify` | `steps/clarify.md` | gap analysis + 8–15 questions, interactive answer loop |
| `build` | `steps/build.md` | WBS + Proposal + sync-check + auto-render in one phase |
| `handoff` | `steps/handoff.md` | compose intake.md from presale, continuity check |
| `status` | `steps/status.md` | read-only inspection |

## Lifecycle Engine

| State | Owner | Model | Output | Gate |
|-------|-------|-------|--------|------|
| 0 — bootstrap | presale-lead | sonnet | `00_presale/00-inputs/` organized | auto-chain to domain-study |
| 1 — domain-study | presale-lead + WebSearch | **opus** | `00-domain-primer.md` (VN) | **USER GATE** |
| 2 — clarify | presale-lead | **opus** | `05-clarifications.md` (EN) | **USER GATE** |
| 3 — build | wbs-builder ‖ proposal-writer + lead sync | sonnet ×2 + opus | `10-wbs-content.md` (+csv), `20-proposal-content.md`, `_output/*.xlsx`, `_output/*.docx` | **USER GATE** |
| 4 — handed-off | presale-lead | sonnet | `01_intake/intake.md` + `plan.md` + manifest + `_sources/` | continuity check |

## Fast Execution Contract

1. Auto-derive `slug` + `date` from cwd — never ask user.
2. Print a pre-run description block (English, short) before each phase; wait for `ok`.
3. Enforce prerequisites from `core/contract.yaml` `commands.presale_*.requires`.
4. Enforce user gates — do not auto-advance past `domain-study`, `clarify`, `build`, or `handoff`.
5. Stop on ambiguity instead of guessing.
6. Ask before overwriting any mutable target.
7. `build` auto-renders xlsx + docx (no separate render command).
8. Surgical edits after build re-render only the affected file (xlsx OR docx).

## Language Policy

| Artifact | Language |
|----------|----------|
| Domain Primer (`00-domain-primer.md`) | **Vietnamese** |
| Clarifications (`05-clarifications.md`) | **English** (client-facing) |
| WBS (`10-wbs-content.md`) + xlsx | **English** (client-facing) |
| Proposal (`20-proposal-content.md`) + docx | **English** (client-facing) |
| State cards (`_state-cards/*`) | **Vietnamese** (internal) |
| Agent summaries to user | **Vietnamese** |
| Command descriptions (this file, pre-run blocks) | **English** |
| `intake.md` + `plan.md` (after handoff) | **Vietnamese** (matches /ba-start defaults) |

## Stop Conditions

- Never recall past projects. Engine = single source of truth per workspace.
- Never inline templates into delegation packets — reference paths only.
- Never delegate assembly, merge, render dispatch, conflict arbitration, or handoff.
- Never auto-advance past a user gate.
- Never resolve WBS↔Proposal conflicts by "stronger side" — anchor to requirement source priority (inputs > clarifications > primer > assumption).
- Never render xlsx/docx independently of `build` — render is integrated into build + auto re-rendered on surgical edit.
- Never persist feedback history — surgical edits apply immediately, only sync-check arbitrations are logged in `_changelog/`.
- Block handoff if the continuity check fails.

## Shared References

- [../../core/contract.yaml](../../core/contract.yaml)
- [../../templates/domain-primer-template.md](../../templates/domain-primer-template.md)
- [../../templates/clarifications-template.md](../../templates/clarifications-template.md)
- [../../templates/wbs-template.md](../../templates/wbs-template.md)
- [../../templates/wbs-template.csv](../../templates/wbs-template.csv)
- [../../templates/proposal-template.md](../../templates/proposal-template.md)
- [../../templates/proposal-guide.md](../../templates/proposal-guide.md)
- [../../templates/output-style-spec.json](../../templates/output-style-spec.json)
- [../../agents/presale-lead.md](../../agents/presale-lead.md)
- [../../agents/wbs-builder.md](../../agents/wbs-builder.md)
- [../../agents/proposal-writer.md](../../agents/proposal-writer.md)
- [../../rules/ba-presale-standards.md](../../rules/ba-presale-standards.md)
