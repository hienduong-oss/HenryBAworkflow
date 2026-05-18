<!--
TEMPLATE: WBS Content (markdown source of truth)
PURPOSE: Lightweight, edit-friendly WBS used during iteration. Auto-rendered to xlsx after /ba-presale build sync-check passes.
LOCATION (per project): plans/{slug}-{date}/00_presale/10-wbs-content.md
PAIRED WITH: 10-wbs-content.csv (CSV intermediate for xlsx render)
LANGUAGE: English (client-facing artifact).

TWO FORMATS — same content, different columns:

MARKDOWN WBS (this file) — 7 columns, includes planning fields:
  WBS ID | Milestone | EPIC | Feature / Function | Actor | Description | Dependencies

XLSX OUTPUT (Google Sheets) — 8 columns, drops Milestone/Dependencies, splits Description:
  # | Category | Function | Sub-Function | Actor | Notes | Web/mobile (day) | Backend (day)
  See output-style-spec.json xlsx.sheets.WBS for full column spec and formatting rules.

EPIC ROW CONVENTION (both formats):
  - WBS ID = integer only (1, 2, 3, 4)
  - EPIC = ALL CAPS name
  - All other columns = LEAVE EMPTY

FEATURE ROW CONVENTION (both formats):
  - WBS ID = decimal (1.1, 1.2, 2.1, ...)
  - 1 row = 1 actor + 1 action + 1 observable outcome
  - Actor = specific: "User (App)", "Group Admin", "System", "Tech Lead", "BA", "DevOps"
  - Description / Sub-Function = actor-perspective acceptance condition: "Actor does X and sees Y"
  - Notes (xlsx) = full behavioral spec + edge cases + [src:...] refs

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

These rules apply to **both** the markdown WBS (this file) and the WBS table inside the Proposal. The only difference is that the Proposal WBS omits the effort columns (Web/mobile day, Backend day).

### Row atomicity

1 row = 1 actor + 1 action + 1 observable outcome.

If Notes/Description needs "and then" / "also" / "as well as" → split into 2 rows.

### When to create a new EPIC

Create a new EPIC when the feature group:
- Serves a **distinct user journey**
- Has a **different primary actor** (user-facing vs admin-facing vs system-level)
- Has a **clear dependency boundary** — all rows in this EPIC must complete before the next EPIC starts

Do not create a new EPIC just because features "seem different."

### When to split into a new feature row

Split when:
- Actor differs ("Admin creates X" vs "System sends notification Y")
- Trigger differs ("User submits form" vs "System validates form")
- Screen/state differs ("User sees list" vs "User sees detail")
- FE/BE effort significantly different (split to make estimation clearer)
- Can fail independently in UAT

Do not split when:
- Sub-steps of the same action (e.g. validate field A + B → one "Form validation" row)
- FE and BE of the same feature (use effort cols G/H)

### Function vs Sub-Function depth

**Function** = feature-card level — PM-readable without context.
- Correct: `Add Order tab to TabBar`
- Too detailed: `Modify TabBar.swift line 42`
- Too vague: `App changes`

**Sub-Function / Description** = actor-perspective acceptance condition — dev knows when it's done.
- Correct: `User sees Order tab in TabBar; tapping opens OrderVC`
- Wrong (repeats Function): `Add Order tab`
- Wrong (implementation detail): `Set tabBarItem.image = UIImage(named: "order_icon")`

**Notes** = full behavioral spec + edge cases + `[src:...]` refs. No implementation detail.

### Actor convention

Use the most specific actor possible:
- `User (App Name)` — not just `User` when multiple user types exist
- `Group Admin` — not `Admin` if only group admins can perform the action
- `System` — for background jobs, auto-triggers, server-to-server calls
- `Tech Lead` — for ADR, architecture decisions, setup tasks
- `BA` — for discovery, clarification, spec review tasks

If 2 actors are genuinely needed → split into 2 rows.

### Effort columns (xlsx only)

- Fill both Web/mobile (G) and Backend (H). Use `0` for the inapplicable side — never leave blank.
- Leave `0` in both when unestimated — estimator fills later.

---

<!-- RENDER HINT:
When rendering via document-skills:xlsx:
- Sheet "WBS" = main table from CSV (7-column format)
- Sheet "Clarifications" = parsed from 05-clarifications.md
- Sheet "Summary" = milestone groupings from WBS table
- Sheet "Assumptions" = from Assumptions section above
- EPIC rows (integer WBS ID): bold + fill color, no data in Feature/Actor/Description/Dependencies
- Feature rows (decimal WBS ID): normal weight
- Freeze panes: row 1 (header)
-->
