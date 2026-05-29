<!--
TEMPLATE: WBS Content (markdown source of truth)
PURPOSE: Lightweight, edit-friendly WBS used during iteration. Auto-rendered to xlsx after /ba-presale build sync-check passes.
LOCATION (per project): plans/{slug}-{date}/00_presale/10-wbs-content.md
PAIRED WITH: 10-wbs-content.csv (CSV intermediate for xlsx render)
LANGUAGE: English (client-facing artifact).

═══════════════════════════════════════════════════════
WBS BREAK MODE — must be declared at top of every WBS file
═══════════════════════════════════════════════════════

Two modes are supported. Mode is chosen by user during /ba-presale build (Pre-run step).
Declare in the WBS file header: **Mode: A — feature-ui** or **Mode: B — epic-component**

MODE A — feature-ui (default)
  Purpose: stakeholder communication, requirements traceability, UC/AC authoring.
  Break axis: domain category → feature → actor action.
  Unit: 1 row = 1 actor + 1 action + 1 observable outcome.
  Actor split: when a feature has distinct FE and BE work, suffix ID with a/b.
    1.1a = FE/mobile row (Actor = "User (App)" or "Admin")
    1.1b = BE/System row (Actor = "System")
  Complexity: BE complexity captured in Notes column — not broken into sub-tasks.
  Columns (xlsx): # | Category | Function | Sub-Function | Actor | Notes | Web/mobile (day) | Backend (day)
  See output-style-spec.json xlsx.sheets.WBS for full spec.

MODE B — epic-component
  Purpose: sprint planning, dev task assignment, delivery tracking.
  Break axis: phase → epic (technical layer) → deliverable task (FE task / BE task / SC task / DevOps task).
  Unit: 1 row = 1 deliverable that can be built, tested, and done independently.
  Key difference from Mode A: BE complexity is ALWAYS broken into separate rows — no hiding in Notes.
    Each row tagged with layer: [Mobile] | [FE] | [BE] | [SC] | [DevOps] | [QC]
    Cross-cutting epics (Infra, Smart Contract, QA) are first-class epics, not footnotes.
  Columns (xlsx): # | Phase | Epic | Task Name | Layer | Notes | PM | BA | SC | BE | DevOps | Mobile | FE | QC | Total MD
  See output-style-spec.json xlsx.sheets.WBS_mode_b for full spec.

WHEN TO USE WHICH MODE:
  Mode A → client review, requirements sign-off, UC/story authoring input
  Mode B → dev team planning, sprint breakdown, resource allocation
  Both can coexist in the same project as separate files:
    10-wbs-content.md      (Mode A — requirements view)
    10-wbs-content-dev.md  (Mode B — delivery view)

═══════════════════════════════════════════════════════
MARKDOWN WBS — 7 columns (both modes, planning fields):
  WBS ID | Milestone | EPIC | Feature / Function | Actor | Description | Dependencies

XLSX OUTPUT — columns differ by mode (see above).
Note: Milestone and Dependencies are markdown-only fields — omit from xlsx output.
═══════════════════════════════════════════════════════

EPIC ROW CONVENTION (both modes):
  - WBS ID = integer only (1, 2, 3, 4)
  - EPIC = ALL CAPS name
  - All other columns = LEAVE EMPTY

FEATURE ROW CONVENTION — MODE A:
  - WBS ID = decimal (1.1, 1.2, 2.1, ...)
  - Actor-boundary split: suffix a/b when FE and BE work are distinct
  - 1 row = 1 actor + 1 action + 1 observable outcome
  - Actor = specific: "User (App)", "Group Admin", "System", "Tech Lead", "BA", "DevOps"
  - Description / Sub-Function = actor-perspective acceptance condition: "Actor does X and sees Y"
  - Notes (xlsx) = full behavioral spec + edge cases + [src:...] refs

FEATURE ROW CONVENTION — MODE B:
  - WBS ID = decimal (1.1, 1.2, 2.1, ...)
  - Layer tag prefix in Task Name: "[Mobile]", "[FE]", "[BE]", "[SC]", "[DevOps]", "[QC]"
  - 1 row = 1 deliverable — independently buildable, testable, assignable
  - No collapsing BE complexity into Notes — every distinct BE sub-task = its own row
  - Cross-cutting epics (Infra, Smart Contract, QA) = dedicated EPICs, not sub-rows of feature epics
  - Notes (xlsx) = technical scope boundary + [src:...] refs

TRACEABILITY RULE (CRITICAL — see ba-presale-standards.md §5):
- Every feature row MUST have a source ref in Description or Notes.
- Format: [src:client:<file>§<sec>] | [src:domain:§<n>] | [src:clarify:Q<n>] | [src:assumption:A<n>]
- Missing source ref → row blocked from auto-render.
-->

# WBS — {{client_name}} / {{project_name}}

> **Status:** {{draft|reviewed|LOCKED}}
> **Version:** v{{X.Y}} — {{YYYY-MM-DD}}
> **Milestones:** M1 / M2 / M3 / M4

---

## WBS Table

| WBS ID | Milestone | EPIC | Feature / Function | Actor | Description | Dependencies |
|--------|-----------|------|--------------------|-------|-------------|--------------|
| 1 | M1 | DISCOVERY & ARCHITECTURE | | | | |
| 1.1 | M1 | Discovery | Review client documents and confirm scope | BA, Client PO | BA reviews all input documents and confirms integration mechanism and scope boundaries [src:client:RFP§1] | — |
| 1.2 | M1 | Discovery | Architecture Decision Record | Tech Lead | Document confirmed decisions: mechanism, identity, integrations [src:domain:§2] | 1.1 |
| 2 | M2 | {{EPIC 2 NAME}} | | | | |
| 2.1 | M2 | {{Feature Group}} | {{Feature or function name}} | {{Actor}} | {{Actor does X and sees Y}} [src:clarify:Q1] | 1.2 |
| 3 | M3 | {{EPIC 3 NAME}} | | | | |
| 3.1 | M3 | {{Feature Group}} | {{Feature or function name}} | {{Actor}} | {{System pushes Z to W}} [src:assumption:A1] | 2.1 |
| 4 | M4 | {{EPIC 4 NAME}} | | | | |
| 4.1 | M4 | {{Feature Group}} | {{Feature or function name}} | {{Actor}} | {{Actor sees confirmation screen}} [src:client:RFP§4] | 3.1 |

---

## Scope Summary

**In-scope:**
- {{bullet list}}

**Out-of-scope:**
- {{bullet list}}

## Assumptions

| ID | Description | Affects rows |
|----|-------------|--------------|
| A1 | {{...}} | {{2.1, 3.1}} |

## External Dependencies

- {{Third party / client must provide X before milestone Y}}

---

## WBS Content Rules

These rules apply to **both** the markdown WBS (this file) and the WBS table inside the Proposal. The only difference is that the Proposal WBS omits the effort columns.

Rules are split by mode. Declare mode at top of file before applying rules.

---

### MODE A — feature-ui rules

#### Row atomicity

1 row = 1 actor + 1 action + 1 observable outcome.

If Notes/Description needs "and then" / "also" / "as well as" → split into 2 rows.

#### When to create a new EPIC

Create a new EPIC when the feature group:
- Serves a **distinct user journey**
- Has a **different primary actor** (user-facing vs admin-facing vs system-level)
- Has a **clear dependency boundary** — all rows in this EPIC must complete before the next EPIC starts

Do not create a new EPIC just because features "seem different."

#### When to split into a new feature row

Split when:
- Actor differs ("Admin creates X" vs "System sends notification Y")
- Trigger differs ("User submits form" vs "System validates form")
- Screen/state differs ("User sees list" vs "User sees detail")
- Can fail independently in UAT

**Actor-boundary split (CRITICAL):** When a feature has distinct FE/mobile work AND distinct BE/System work, split into 2 rows — one per actor. Do NOT collapse into a single row and rely on G/H columns to carry both sides.
- Row `N.Xa`: Actor = "User (App)" or "Admin" — G col carries FE effort, H = 0
- Row `N.Xb`: Actor = "System" — G = 0, H col carries BE effort
- Sub-Function for each row describes what THAT actor does and sees, not the combined flow
- Example: "Bot Start Flow" → `3.2a`: User taps Deposit, approves 3 wallet txs, sees position added (G=3, H=0) / `3.2b`: System registers Bot with wl_code, updates position list (G=0, H=2)
- If a feature splits into more than 2 actor rows, continue suffix: `N.Xa`, `N.Xb`, `N.Xc`

Do not split when:
- Sub-steps of the same action by the same actor (e.g. validate field A + B → one "Form validation" row)
- FE and BE are trivially coupled with no independent failure mode (e.g. a read-only display field backed by a simple GET)

#### Function vs Sub-Function depth

**Function** = feature-card level — PM-readable without context.
- Correct: `Add Order tab to TabBar`
- Too detailed: `Modify TabBar.swift line 42`
- Too vague: `App changes`

**Sub-Function / Description** = actor-perspective acceptance condition — dev knows when it's done.
- Correct: `User sees Order tab in TabBar; tapping opens OrderVC`
- Wrong (repeats Function): `Add Order tab`
- Wrong (implementation detail): `Set tabBarItem.image = UIImage(named: "order_icon")`

**Notes** = full behavioral spec + edge cases + `[src:...]` refs. No implementation detail.

#### Actor convention

Use the most specific actor possible:
- `User (App Name)` — not just `User` when multiple user types exist
- `Group Admin` — not `Admin` if only group admins can perform the action
- `System` — for background jobs, auto-triggers, server-to-server calls
- `Tech Lead` — for ADR, architecture decisions, setup tasks
- `BA` — for discovery, clarification, spec review tasks

If 2 actors are genuinely needed → split into 2 rows.

#### Effort columns (xlsx only)

- Fill both Web/mobile (G) and Backend (H). Use `0` for the inapplicable side — never leave blank.
- Leave `0` in both when unestimated — estimator fills later.

---

### MODE B — epic-component rules

#### Row atomicity

1 row = 1 deliverable that can be built, tested, and marked done independently.

A deliverable is independently done when: it can be code-reviewed separately, has its own failure mode in UAT, and can be assigned to one person without blocking another row in the same epic.

If a task description needs "and also" / "plus" / "as well as" → split into 2 rows.

#### When to create a new EPIC

Create a new EPIC when the task group:
- Is a **cross-cutting concern** (Infrastructure, Smart Contract, QA, DevOps) — always its own EPIC regardless of size
- Belongs to a **distinct technical layer** with its own dependency boundary
- Has a **different primary layer tag** and cannot be delivered incrementally with another group

Cross-cutting EPICs are **mandatory** — never fold Infra, SC, or QA tasks into feature EPICs.

#### Layer tags (REQUIRED on every feature row)

Every row in Mode B MUST start Task Name with a layer tag:

| Tag | Covers |
|-----|--------|
| `[Mobile]` | Mobile PWA / native app UI + client logic |
| `[FE]` | Admin web frontend / desktop web UI |
| `[BE]` | Backend API, workers, jobs, data layer |
| `[SC]` | Smart contract design, implementation, audit |
| `[DevOps]` | Infrastructure, CI/CD, environments, monitoring |
| `[QC]` | Test plans, E2E, UAT, security review |
| `[PM]` | Project management, coordination, sign-off |
| `[BA]` | Discovery, spec review, clarification tasks |

#### When to split into a new row

Split when:
- Layer differs — `[Mobile]` and `[BE]` work for the same feature = 2 rows minimum
- BE complexity has multiple independent sub-tasks — each sub-task = its own `[BE]` row
  - Example: "Bot Start" → `[BE] Bot relay endpoint + wl_code validation` / `[BE] HMAC signing + nonce dedup` / `[BE] Position mirror upsert after register`
- Cross-cutting work exists — `[DevOps]` provisioning is never folded into a `[BE]` feature row

**Anti-pattern (CRITICAL):** Do NOT write `[BE] Register bot + HMAC signing + nonce + position mirror` as one row. Each distinct BE sub-task that can fail independently = its own row.

Do not split when:
- Two trivially coupled steps with no independent failure mode (e.g. `[BE] Read config + return response` — one GET handler, one row)

#### Task Name depth

**Task Name** = deliverable-level — dev knows what to build without reading Notes.
- Correct: `[BE] HMAC-SHA256 signing + nonce dedup TTL`
- Too vague: `[BE] Auth stuff`
- Too detailed: `[BE] Add hmac_sign() function to utils/crypto.ts line 42`

**Notes** = technical scope boundary + constraints + `[src:...]` refs. No implementation detail (no function names, no file paths).

#### Effort columns (xlsx only)

Multi-role columns: PM | BA | SC | BE | DevOps | Mobile | FE | QC | Total MD.
- Fill only the column matching the row's layer tag. All other role columns = `0`.
- Total MD = sum of all role columns for that row.
- Leave `0` when unestimated — estimator fills later.
- Never leave blank — always use `0`.

---

<!-- RENDER HINT:
When rendering via document-skills:xlsx:

MODE A (feature-ui):
- Sheet "WBS" = main table from CSV (8-column format: # | Category | Function | Sub-Function | Actor | Notes | Web/mobile (day) | Backend (day))
- Sheet "Clarifications" = parsed from 05-clarifications.md
- Sheet "Summary" = milestone groupings from WBS markdown §3
- Sheet "Assumptions" = from Assumptions section above
- EPIC rows (integer WBS ID): bold + fill color, no data in Feature/Actor/Description/Dependencies
- Feature rows (decimal WBS ID): normal weight
- Freeze panes: row 1 (header)
- Style spec: output-style-spec.json xlsx.sheets.WBS

MODE B (epic-component):
- Sheet "WBS" = main table from CSV (15-column format: # | Phase | Epic | Task Name | Layer | Notes | PM | BA | SC | BE | DevOps | Mobile | FE | QC | Total MD)
- Sheet "Clarifications" = same as Mode A
- Sheet "Summary" = phase totals + per-role totals
- Sheet "Assumptions" = same as Mode A
- EPIC rows (integer WBS ID): bold + fill color
- Feature rows (decimal WBS ID): normal weight, Layer column color-coded by tag
- Freeze panes: row 1 (header)
- Style spec: output-style-spec.json xlsx.sheets.WBS_mode_b
-->
