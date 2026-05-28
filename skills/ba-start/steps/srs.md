# BA Start Step - SRS Router

This step requires:

- `core/contract.yaml`
- `core/contract-behavior.md`
- `core/behavior/srs.md`

## Governance Gate

Before mutating any SRS artifact:
1. **Skip this gate for first-pass creation** (when `paths.srs_spec` and `paths.srs` do not yet exist).
2. For reruns (artifact already exists): verify write authority and locate the active impact receipt at `paths.impact_receipt`. If no active receipt exists and `change_class` is not `wording-only`, emit `GOVERNANCE_BLOCK: impact_receipt missing or invalidated` and stop.
3. If either check fails on a rerun: emit `GOVERNANCE_BLOCK: {reason}` and stop.
4. After mutation completes: offer to file the change into canonical memory using `templates/project-memory-fileback-record-template.md`.

Receipt reference: `templates/impact-receipt-template.md`

## Scope

Run Steps 8-11 only. Keep execution split across the listed step files.

## Read Order

1. Read this router for SRS preflight and orchestration.
2. Read [srs-core.md](./srs-core.md) for Step 8 and Step 8.1.
3. Read [srs-wireframes.md](./srs-wireframes.md) for Step 8.2, mandatory ASCII coverage, Step 10, and Group D.
4. Read [srs-assembly.md](./srs-assembly.md) for Step 10.1 and Step 11.

## Prerequisites

- Resolve slug, date, and module using the shared contract.
- Require `paths.backbone`, `paths.backbone_index`, and `paths.userstories_index`.
- If a required artifact is missing, print the path, recommend the prerequisite subcommand, and stop.
- Run preflight from indexes first; read only targeted backbone/story sections, optional module FRD, and `paths.plan` when it exists.
- In reverse mode, require valid baseline/drift/evidence; skip `paths.design_doc`.

## Outputs

- `paths.srs_spec` — FR/NFR/rules/API/data constraints
- `paths.srs_flows` — module/system flows
- `paths.srs_states` — module state registry
- `paths.srs_erd` — business data model when justified
- `paths.srs`
- `paths.usecases_index` and `paths.usecase_item` files as canonical use case sources
- `paths.usecase_diagrams`
- `paths.ascii_screen_index` and `paths.ascii_screen_item` files as canonical screen sources
- `paths.srs_compile_receipt`
- `paths.design_doc` when UI design direction is confirmed or refreshed

Keep generated index/state artifacts compact. When `paths.usecases_index` or `paths.ascii_screen_index` is written, set `stale_status: unknown`, leave validator fields blank, then run:
`python3 scripts/validate-index-quality.py --repo . --index-key usecases_index --slug <slug> --date <date> --module <module> --writeback`
`python3 scripts/validate-index-quality.py --repo . --index-key ascii_screen_index --slug <slug> --date <date> --module <module> --writeback`
before downstream work trusts the indexes. `paths.srs` is compiled output only; canonical edits belong in `usecases/`, `ascii-screen/`, or `srs/` and must compile back into it.

## Execution Order

```text
Step 8   -> srs-core.md
Step 8.2 -> srs-wireframes.md only for forward DESIGN.md gating
ASCII     -> srs-wireframes.md in forward mode only
Step 10  -> srs-wireframes.md
Step 10.1 + 11 -> srs-assembly.md
```
