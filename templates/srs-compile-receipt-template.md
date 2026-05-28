# SRS Compile Receipt

## Metadata

| Field | Value |
| --- | --- |
| receipt_type | srs-compile |
| module_slug | [module-slug] |
| compiled_artifact | `./srs.md` |
| source_index | `./ascii-screen/index.md`, `./usecases/index.md` |
| generated_at | [YYYY-MM-DDTHH:mm:ssZ] |
| generated_by_command | `ba-start srs` |
| compile_status | generated |

## Source Manifest

| source_type | source_id | path | source_hash | included_sections |
| --- | --- | --- | --- | --- |
| usecase | UC-xxx | `./usecases/uc-xxx.md` | [sha256] | Goal, Flow, Diagram, Trace |
| screen | SCR-XXX-01 | `./ascii-screen/scr-xxx-01.md` | [sha256] | Purpose, Fields, States, ASCII, Figma Map |
| srs-slice | SRS-ERD | `./srs/erd.md` | [sha256] | ERD |

## Compile Order

| order | section | source |
| --- | --- | --- |
| 1 | Scope And Objective | `srs/spec.md` |
| 2 | Functional Requirements | `srs/spec.md` |
| 3 | Use Cases | `usecases/*.md` |
| 4 | Screen Inventory | `ascii-screen/index.md` Screen Registry |
| 5 | Screen Descriptions And ASCII | `ascii-screen/*.md` |
| 6 | Diagrams | `usecases/*.md`, `srs/flows.md`, `srs/erd.md` |
| 7 | Traceability Summary | `usecases/index.md`, `ascii-screen/index.md` |

## Freshness State

| check | state | notes |
| --- | --- | --- |
| sources_match_receipt | unknown | [Validator fills] |
| index_matches_sources | unknown | [Validator fills] |
| compiled_matches_sources | unknown | [Validator fills] |
