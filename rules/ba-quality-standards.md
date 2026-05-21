# BA Quality Standards

Áp dụng trước khi artifact được coi là complete.

## Requirements
- Mỗi requirement có source, business rationale, owner, acceptance criteria.
- Unambiguous, testable, prioritized. Một intent per statement.

## User Stories

### Story Format
`As a [specific persona] / I want to [concrete action] / So that [distinct business value]`

Persona MUST be role-specific (e.g., `Registered Customer`, `Group Admin`, `Finance Manager`). Generic personas (`user`, `admin`) are NOT acceptable.

### INVEST Criteria (all 6 required per story)

| Criterion | Rule |
|-----------|------|
| **I — Independent** | Deliverable without another story being done first |
| **N — Negotiable** | Describes behavior, not implementation (no API names, DB schema, UI layout) |
| **V — Valuable** | "So that" clause delivers distinct, measurable business value |
| **E — Estimable** | Dev team can size it without additional discovery |
| **S — Small** | Fits one sprint; AC count ≤ 7–8 scenarios |
| **T — Testable** | QA can write test cases directly from AC — no vague qualifiers |

### Acceptance Criteria — Gherkin Format (MANDATORY)

Minimum **3 AC per story**, covering:
1. **Happy path** — main success flow
2. **Edge case / boundary** — limit condition, empty state, or validation boundary
3. **Negative path / error** — failure handling (invalid input, permission denied, system error)

Each AC uses **Given-When-Then**:
```gherkin
AC-{story_id}-{n}: {short label}
  Given [precondition]
  When  [user action or system trigger]
  Then  [observable, measurable outcome]
```

**AC quality rules:**
- Outcomes must be measurable — not "user sees an error" but "user sees error message 'Email already registered'"
- No implementation detail (no API names, no DB tables)
- No UI specifics (no colors, pixel positions)
- No vague qualifiers ("fast", "user-friendly", "safe") — use concrete thresholds

### Story Split Rules

Split when ANY of:
- Story covers >1 distinct persona → one story per persona
- AC count would exceed 7–8 → split by workflow phase
- Story covers multiple CRUD operations → one story per operation
- Story spans multiple systems → split at system boundary
- "So that" has two distinct business values → split into two stories

## Traceability
- Business goals → requirements → downstream artifacts/test cases.
- Cross-references explicit và dễ follow.

## Cross-Artifact Consistency
- Use cases, screen descriptions, wireframe constraints, and any user-supplied wireframes must describe the **same** behavior using **identical** terminology.
- Every detailed Use Case in the SRS must include a Process Flow with swimlanes (using PlantUML) or a Sequence Diagram (using Mermaid).
- When wireframe support is requested, an approved project `DESIGN.md` must exist and the resulting manual handoff pack must follow it consistently.
- Screen Contract Plus must be sufficient to prepare wireframe constraints before final screen descriptions are written.
- The backbone must lock a system-level `Portal Matrix` whenever UI-backed scope exists.
- `DESIGN.md` must define a `Navigation Schema` for every portal that appears in module-level screen specs.
- UC actor actions must match screen User Actions — same wording, same sequence.
- UC system responses must match screen field Behaviour Rules.
- UC alternate flows must be reflected in screen Error/States.
- `Portal ID`, `Nav Schema ID`, and `Expected Active Menu Item` must remain consistent between Screen Contract Plus, wireframe artifacts, final screen descriptions, and any user-supplied mockup.
- Screens in the same portal must reuse the same navigation schema unless an explicit exception is documented.
- If global navigation is visible on a screen, the active/highlighted menu state must be documented as both behavior and visual evidence.
- Modal, dialog, drawer, and overlay screens with distinct interaction logic must be modeled as primary screens with their own detailed screen sections.
- Supporting wireframe frames must reflect the parent screen's defined states and feedback rules, including empty, error, and message variants when applicable.
- Field names must be identical across UC steps, screen field tables, and wireframe constraint labels or user-supplied mockup labels.
- Screen field descriptions must separate `Display Rules`, `Behaviour Rules`, and `Validation Rules`.
- `Display Rules` should capture how the field appears, including label, placeholder, visibility, defaults, formatting, and read-only state when relevant.
- `Behaviour Rules` should capture what happens when the user interacts with the field, including navigation targets, modal openings, and dependent-field behavior.
- `Validation Rules` should capture validation logic, error surface (`inline`, `toast`, `banner`, etc.), and the exact message text or `Message Code`.
- Reusable cross-screen rules should be centralized in a `Common Rules` section and referenced by `Rule Code` from screen descriptions instead of being duplicated verbatim.
- Reusable UI and validation messages should be centralized in a `Message List` section and referenced by `Message Code` from screen descriptions instead of being duplicated verbatim.
- `Rule Code` should use the format `CR-{TYPE}-{NN}` where `TYPE` is one of `DIS`, `BEH`, `VAL`, or `MIX`.
- `Message Code` should use the format `MSG-{TYPE}-{NN}` where `TYPE` is one of `ERR`, `WRN`, `SUC`, or `INF`.
- `NN` should be a 2-digit sequence that remains unique within the SRS and stable when the same shared rule or message is reused.
- Each SRS screen must reference the correct manual wireframe status and attachment location when a mockup is supplied.
- Inventory-only supporting screens must still be listed in the SRS screen inventory and kept aligned with the wireframe handoff checklist.
- User story acceptance criteria must be covered by UC postconditions and screen Validation Rules.
- FRD features must be fully traceable through user stories into SRS requirements.
- Final screen descriptions must be derived from and remain consistent with the pre-wireframe screen spec, the wireframe constraint pack, and the upstream use cases.
- Final screen descriptions may enrich layout and interaction detail, but they must not redefine portal ownership, navigation schema, or active/highlight behavior that was already locked upstream.
- Any user-supplied wireframe styling, density, and component treatment must remain consistent with the approved `designs/{slug}/DESIGN.md`.
- When inconsistency is found, the upstream artifact (user story > use case > screen > wireframe) is the source of truth.

## Cross-Module (Teamwork)
- Portals, Global Navigation, UX style phải lock ở system-level (`02_backbone/feature-map.md` + `DESIGN.md`).
- Module branch không tự định nghĩa Global Menu hoặc thay đổi UX style.
- `CR-***` và `MSG-***` codes unique across all modules.

## Quality Checklist
- SMART requirements, INVEST stories (all 6 criteria).
- Gherkin AC: min 3 per story (happy / edge / negative), no vague language.
- Persona specific — no generic roles.
- Không contradiction, không orphaned requirement.
- Language clear, dependencies visible, risks stated, links current.
