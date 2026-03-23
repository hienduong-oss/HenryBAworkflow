# BA-kit Project Overview

## Summary

BA-kit is a reusable toolkit that equips Claude Code and Codex for professional business analysis work. It standardizes discovery, requirements, process design, compliance review, and document packaging through a curated set of skills, templates, rules, and agent roles.

## Problem Statement

Agent coding environments are usually optimized for software implementation. Business analysis work needs different defaults:
- structured elicitation
- formal and Agile requirement artifacts
- process and stakeholder analysis
- stronger traceability and sign-off discipline
- reusable templates for recurring deliverables

BA-kit closes that gap with a BA-first operating model.

## Objectives

- Make BA workflows repeatable across projects
- Reduce time spent rebuilding templates and checklists
- Improve consistency of requirement quality and acceptance criteria
- Support Agile, Traditional, and Hybrid delivery styles
- Keep deliverables easy to hand off to product, engineering, compliance, and operations teams

## Core Components

| Component | Purpose |
| --- | --- |
| `skills/` | Task-specific BA operating instructions and Codex reference playbooks |
| `agents/` | Specialized delegation roles for parallel execution |
| `rules/` | Workflow, quality, methodology, and documentation standards |
| `templates/` | Ready-to-fill BA deliverable structures |
| `AGENTS.md` | Persistent Codex repository instructions |
| `docs/` | Project-level guidance and catalogs |

## Product Scope

### In Scope

- Discovery and scoping
- Requirements engineering
- Stakeholder analysis
- Process mapping
- Gap, feasibility, SWOT, and cost-benefit analysis
- Compliance-aware BA workflows
- Template-driven documentation

### Out of Scope

- Full project management automation
- Domain-specific regulatory logic beyond starter guidance
- Code generation for implementation teams
- Diagram rendering beyond Mermaid syntax

## Target Users

- business analysts
- product managers doing BA work
- consulting teams running discovery engagements
- solution analysts supporting implementation squads

## Success Metrics

- Users can start with `ba-discovery` and receive a coherent discovery workflow
- Every requirement-oriented skill references acceptance criteria and templates
- Rule files clearly guide lifecycle decisions without depending on software-dev assumptions
- Installation takes less than five minutes in a standard Claude environment
- Codex can use the repo immediately through `AGENTS.md` plus local playbooks

## Design Decisions

1. BA-kit is a standalone toolkit, not a fork of another project.
2. Skills are the primary unit of value; rules and agents reinforce them.
3. Templates are first-class assets because BA deliverables are repeatable.
4. Mermaid is the standard diagram syntax for portability in markdown.
5. Hybrid methodology is the default, with Agile and Traditional branches available when needed.

## Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Skill sprawl creates overlap | Medium | Keep each skill focused and cross-reference related skills |
| Templates become too generic | Medium | Include guidance prompts and related-template links |
| Users bypass quality rules | High | Put mandatory checks into instructions and rules |
| Regulatory guidance is interpreted as legal advice | High | Position compliance content as analysis support, not legal sign-off |

## Acceptance Criteria

- Project structure exists and installs cleanly
- Skill catalog and methodology docs are complete
- Internal cross-references are consistent
- Core BA outputs can be generated from templates without rework
