# BA Start Step - FRD

## Checkpoint

Write `plans/{slug}-{date}/_checkpoint.md` as the **first action** before reading any artifact:
```
step: frd
status: running
command: <exact invoked command>
started: <ISO timestamp>
updated: <ISO timestamp>
progress: ""
last_write: ""
resume_hint: ""
```
After each incremental use-case write, update `progress` (e.g., "UC-03/7 done"), `last_write`, and `resume_hint` (e.g., "Continue from UC-04").
On complete, update `status: completed` and `updated`.

This step requires:

- `core/contract.yaml`
- `core/contract-behavior.md`

## Memory Read Scope

- **Must read:** `core/contract.yaml`, `core/contract-behavior.md`, `paths.backbone_index`, `paths.plan` (when exists)
- **May read:** targeted `paths.backbone` sections routed by the index, `paths.project_memory` or (`paths.memory_hot_vocabulary` + `paths.memory_hot_decisions`) when shard mode is active
- **Must NOT read:** `log.md`, `cold/`, `warm/` shards, unrelated module shards

## Governance Gate

Before mutating this artifact:
1. **Skip this gate for first-pass creation** (when `paths.frd` does not yet exist).
2. For reruns (artifact already exists): verify write authority and locate the active impact receipt at `paths.impact_receipt`. If no active receipt exists and `change_class` is not `wording-only`, emit `GOVERNANCE_BLOCK: impact_receipt missing or invalidated` and stop.
3. If either check fails on a rerun: emit `GOVERNANCE_BLOCK: {reason}` and stop.
4. After mutation completes: offer to file the change into canonical memory using `templates/project-memory-fileback-record-template.md`.

Receipt reference: `templates/impact-receipt-template.md`

## Scope

Run Step 6 only.

## Prerequisites

- Resolve slug, date, and module using the shared contract.
- Require `paths.backbone`.
- Prefer `paths.backbone_index` for routing. If it is missing and the backbone is large, stop and ask to refresh the index.
- If backbone is missing, print the exact missing path and stop.
- Trust accepted user intent. Do not reopen scope discovery after FRD execution is accepted.
- Run a narrow FRD preflight:
  - If `ba-kit guardrail --command frd --slug <slug> --date <date> --module <module>` returns `status=block`, surface the block message and stop
  - Otherwise use `ALLOW_READS` for file discovery
  - read `paths.backbone_index` first
  - read only targeted `paths.backbone` sections and `paths.plan` when it exists
  - do not scan unrelated module folders once slug, date, and module are resolved

## Output

- `paths.frd`

## Step 6 — Produce FRD

Produce the FRD from the backbone using [../../../templates/frd-template.md](../../../templates/frd-template.md).

### 6.2 — FRD Sections

- Functional overview
- User personas (role-specific — no generic "User" or "Admin")
- Feature list with MoSCoW priorities
- Use Case Specifications (Wiegers/IIBA 13-field, one UC per sea-level goal)
- Workflows (Mermaid sequence or activity diagram)
- Data requirements
- Business rules (numbered BR-{n}, separate from UC flow steps)
- Integration points
- Acceptance criteria (linked to UC postconditions)

### 6.3 — Use Case Rules (MANDATORY)

**UC Naming:** `[action verb] + [object]` format. UC ID: `UC-{module}-{seq}` (e.g., `UC-AUTH-01`). Vague verbs (`manage`, `handle`, `process`) are NOT acceptable.

**Scope guard (Cockburn coffee-break test):** If a UC cannot be completed in one user session, it is kite-level — split into sea-level UCs. If a UC is a single click with no decision, it is fish-level — merge upward.

**Normal Course rules:**
- Numbered steps, alternating actor action / system response
- One action per step
- No embedded `if/else` — branching goes to Alternative Courses
- Steps run from trigger (precondition met) to postcondition (goal achieved)

**Alternative Courses:** Each alternative references the step it branches from (`{step_number}{letter}` — e.g., `3a`). Must state: trigger condition → steps → rejoins or ends.

**Exceptions:** Each exception states: trigger → system response → final state (success, failure, or pending). Cover at minimum: authentication failure, validation failure, system/integration error.

**Quality gate — 20-point checklist (before marking UC complete):**

| # | Check |
|---|-------|
| C1 | UC name uses verb + object format |
| C2 | Scope passes coffee-break test (sea-level) |
| C3 | UC-ID is unique within the module |
| C4 | Exactly 1 primary actor |
| C5 | System boundary is clear (what is inside vs. outside) |
| C6 | Actor is a specific role, not generic "User" |
| C7 | Description answers WHY / WHAT / expected outcome |
| C8 | Frequency of use is stated |
| C9 | Preconditions are verifiable (not assumptions) |
| C10 | Postconditions describe final system state for all outcomes |
| C11 | Assumptions are separate from preconditions |
| C12 | Normal Course steps are numbered, one action each |
| C13 | Actor and system actions alternate (no merged steps) |
| C14 | No embedded conditionals in Normal Course |
| C15 | Normal Course runs from trigger to postcondition without gaps |
| C16 | Each Alternative Course references a specific step + condition |
| C17 | Each Exception has trigger + system response + final state |
| C18 | Common failure modes are covered (auth, validation, system error) |
| C19 | Included sub-UCs exist and are valid |
| C20 | Special Requirements are non-functional only (no flow logic) |

### 6.4 — Execution Rules

- Start from `paths.backbone_index`, then the exact targeted backbone sections, plus the exact plan path when it exists.
- In `hybrid` mode, keep the FRD concise and focused on features, workflows, business rules, and integration-relevant context. Emit full UC specs only for complex or risky flows.
- In `lite` mode, emit the FRD only when the user explicitly asks for it.
- Write incrementally: one UC at a time. Update checkpoint `progress` after each UC.
- Do NOT write a UC that fails the 20-point checklist — fix first, then write.

Save to `paths.frd`.

## Memory Capture

After FRD is approved by user, promote to project memory:

| What to capture | Target shard | Trigger |
|---|---|---|
| Business rules that override or extend backbone decisions | `hot/approved-decisions.md` (MEM-DEC) | When BR contradicts or refines a backbone decision |
| Actor-specific workflow decisions (e.g., actor X cannot do Y) | `warm/modules/{module_slug}.md` | Per module, when UC flow is locked |
| Integration constraints confirmed during FRD | `warm/modules/{module_slug}.md` | When integration point is locked |
| Push-back triggers from FRD review (scope items rejected) | `hot/pushback-triggers.md` | When user explicitly rejects a UC or BR |

Set `Confidence: high` for user-confirmed items, `medium` for FRD-inferred items.
