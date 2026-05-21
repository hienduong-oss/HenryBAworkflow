# BA Start Step - Package

## Checkpoint

Write `plans/{slug}-{date}/_checkpoint.md` as the **first action**:
```
step: package
status: running
command: <exact invoked command>
started: <ISO timestamp>
updated: <ISO timestamp>
```
On complete, update `status: completed` and `updated`.

This step requires:

- `core/contract.yaml`
- `core/contract-behavior.md`

## Memory Read Scope

- **Must read:** `core/contract.yaml`, `core/contract-behavior.md`, `paths.backbone_index` when it exists
- **May read:** `paths.stories_index`, `paths.srs_index`, `paths.project_memory` (compact only, consistency check), `paths.memory_index` (health overview and activation state)
- **Must NOT read:** raw source, full intake, `log.md`, `cold/`, `warm/` shards, or full source-of-truth artifacts for cross-reference discovery when indexes are current

## Scope

Run Step 12 only.

## Prerequisites

- Resolve slug and date using the shared contract.
- Require at least one emitted downstream artifact for the selected mode.
- If the engagement emitted any module SRS, require at least one module `paths.srs`.
- Read `paths.wireframe_state` when present.
- If wireframe state is `missing`, print the exact marker path and stop.
- If wireframe state is `completed`, `skipped`, or `not-applicable`, continue.

## Outputs

- packaged HTML under `paths.compiled_root`
- delivery summary

## Step 12 - Package deliverables

Run a final packaging and quality pass:

- Keep the default package scope narrow: validate the existing artifact set, then regenerate `paths.compiled_frd` when FRD exists and `paths.compiled_srs` when SRS exists.
- Do not treat `package` as a full rebuild of intake, backbone, stories, and SRS drafts.
- Use `paths.backbone_index`, `paths.stories_index`, and `paths.srs_index` for cross-reference discovery when they are current.
- Read full markdown only for the artifact currently being converted to HTML, or emit `READ_ESCALATION` when an index is missing, stale, or contradictory.
- Verify all deliverables follow their templates.
- Check cross-references between the backbone and every emitted downstream artifact.
- When FRD and SRS exist, check their cross-references against stories.
- Verify user-story traceability across FR, UC, and SCR.
- Validate naming conventions and file structure.
- Flag broken links or missing sections.
- Produce a delivery summary.

## Step 12.1 - Generate packaged HTML

When the engagement includes multiple modules with FRD or SRS, aggregate and convert them to HTML:

```bash
python scripts/md-to-html.py plans/{slug}-{date}/03_modules --aggregate
```

Output:

- `paths.compiled_frd`
- `paths.compiled_srs`

When the engagement does not include SRS, package only the artifacts that were actually emitted and requested for stakeholder handoff.

If the user later manually inserts wireframe images or links into the markdown source, preserve those references in the packaged HTML instead of trying to regenerate design assets.

## Packaging Behavior

- `package` is a validation-and-compile step, not a full rebuild.
- HTML output belongs under `paths.compiled_root`.
- Keep markdown artifacts as the source of truth.

## Memory Capture

Package is a validation-and-compile step — it does not generate new decisions. However, if the quality pass surfaces inconsistencies that require user decisions to resolve:

| What to capture | Target shard | Trigger |
|---|---|---|
| Cross-artifact consistency decisions (e.g., canonical field name chosen when conflict found) | `hot/canonical-vocabulary.md` | When a naming conflict is resolved during packaging |
| Delivery scope decisions (which artifacts are included/excluded from the package) | `hot/approved-decisions.md` (MEM-DEC) | When user explicitly scopes the delivery package |

If no new decisions are made during packaging, skip memory capture for this step.
