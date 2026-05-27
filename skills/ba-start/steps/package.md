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

## Discovery Strategy: Snapshot-First

Before any artifact reads, check for a current package snapshot manifest at
`plans/{slug}-{date}/02_backbone/package-snapshot.md`.

- If the snapshot exists and `snapshot_state: current`, use it as the authoritative
  artifact inventory.  Do not re-run broad index discovery.
- If the snapshot is absent or `snapshot_state: degraded`, run the guardrail preflight
  to classify indexes, then proceed with index-first discovery.
- Regenerate the snapshot after any compile step by running:
  ```bash
  python3 scripts/package-snapshot.py --repo . --slug {slug} --date {date} --output plans/{slug}-{date}/02_backbone/package-snapshot.md
  ```

## Memory Read Scope

- **Must read:** `core/contract.yaml`, `core/contract-behavior.md`
- **Snapshot path (preferred):** `plans/{slug}-{date}/02_backbone/package-snapshot.md` when current
- **Index fallback:** `paths.backbone_index`, `paths.stories_index`, `paths.srs_index` when snapshot absent or degraded
- **May read:** `paths.project_memory` (compact only, consistency check), `paths.memory_index` (health overview and activation state)
- **Must NOT read:** raw source, full intake, `log.md`, `cold/`, `warm/` shards, or full source-of-truth artifacts for cross-reference discovery when snapshot or indexes are current

## Scope

Run Step 12 only.

## Prerequisites

- Resolve slug and date using the shared contract.
- Require at least one emitted downstream artifact for the selected mode.
- If the engagement emitted any module SRS, require at least one module `paths.srs`.
- If a module SRS exists in canon-first form, require `paths.srs_compile_receipt` and treat missing/stale receipt as a package blocker.
- If a module has UI-backed screen canon, require current ASCII coverage in `screens/*.md`.

## Outputs

- packaged HTML under `paths.compiled_root`
- delivery summary
- refreshed `plans/{slug}-{date}/02_backbone/package-snapshot.md`

## Step 12 - Package deliverables

Run a final packaging and quality pass:

- Keep the default package scope narrow: validate the existing artifact set from the snapshot
  manifest or indexes, then regenerate `paths.compiled_frd` when FRD exists and
  `paths.compiled_srs` when SRS exists.
- Do not treat `package` as a full rebuild of intake, backbone, stories, and SRS drafts.
- When snapshot is current, use its `artifacts` list for existence checks and its `indexes`
  list for cross-reference routing — no additional index reads required.
- When snapshot is absent or degraded, fall back to `paths.backbone_index`,
  `paths.stories_index`, and `paths.srs_index` for cross-reference discovery.
- Read full markdown only for the artifact currently being converted to HTML, or emit
  `READ_ESCALATION` when an index is missing, stale, or contradictory.
- Verify all deliverables follow their templates.
- Check cross-references between the backbone and every emitted downstream artifact.
- When FRD and SRS exist, check their cross-references against stories.
- Verify user-story traceability across FR, UC, and SCR.
- Verify compiled SRS freshness against `paths.srs_compile_receipt` before converting to HTML.
- Validate naming conventions and file structure.
- Flag broken links or missing sections.
- Produce a delivery summary.
- After compile, refresh the snapshot manifest.

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
