# Legacy SRS Index Template

> Deprecated. Current BA-kit canon uses `usecases/index.md` and `ascii-screen/index.md`.
> Keep this file only for compatibility with old artifacts; do not use it for new SRS generation.

## Metadata

| Field | Value |
| --- | --- |
| index_type | srs |
| source_artifact | `./srs.md` |
| source_hash | [sha256] |
| generated_at | [ISO-8601] |
| generated_by_command | `ba-start srs` |
| stale_status | unknown |
| validated_at | [ISO-8601 or blank] |
| validated_by | [validator id or blank] |
| canon_roots | `./ascii-screen`, `./usecases`, `./srs` |
| compiled_artifact | `./srs.md` |

## Module Summary

| Field | Value |
| --- | --- |
| module_slug | [module-slug] |
| status | [draft/in-review/approved] |

## Screen Registry

| screen_id | screen_name | path | screen_type | portal_id | nav_schema_id | active_menu | states | ascii | figma_sync | status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SCR-01 | [Screen] | `./ascii-screen/scr-01.md` | primary | PORTAL-ADMIN | NAV-01 | dashboard | default,error | ready | eligible | draft |

## Use Case Registry

| uc_id | uc_name | path | diagram_type | primary_actor | screens | fr_links | status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| UC-01 | [Use Case] | `./usecases/uc-01.md` | activity | [Actor] | SCR-01 | FR-001 | draft |

## Diagram Registry

| diagram_id | diagram_type | scope | path | source_ref | status |
| --- | --- | --- | --- | --- | --- |
| DG-01 | activity | usecase | `./usecases/uc-01.md` | UC-01 | draft |

## Data Artifact Registry

| artifact_id | artifact_type | path | scope | status |
| --- | --- | --- | --- | --- |
| DATA-ERD-01 | erd | `./srs/erd.md` | module | draft |

## Trace Summary

| object_type | object_id | links_to |
| --- | --- | --- |
| screen | SCR-01 | UC-01; FR-001 |

## Validation Status

| check | result | notes |
| --- | --- | --- |
| schema | pending | [notes] |
| compile_freshness | pending | [notes] |
