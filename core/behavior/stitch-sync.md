# Stitch Sync Behavior

## Scope

`stitch-sync` is a downstream visual-consumer lane. It reads approved SRS canon
and DESIGN.md, bootstraps a Stitch design system, and generates consistent UI
screens via Stitch MCP. It never owns BA requirements.

## Read Scope

- Must read `core/contract.yaml` and `core/contract-behavior.md`.
- Must read `paths.ascii_screen_index` before individual screen files.
- Must read `paths.design_doc` and `paths.shared_shell_contract`.
- May read `paths.ascii_screen_root` and `paths.srs_compile_receipt`.
- Must not read `paths.usecases_root`, `paths.userstories_root`, or `paths.frd`.

## Write Scope

- May write only under `paths.stitch_lane_root`.
- Must write: `paths.stitch_design_system_id`, `paths.stitch_screen_map`,
  `paths.stitch_sync_report`, `paths.stitch_mismatch_report`.
- Must not write `paths.srs`, `paths.ascii_screen_root`, `paths.usecases_root`,
  `paths.design_doc`, or `paths.shared_shell_contract`.

## MCP Connectivity Gate

- Before any BA artifact read, probe Stitch MCP via `list_projects`.
- If the tool is unavailable or returns AUTH_FAILED: block immediately.
  Print Stitch MCP setup instructions. Do not proceed.
- BA-kit does not install or configure MCP. The user must set it up separately.

## Guardrails

- If Stitch MCP is unreachable, block — do not read BA artifacts.
- If `paths.srs_compile_receipt` is missing or stale, block and recommend
  `ba-start srs --slug <slug> --module <module_slug>`.
- If `paths.design_doc` is missing, block and recommend `ba-start backbone`.
- If a Stitch design system already exists for this project, ask: reuse / refresh / abort.
- If DESIGN.md content hash changed since last sync, force-refresh the design system.
- Refresh means full regeneration: destroy old DS, regenerate ALL screens.
- Screens with `stitch_sync_eligible: false` in ascii-screen frontmatter are skipped.
- `--device` flag (DESKTOP default | MOBILE | TABLET | AGNOSTIC) controls screen device type.

## Design System Bootstrap

1. Read `paths.design_doc` — extract full content.
2. Base64-encode the DESIGN.md content.
3. Call `upload_design_md(designMdBase64, projectId)` — creates screen instance.
4. Call `create_design_system_from_design_md(projectId, selectedScreenInstance)` — builds design system asset.
5. Persist asset ID + DESIGN.md hash to `paths.stitch_design_system_id`.
6. All subsequent `generate_screen_from_text` calls use this asset ID via `designSystem` parameter.

## Screen Generation

For each eligible screen:
1. Read the ascii-screen canon file.
2. Extract: screen name, Portal ID, Nav Schema ID, field table, state coverage, ASCII wireframe.
3. Read portal/nav context from `paths.shared_shell_contract`.
4. Build prompt: portal context + screen description + ASCII constraints.
5. Call `generate_screen_from_text(projectId, prompt, deviceType=<resolved_device>, designSystem=<assetId>)`.
6. Record `{ba_screen_id: {stitch_screen_id, generated_at}}` in `paths.stitch_screen_map`.

## Output

- `stitch-design-system-id.json`: `{asset_id, design_md_hash, created_at, project_id}`
- `stitch-screen-map.json`: `{ba_screen_id: {stitch_screen_id, generated_at, status}}`
- `stitch-sync-report.md`: what was generated, skipped, verified
- `stitch-mismatch-report.md`: cross-screen drift detected (logo, navbar, colors)
