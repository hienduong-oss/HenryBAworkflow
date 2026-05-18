# BA Quality Standards

Áp dụng trước khi artifact được coi là complete.

## Requirements
- Mỗi requirement có source, business rationale, owner, acceptance criteria.
- Unambiguous, testable, prioritized. Một intent per statement.

## User Stories
- `As a / I want / so that` khi dùng Agile.
- AC đủ cụ thể để verify không cần interpretation. Có boundary + failure cases.

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
- SMART requirements, INVEST stories.
- Không contradiction, không orphaned requirement.
- Language clear, dependencies visible, risks stated, links current.
