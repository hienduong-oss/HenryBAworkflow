# BA Start Step - Stories

## Checkpoint

Write `plans/{slug}-{date}/_checkpoint.md` as the **first action** before reading any artifact:
```
step: stories
status: running
command: <exact invoked command>
started: <ISO timestamp>
updated: <ISO timestamp>
progress: ""
last_write: ""
resume_hint: ""
```
After each incremental epic/story group write, update `progress` (e.g., "Epic 2/4 done"), `last_write`, and `resume_hint`.
On complete, update `status: completed` and `updated`.

This step requires:

- `core/contract.yaml`
- `core/contract-behavior.md`

## Memory Read Scope

- **Must read:** `core/contract.yaml`, `core/contract-behavior.md`, `paths.backbone_index`
- **May read:** targeted `paths.backbone` sections, `paths.plan`, `paths.frd` (when exists), `paths.project_memory` or (`paths.memory_hot_vocabulary` + `paths.memory_hot_decisions`) when shard mode is active
- **Must NOT read:** `log.md`, `cold/`, `warm/` shards, unrelated module shards, `user-stories.md`, `user-stories-index.md`

## Backbone Authority Gate

Before writing any story file, validate backbone alignment:
- Story actor, goal, feature, and priority must trace to backbone module scope.
- If alignment fails: emit `BACKBONE_ALIGNMENT_FAIL: story_scope` and stop.
- Recovery: run `ba-start impact --slug <slug>` or refresh backbone, then rerun.

## Governance Gate

Before mutating this artifact:
1. **Skip this gate for first-pass creation** (when `paths.userstories_root` does not yet exist).
2. For reruns (artifacts already exist): verify write authority and locate the active impact receipt at `paths.impact_receipt`. If no active receipt exists and `change_class` is not `wording-only`, emit `GOVERNANCE_BLOCK: impact_receipt missing or invalidated` and stop.
3. If either check fails on a rerun: emit `GOVERNANCE_BLOCK: {reason}` and stop.
4. After mutation completes: offer to file the change into canonical memory using `templates/project-memory-fileback-record-template.md`.

## Scope

Run Step 7 only.

## Prerequisites

- Resolve slug, date, and module using the shared contract.
- Require `paths.backbone`.
- Prefer `paths.backbone_index` for routing. If it is missing and the backbone is large, stop and ask to refresh the index.
- If backbone is missing, print the exact missing path and stop.
- Run a narrow stories preflight:
  - If `ba-kit guardrail --command stories --slug <slug> --date <date> --module <module>` returns `status=block`, surface the block message and stop
  - Otherwise use `ALLOW_READS` for file discovery
  - read `paths.backbone_index` first
  - read only targeted `paths.backbone` sections
  - read `paths.plan` only when it adds needed scope context
  - read `paths.frd` only when it already exists and adds needed vocabulary or workflow structure
  - do not scan unrelated module folders once slug, date, and module are resolved

## Output

- `paths.userstories_index` — folder index navigator
- `paths.userstory_item` — one file per story (`userstories/us-{slug}.md`)

Do NOT create `user-stories.md` or `user-stories-index.md`.

---

## Step 7 — Produce User Stories

Generate Agile user stories from the backbone feature map and FR draft.

Use templates:
- `templates/userstory-item-template.md` for each story file
- `templates/userstories-index-template.md` for the index

Generation rules:
- Derive one story per coherent user intent — not per acceptance criterion.
- One acceptance criteria set per story.
- Stable slug from normalized story title (kebab-case, ASCII, max 40 chars).
- No bundled behaviors — one intent per story statement.
- Story actor, goal, feature, and priority must trace to backbone module scope.

Story item fields:
- `story_id`: `US-{NNN}` (zero-padded, sequential within module)
- `slug`: stable kebab-case from story title
- `actor`: from backbone actor registry
- `priority`: P0 / P1 / P2 from backbone feature priority
- `source_backbone_ids`: backbone feature/scope IDs this story traces to
- `linked_usecases`: populated by SRS step
- `linked_screens`: populated by SRS step

Index row fields:
- `story_id`, `file`, `actor`, `feature_or_fr`, `acceptance_criteria_count`, `linked_usecases`, `linked_screens`, `source_backbone_ids`, `stale_status`

### 7.1 — Epic & Feature Breakdown

Derive epics directly from backbone feature map. Each epic maps to one functional area. Features within an epic map to individual user stories.

### 7.2 — Story Format (MANDATORY)

Every story MUST follow this exact format:

```
As a [specific persona],
I want to [concrete, measurable action],
So that [distinct business value — not a restatement of the want].
```

**Persona quality guard (BLOCKING):**
- Generic personas (`user`, `admin`, `member`) are NOT acceptable.
- Replace with role-specific personas: `Registered Customer`, `Group Admin`, `Finance Manager`, `Guest Visitor`, `System Operator`.
- If the backbone uses a generic persona, infer the specific role from context. If ambiguous, flag and ask.

### 7.3 — INVEST Validation (per story, MANDATORY)

Every story MUST pass all 6 INVEST criteria before being written to the artifact. Self-check inline — do not write a story that fails any criterion.

| Criterion | Rule | Fail signal |
|-----------|------|-------------|
| **I — Independent** | Story can be developed and delivered without depending on another story being done first | "requires story X to be done first" |
| **N — Negotiable** | Scope is not locked to a specific implementation; the HOW is open | Story describes UI layout, API names, or DB schema |
| **V — Valuable** | Delivers clear value to a specific persona or the business | "So that" is vague, missing, or repeats the "I want" |
| **E — Estimable** | Dev team can size it without needing more information | Story spans multiple systems with unclear boundaries |
| **S — Small** | Fits within one sprint (≤ 7–8 scenarios in AC) | See Story Split Rules below |
| **T — Testable** | QA can write test cases directly from the AC | AC uses vague language ("user-friendly", "fast", "safe") |

If a story fails INVEST, apply the fix before writing:
- Fails **I** → split or reframe to remove dependency
- Fails **N** → remove implementation detail, keep behavior
- Fails **V** → rewrite "So that" with a measurable outcome
- Fails **E** → break down or add a spike story
- Fails **S** → apply Story Split Rules (§7.5)
- Fails **T** → rewrite AC with concrete, measurable conditions

### 7.4 — Acceptance Criteria Format (MANDATORY)

Every story MUST have a minimum of **3 Acceptance Criteria** covering:

1. **Happy path** — the main success flow (user does X correctly, system responds Y)
2. **Edge case / boundary** — limit condition, empty state, or validation boundary
3. **Negative path / error** — failure handling (invalid input, permission denied, system error)

Each AC MUST use **Gherkin Given-When-Then** format:

```gherkin
AC-{story_id}-{n}: {short label}
  Given [precondition — system state or user context]
  When  [user action or system trigger]
  Then  [observable, measurable outcome]
  And   [additional outcome if needed — keep to 1-2 And clauses max]
```

**AC quality rules (BLOCKING — do not write AC that violates these):**

| Rule | Correct | Wrong |
|------|---------|-------|
| Outcomes must be measurable | "user sees error message 'Email already registered'" | "user sees an error" |
| No implementation detail | "system sends a confirmation email" | "system calls SendGrid API" |
| No UI specifics | "form displays validation message" | "red text appears below the input field" |
| No vague qualifiers | "page loads within 3 seconds" | "page loads quickly" |
| QA can write test case directly | AC describes input + action + expected output | AC describes intent only |

**AC ID convention:** `AC-{EPIC_ID}-{STORY_SEQ}-{AC_SEQ}` — e.g., `AC-1-3-2` = Epic 1, Story 3, AC 2.

### 7.5 — Story Split Rules

Split a story when ANY of the following is true:

| Trigger | Split strategy |
|---------|---------------|
| Story covers >1 distinct persona | One story per persona |
| AC count would exceed 7–8 scenarios | Split by workflow phase (e.g., "initiate" vs "complete") |
| Story covers multiple CRUD operations | One story per operation (Create / Read / Update / Delete) |
| Story spans multiple systems or integration points | Split at system boundary |
| "So that" clause has two distinct business values | Split into two stories, one per value |

When splitting, ensure each child story independently passes INVEST.

### 7.6 — Story-to-Screen Alignment

When UI exists (FRD or wireframe constraints available):
- Map each story to the screen(s) it touches using `[SCR-{nn}]` refs.
- Verify AC field names match screen field table terminology exactly.
- Flag any story whose AC references a field not present in the screen contract.

### 7.7 — Output Structure per Story File

```
**As a** {specific persona},
**I want to** {concrete action},
**So that** {distinct business value}.

**INVEST check:** I✓ N✓ V✓ E✓ S✓ T✓  (or flag failing criteria)

AC-{n}-{m}-1: {Happy path label}
  Given ...  When  ...  Then  ...

AC-{n}-{m}-2: {Edge case label}
  Given ...  When  ...  Then  ...

AC-{n}-{m}-3: {Negative path label}
  Given ...  When  ...  Then  ...

Screen refs: [SCR-{nn}] (if UI exists)
Dependencies: {story IDs or "none"}
Priority: {MoSCoW}
Estimate: {story points or T-shirt size}
```

### 7.8 — Execution Rules
- Start from `paths.backbone_index`, then the exact targeted backbone sections, plus the exact plan path when genuinely needed.
- Pull the FRD only when it already exists or the current mode requires it.
- If the user already confirmed that story generation should proceed, continue from the resolved backbone instead of reopening discovery.
- Write incrementally: one epic at a time. Update checkpoint `progress` after each epic.
- Do NOT write a story that fails INVEST — fix first, then write.
- Do NOT write AC that uses vague language — rewrite before writing to artifact.
- Flag stories that need splitting before writing them; do not silently write an oversized story.
- Treat generated index artifacts as `agent_facing`; keep them compact and do not duplicate source-of-truth requirement text.

After generating all story item files, create or refresh `paths.userstories_index` using `templates/userstories-index-template.md`. Keep it as a navigator over stories, acceptance-criteria counts, screen IDs, and source headings.

Generate `paths.userstories_index` with `stale_status: unknown`, leave `validated_at` and `validated_by` blank, then run:

```bash
ba-kit validate-index --index-key userstories_index --slug <slug> --date <date> --module <module> --writeback
```

before any downstream routing trusts the index as `current`.

## Memory Capture

After stories are approved by user, promote to project memory:

| What to capture | Target shard | Trigger |
|---|---|---|
| Persona definitions confirmed during story review | `hot/canonical-vocabulary.md` | When a new role-specific persona is locked |
| Story split decisions (why a story was split, what boundary was used) | `warm/modules/{module_slug}.md` | When a split decision is non-obvious |
| AC boundary decisions (what counts as edge case vs. negative path for this domain) | `warm/modules/{module_slug}.md` | When a domain-specific AC pattern is established |
| Push-back triggers (story intents explicitly rejected or descoped) | `hot/pushback-triggers.md` | When user explicitly rejects a story |

Set `Confidence: high` for user-confirmed items.
