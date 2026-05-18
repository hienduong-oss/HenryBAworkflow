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

- **Must read:** `core/contract.yaml`, `core/contract-behavior.md`, `paths.backbone`, `paths.plan` (when exists)
- **May read:** `paths.project_memory` or (`paths.memory_hot_vocabulary` + `paths.memory_hot_decisions`) when shard mode is active
- **Must NOT read:** `log.md`, `cold/`, `warm/` shards, unrelated module shards

## Governance Gate

Before mutating this artifact:
1. Verify you have write authority for this artifact scope.
2. Confirm an impact run is completed and approved (skip only for `wording-only` changes).
3. If either check fails: emit `GOVERNANCE_BLOCK: {reason}` and stop.
4. After mutation completes: offer to file the change into canonical memory using `templates/project-memory-fileback-record-template.md`.

## Scope

Run Step 6 only.

## Prerequisites

- Resolve slug, date, and module using the shared contract.
- Require `paths.backbone`.
- If backbone is missing, print the exact missing path and stop.
- Trust accepted user intent. Do not reopen scope discovery after FRD execution is accepted.
- Run a narrow FRD preflight:
  - read only `paths.backbone` and `paths.plan` when it exists
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

- Start from the exact backbone artifact only, plus the exact plan path when it exists.
- In `hybrid` mode, keep the FRD concise and focused on features, workflows, business rules, and integration-relevant context. Emit full UC specs only for complex or risky flows.
- In `lite` mode, emit the FRD only when the user explicitly asks for it.
- Write incrementally: one UC at a time. Update checkpoint `progress` after each UC.
- Do NOT write a UC that fails the 20-point checklist — fix first, then write.

Save to `paths.frd`.
