# BA-kit Project Overview

## Summary

BA-kit is a reusable toolkit that equips Claude Code and Codex for professional business analysis work. It standardizes a solo-IT-BA-friendly lifecycle from raw input to packaged deliverables through a single unified skill, focused agent roles, reusable templates, and workflow rules.

## Problem Statement

Agent coding environments are usually optimized for software implementation. Business analysis work needs different defaults:
- structured elicitation and intake normalization
- a single persisted source of truth before formal and Agile requirement artifacts are emitted
- traceability from business goals to test cases
- reusable templates for recurring deliverables
- wireframe constraint packs for UI-backed scope

BA-kit closes that gap with a BA-first operating model.

## Objectives

- Make BA workflows repeatable across projects
- Reduce duplicated writing for solo analysts
- Reduce time spent rebuilding templates and checklists
- Improve consistency of requirement quality and acceptance criteria
- Support Agile, Traditional, and Hybrid delivery styles
- Keep deliverables easy to hand off to product, engineering, and operations teams

## Core Components

| Component | Purpose |
| --- | --- |
| `skills/ba-presale/` | Upstream presale lifecycle: domain study, clarifications, WBS + Proposal generation, handoff to `/ba-start` |
| `skills/ba-start/` | Single unified BA skill covering intake, backbone-first analysis, gated artifact emission, and packaging |
| `agents/` | 5 specialized delegation roles: presale-lead, wbs-builder, proposal-writer, requirements-engineer, ui-ux-designer, ba-documentation-manager, ba-researcher |
| `rules/` | Workflow, quality, and presale standards |
| `templates/` | BA deliverable structures including the requirements backbone |
| `designs/` | Project runtime `DESIGN.md` files that constrain manual wireframing and external design handoff |
| `CODEX.md` | Persistent Codex repository instructions |
| `CLAUDE.md` | Claude Code project instructions |

## Product Scope

### In Scope

- Presale deliverables: domain primer, clarifications, WBS, Proposal (xlsx + docx)
- Presale-to-BA handoff via intake bridge
- Intake normalization and gap analysis
- Requirements backbone and gated requirements engineering (FRD, SRS)
- User story generation
- Critical-screen-first wireframe constraint preparation for UI-backed scope
- Quality review and packaging
- Template-driven documentation

### Out of Scope

- Full project management automation
- Domain-specific regulatory logic beyond starter guidance
- Code generation for implementation teams
- Diagram rendering beyond Mermaid syntax

## Target Users

- Business analysts
- Product managers doing BA work
- Consulting teams running discovery engagements
- Solution analysts supporting implementation squads

## Success Metrics

- Users can start with `/ba-start` and receive a complete BA workflow
- Every requirement has acceptance criteria
- Installation takes less than five minutes
- Codex can use the repo immediately through `CODEX.md`

## Design Decisions

1. BA-kit uses a single unified skill instead of many disconnected skills.
2. The requirements backbone is the default authoring source after intake.
3. Four focused agent roles handle delegation without overlap.
4. Templates are first-class assets because BA deliverables are repeatable.
5. Mermaid is the standard diagram syntax for portability in markdown.
6. Hybrid methodology is the default for solo IT BA work.
7. SRS and wireframes are gated by real handoff, UI, and risk needs instead of always being emitted in full.

## Acceptance Criteria

- Project structure exists and installs cleanly
- Skill, agents, rules, and templates are internally consistent
- Cross-references between files are valid
- Core BA outputs can be generated from templates without rework
