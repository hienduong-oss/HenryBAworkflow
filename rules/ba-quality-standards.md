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

## Cross-Artifact Consistency (critical)
- UC steps, screen fields/actions, wireframe labels: **identical terminology, same behavior**.
- Field names nhất quán qua UC → screen field tables → wireframe labels.
- Screen fields tách rõ: `Display Rules` | `Behaviour Rules` | `Validation Rules`.
- Reusable rules → `Common Rules` section, ref bằng `CR-{TYPE}-{NN}`.
- Reusable messages → `Message List` section, ref bằng `MSG-{TYPE}-{NN}`.
- `Portal ID`, `Nav Schema ID`, active menu state nhất quán qua tất cả artifacts.
- Modal/drawer/overlay có interaction logic riêng → primary screen `SCR-xx`, không phải supporting state.
- Upstream artifact là source of truth khi có inconsistency: story > UC > screen > wireframe.

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
