---
name: ba-presale
description: Upstream presale lifecycle that runs BEFORE /ba-start. Auto-bootstraps the project folder from cwd, synthesizes a Domain Primer, generates 8-15 clarifying questions with agent-suggested answers, builds WBS + Proposal in parallel (auto-rendered to xlsx + docx), then hands off a locked source-of-truth bundle to /ba-start. No --slug/--date flags needed — everything auto-derives from cwd.
argument-hint: "[clarify|build|handoff|status]"
---

# BA Presale

Use this skill for presale work — before requirements are clear enough to start `/ba-start`. Input: raw client material in the project folder. Output: a client-ready WBS (xlsx) + Proposal (docx) + intake.md ready for `/ba-start backbone`.

## Required Read Order

1. Read [../../core/contract.yaml](../../core/contract.yaml) — exact paths, prerequisites, presale states, command metadata.
2. Read [../../core/contract-behavior.md](../../core/contract-behavior.md) — shared LLM policy.
3. Read [../../rules/ba-presale-standards.md](../../rules/ba-presale-standards.md) — presale rules, language policy, stop conditions.
4. Resolve the selected subcommand.
5. Read only the matching file under `steps/`.
6. Read templates and upstream artifacts only when the active step needs them.

## Invocation

All commands auto-derive `slug = basename(cwd)` and `date = today`. No flags required.

```text
/ba-presale            # Phase 0 (bootstrap) → auto-chain Phase 1 (domain study) → USER GATE
/ba-presale clarify    # Phase 2: gap analysis + 8-15 clarifying questions → USER GATE
/ba-presale build      # Phase 3: WBS + Proposal (parallel) + sync-check + auto-render → USER GATE
/ba-presale handoff    # Phase 4: compose intake.md from presale artifacts + continuity check
/ba-presale status     # Read-only: phase, artifact freshness, next command
```

### Bare prompts during a user gate

- Phase 1 gate — bare prompts probe findings or edit the Domain Primer. `/ba-presale clarify` advances.
- Phase 2 gate — bare prompts edit clarifications (answer / edit / add / remove). "accept all suggestions" mass-accepts. `/ba-presale build` advances.
- Phase 3 gate — bare prompts trigger surgical edits on WBS or Proposal + auto re-render affected output only.

## Step Dispatch

| Command | Read next | Notes |
| --- | --- | --- |
| no subcommand | `steps/bootstrap.md` → auto-chain `steps/domain-study.md` | stops at user gate after domain study |
| `clarify` | `steps/clarify.md` | gap analysis + 8–15 questions, interactive answer loop |
| `build` | `steps/build.md` | WBS + Proposal + sync-check + auto-render in one phase |
| `handoff` | `steps/handoff.md` | compose intake.md from presale, continuity check |
| `status` | `steps/status.md` | read-only inspection |

## Fast Execution Contract

1. Auto-derive `slug` + `date` from cwd — never ask user.
2. Print a pre-run description block (English, short) before each phase; wait for `ok`.
3. Enforce prerequisites from `core/contract.yaml` `commands.presale_*.requires`.
4. Enforce user gates — do not auto-advance past `domain-study`, `clarify`, `build`, or `handoff`.
5. Stop on ambiguity instead of guessing.
6. Ask before overwriting any mutable target.
7. `build` auto-renders xlsx + docx — no separate render command.
8. Surgical edits after build re-render only the affected file (xlsx OR docx).
