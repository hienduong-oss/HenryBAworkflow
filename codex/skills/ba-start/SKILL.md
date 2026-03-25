---
name: ba-start
description: Codex-compatible BA entry point for intake normalization, FRD, user stories, SRS, wireframes, and packaging.
---

# BA Start for Codex

This is the Codex conversion of BA-kit's end-to-end business analysis workflow. Use it when starting from raw requirements or when producing formal BA artifacts in this repository.

## Use When

- You have raw requirements in text, markdown, PDF, image, or DOCX form.
- You need a structured BA artifact set, not just a summary.
- The work includes UI-backed scope, traceability, or handoff quality requirements.

## Required Context

Before producing outputs, read the repo instructions and the relevant asset set:

- `AGENTS.md`
- `rules/`
- `templates/`
- `designs/` if screens or states are mentioned

## Workflow

1. Normalize the source into an intake form.
2. Identify gaps and ask targeted clarifying questions.
3. Produce a scoped work plan.
4. Draft FRD and user stories with acceptance criteria.
5. Draft use case specifications.
6. Draft Screen Contract Lite for wireframe input.
7. Generate Pencil wireframes from the use cases and screen contract.
8. Finalize screen descriptions after wireframes exist.
9. Package and quality-check the deliverables into a unified HTML output.

## Delegation Guide

Use Codex subagents when the task is more than a small, single-artifact edit.

| When | Delegate to |
| --- | --- |
| Intake normalization, FRD, user stories, use cases, screen contract, final screen descriptions | `requirements-engineer` |
| Domain, market, standards, or regulatory research | `ba-researcher` |
| Document cleanup, naming, cross-links, packaging | `ba-documentation-manager` |
| Pencil wireframes from SRS screens | `ui-ux-designer` |

## Output Expectations

- Every requirement should have acceptance criteria.
- Use cases should cover primary and alternate flows.
- Wireframes should be generated from Use Cases + Screen Contract Lite before final screen descriptions are expanded.
- Wireframes should use the Shadcn UI design system by default unless the user explicitly requests a different system.
- SRS screen sections should link to requirements, user stories, and wireframes when UI exists.
- Modal, dialog, drawer, and overlay screens that have their own display or behaviour rules should be treated as primary screens with detailed documentation, not as inventory-only supporting frames.
- Supporting wireframe frames for empty/error/loading/toast/inline-message states should exist in `.pen` when implied by the screen behavior, even if they are only listed in the SRS screen inventory and not expanded into full screen detail sections.
- Recommendations should stay tied to business goals, risks, or value.
- Keep the tone concise, decision-ready, and traceable.

## Execution Note

Codex should treat this file as the playbook for BA work in this repo. The actual work should be delegated to the Codex agents under `codex/agents/` when the scope is large enough to benefit from separation of concerns.
