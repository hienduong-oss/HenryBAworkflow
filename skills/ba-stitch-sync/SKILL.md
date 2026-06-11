---
name: ba-stitch-sync
description: Sync approved BA canon to Stitch MCP for consistent UI screen generation. Requires Stitch MCP installed and configured.
argument-hint: "--module <module_slug> [--slug <slug>] [--date <date>] [--device DESKTOP|MOBILE|TABLET|AGNOSTIC]"
allowed-tools:
  - Read
  - Write
  - Bash
  - mcp__stitch__list_projects
  - mcp__stitch__create_project
  - mcp__stitch__list_design_systems
  - mcp__stitch__upload_design_md
  - mcp__stitch__create_design_system_from_design_md
  - mcp__stitch__generate_screen_from_text
  - mcp__stitch__get_screen
  - mcp__stitch__get_project
---

# BA Stitch Sync

Downstream visual-consumer command. Reads approved SRS canon + DESIGN.md, bootstraps a Stitch design system, and generates consistent UI screens via Stitch MCP.

## Invocation

```text
/ba-stitch-sync --module auth-flow
/ba-stitch-sync --slug warehouse-rfp --module payment --device MOBILE
/ba-do đồng bộ Stitch cho module auth-flow
/ba-do tạo UI từ SRS module payment
```

## Required Read Order

1. Read `core/contract.yaml`.
2. Read `core/contract-behavior.md`.
3. Read `core/behavior/stitch-sync.md`.
4. Resolve slug, date, module, and `--device` flag per `contract.yaml` resolution rules.

## General Error Handling Rules

**ID Validation Rule (applies to ALL MCP calls):**
After every MCP call that returns an ID (screen ID, asset ID, project ID):
1. Check the value is a non-empty string.
2. Check it is not an error object (no `error` or `code` field at top level).
3. Check it is not a hallucinated placeholder (not "id", "undefined", "null", "TODO", "xxx").
4. If ANY check fails → follow the per-step BLOCK/WARN/retry rule below.
5. Print the ID to user immediately so they can verify.
6. Write ID to disk immediately (not batch at end) to survive mid-phase crashes.

**Recovery Hierarchy:**

| Severity | Action | Example |
|----------|--------|---------|
| **BLOCK** | Stop entire command. Print error + fix instructions. | Asset ID missing, all screens failed, quota exceeded |
| **WARN + skip** | Log warning, skip this item, continue. | Single screen generation failed |
| **Retry** | Retry once after 10s. If still fails → escalate to WARN. | Timeout on upload_design_md |

---

## Phase 0 — Preflight

### Step 0.1: Parse arguments

- Extract `--slug`, `--date`, `--module` from ARGUMENTS.
- Extract `--device` flag: DESKTOP (default) | MOBILE | TABLET | AGNOSTIC.
- Resolve slug/date/module per contract.yaml resolution rules.

### Step 0.2: Read contract

- Read `core/contract.yaml`.
- Read `core/contract-behavior.md`.
- Read `core/behavior/stitch-sync.md`.

### Step 0.3: MCP Connectivity Gate

- Call `mcp__stitch__list_projects()`.
- If tool unavailable or error:
  - Print Stitch MCP setup instructions (API key, .mcp.json config, restart Claude Code).
  - **BLOCK** — do not proceed.
- If success: continue.

### Step 0.3a: Resolve Stitch project

- From `list_projects()` output, find project matching slug or prompt user to select.
- If no matching project exists, create one via `mcp__stitch__create_project(name=<slug>)`.
- Extract `projectId` for all subsequent MCP calls.

### Step 0.4: BA Prerequisite Gate

- Check `paths.design_doc` exists.
- Check `paths.srs_compile_receipt` exists and fresh.
- Check `paths.ascii_screen_index` exists.
- Check `paths.shared_shell_contract` exists.
- Any fail → **BLOCK** + recommend correct `ba-start` command.

---

## Phase 1 — Design System Bootstrap

### Step 1.1: Check existing design system

- Call `mcp__stitch__list_design_systems(projectId)`.
- **VALIDATE:** Check response is an array (not null, not error object).
  If response is not iterable → WARN "Unexpected response from list_design_systems" + treat as no existing DS.
- If existing DS found:
  - Show: "Design system already exists (created {date}). Reuse / Refresh / Abort?"
  - **Refresh: Full regeneration.** Destroy old design system, regenerate ALL screens.
    Existing stitch-screen-map.json is invalidated. User warned about re-generation cost.
  - Abort: exit.
- If no existing DS: continue.

### Step 1.2: Read DESIGN.md

- Read full `paths.design_doc`.
- **VALIDATE:** Content is non-empty string. If empty → **BLOCK** "DESIGN.md is empty. Cannot create design system."
- Compute content hash (SHA-256 or similar) for change detection.

### Step 1.3: Upload DESIGN.md

- Base64-encode DESIGN.md content.
- Call `mcp__stitch__upload_design_md(projectId, designMdBase64)`.
- **VALIDATE response:**
  - Response must be an object (not null, not error string).
  - Extract `selectedScreenInstance`: must have `id` (non-empty string) and `sourceScreen` (non-empty string).
  - If `id` is missing/empty → **BLOCK** "upload_design_md returned no screen instance ID. Cannot proceed."
  - If `sourceScreen` is missing/empty → **BLOCK** "upload_design_md returned no source screen reference. Cannot proceed."
- Log: `upload_design_md OK — screen instance: {id}`.

### Step 1.4: Create design system

- Call `mcp__stitch__create_design_system_from_design_md(projectId, selectedScreenInstance)`.
- **VALIDATE response:**
  - Wait for completion — this call can take minutes. DO NOT retry on timeout.
  - If timeout → poll `get_project(projectId)` every 30s for up to 10 attempts to check if DS was created.
  - Extract asset ID from response. Must be non-empty string matching `assets/` or numeric pattern.
  - If asset ID is null/empty/undefined after polling → **BLOCK** "Failed to create design system. DESIGN.md was uploaded but design system creation did not complete. Check Stitch project manually."
- **ID VALIDATION GATE — HARD BLOCK:**
  - The asset ID extracted here is CRITICAL. Every subsequent screen depends on it.
  - Write it to `paths.stitch_design_system_id` IMMEDIATELY (before Phase 2).
  - Re-read the file to confirm the write succeeded and the ID is not truncated.
  - If the file write fails or the ID is malformed → **BLOCK** "Cannot persist design system ID."

### Step 1.5: Verify design system exists (sanity check)

- Call `mcp__stitch__list_design_systems(projectId)` again.
- **VALIDATE:** The asset ID from Step 1.4 MUST appear in the list.
  - If NOT found → **BLOCK** "Design system was created (asset ID: {id}) but not found in list_design_systems. Possible Stitch sync delay or ID mismatch. Retry Phase 1 or check Stitch manually."

---

## Phase 2 — Screen Generation

### Step 2.1: Load design system ID

- Read `paths.stitch_design_system_id`.
- **VALIDATE:** `asset_id` field exists, is non-empty string.
  - If missing or empty → **BLOCK** "Design system ID not found. Run Phase 1 bootstrap first."
  - If file doesn't exist → **BLOCK** "stitch-design-system-id.json not found. Run Phase 1 first."
- **CRITICAL:** This ID is used in EVERY screen generation call. Wrong ID = all screens broken.
  Print the ID to user so they can verify: "Using design system: {asset_id}"

### Step 2.2: Build BA-kit ID Reference Index

Before reading any screen file, build a lookup index from shared_shell_contract:
- Read `paths.shared_shell_contract`.
- Extract ALL valid IDs into a structured index:
  ```
  portals: { "PORTAL-APP": {...}, "PORTAL-IDE": {...} }
  nav_schemas: { "NAV-APP-01": {...portal_id, menu_items, active_rule...}, "NAV-IDE-01": {...} }
  actors: { "ACT-01": {...}, "ACT-02": {...} }  (if defined)
  ```
- **VALIDATE:** Each nav_schema must reference a portal_id that EXISTS in `portals`.
  - If nav_schema references unknown portal → **BLOCK** "shared_shell_contract: NAV-xx references unknown portal PORTAL-xx. Fix shared_shell_contract first."
- Also read `paths.design_doc` — extract Portal Summary and Navigation Schema tables.
- **CROSS-CHECK:** Portal IDs and Nav Schema IDs in DESIGN.md MUST match shared_shell_contract exactly.
  - If DESIGN.md has PORTAL-X but shared_shell_contract has PORTAL-Y → **BLOCK** "DESIGN.md and shared_shell_contract disagree on portals. Align them first."
  - If DESIGN.md has NAV-xx but shared_shell_contract doesn't → **BLOCK** "DESIGN.md defines NAV-xx but shared_shell_contract has no matching schema."
- Print the resolved index: "Resolved {N} portals, {M} nav schemas."

### Step 2.3: Read screen index

- Read `paths.ascii_screen_index`.
- **VALIDATE:** Index is parsable, contains at least 1 screen entry.
  - If empty → WARN "No screens found in ascii_screen_index. Nothing to generate." + skip Phase 2.
- Filter: skip screens with `stitch_sync_eligible: false`.

### Step 2.4: Cross-Reference Validation Gate (MANDATORY — before ANY screen generation)

For each eligible screen, read the canon file and extract IDs. Validate ALL of them against the reference index BEFORE calling any MCP tool:

1. **Screen ID (`id` or `screen_id`):**
   - Must be non-empty.
   - Must follow expected pattern (e.g., `SCR-NN`).
   - If missing → **BLOCK** "Screen file {path}: missing screen ID. Add it before generating."
   - If malformed (e.g., `SCR-`, `SCREEN01`, no prefix) → WARN "Unusual screen ID format: {id}" + continue.

2. **Portal ID (`portal_id`):**
   - Must be non-empty.
   - Must exist in the reference index `portals` built in Step 2.2.
   - If NOT found → **BLOCK** "Screen {id}: portal_id '{portal_id}' not found in shared_shell_contract. Valid portals: {list}. Fix screen file."
   - If screen file doesn't declare portal_id → **BLOCK** "Screen {id}: missing portal_id. Every screen must declare which portal it belongs to."

3. **Nav Schema ID (`nav_schema_id`):**
   - Must be non-empty.
   - Must exist in the reference index `nav_schemas`.
   - Must belong to the same portal declared in `portal_id` (cross-check: nav_schema.portal_id == screen.portal_id).
   - If NOT found → **BLOCK** "Screen {id}: nav_schema_id '{nav_schema_id}' not found. Valid schemas: {list}."
   - If schema belongs to different portal → **BLOCK** "Screen {id}: nav_schema_id '{nav_schema_id}' belongs to portal '{actual_portal}', but screen declares portal '{screen_portal}'. Mismatch."

4. **Expected Active Menu Item:**
   - If declared, must match an item in the nav schema's `menu_item_list`.
   - If NOT found → WARN "Screen {id}: active_menu '{item}' not in nav schema '{nav_schema_id}' menu list: {valid_items}. Active highlight may be wrong."

5. **Overlay Context (`overlay_context.parent_screen`):**
   - If screen is modal/dialog/drawer/overlay, `parent_screen` must reference an existing screen ID in the index.
   - If parent NOT found → **BLOCK** "Screen {id}: overlay parent '{parent}' not found in screen index. Parent screen must exist."

6. **Cross-screen Portal consistency:**
   - All screens in the same portal MUST use the same nav_schema_id (unless an explicit exception is documented).
   - Group screens by portal_id. Check nav_schema_id is uniform per portal group.
   - If mismatch → WARN "Portal {portal_id}: screens use different nav schemas: {list}. This may cause navigation inconsistency. Explicit exception documented?"

7. **Duplicate Screen IDs:**
   - Check no two screen canon files declare the same screen ID.
   - If found → **BLOCK** "Duplicate screen ID '{id}' in files: {file1}, {file2}. Screen IDs must be unique."

**Gate outcome:**
- Print validation summary: "{N} screens checked, {W} warnings, {E} errors."
- If E > 0 → **BLOCK** entire Phase 2. "Fix {E} cross-reference errors above before generating screens."
- If W > 0 → show warnings, ask user "Continue with {W} warnings? (Y/n)". Default Y.
- If 0 errors + 0 warnings → proceed to generation.

### Step 2.5: ID Normalization Rules (for prompt building)

When building the generation prompt, use EXACT IDs from the reference index:
- Do NOT abbreviate (e.g., "APP" instead of "PORTAL-APP").
- Do NOT transliterate or change case.
- Copy the nav schema name and menu items verbatim from shared_shell_contract.
- If a screen references an ID that was resolved/auto-corrected in Step 2.4, use the corrected ID.

### Step 2.6: Generate each screen (sequential)

For each eligible screen:
1. Read ascii-screen canon file.
2. Extract: name, portal_id, nav_schema_id, field table, state coverage, ASCII wireframe.
3. **VALIDATE extracted data:**
   - `name` must be non-empty.
   - `portal_id` must match a known portal from shared_shell_contract.
   - `nav_schema_id` must match a known schema.
   - If any missing → WARN "Screen {file}: missing {field}. Generation may be inconsistent." + continue.
4. Use cached portal/nav context from Step 2.2.
5. Build prompt:
   - "Portal: {portal_id}, Nav: {nav_schema_id}"
   - Screen description + key fields summarized.
   - ASCII wireframe constraints.
   - "Generate in the same design system as other screens in this portal."
6. Call `mcp__stitch__generate_screen_from_text(projectId, prompt, deviceType=<resolved_device>, designSystem=<assetId>)`.
7. **VALIDATE response:**
   - Response must contain a screen ID (non-empty string).
   - If screen ID is null/empty/undefined → mark screen as `failed`, record error "generate_screen_from_text returned no screen ID", continue to next screen.
   - If timeout (no response after 5 minutes) → mark as `failed`, record "timeout", continue.
   - If error code `RATE_LIMITED` → **BLOCK** entire Phase 2. "Stitch daily quota exceeded. {N} screens remaining. Retry after midnight UTC."
8. **ID VALIDATION — POST-WRITE:**
   - Record in in-memory map FIRST: `{ba_screen_id: {stitch_screen_id, generated_at, status: "ok"|"failed", error: "..."}}`.
   - Write `paths.stitch_screen_map` AFTER EACH screen (not batch at end) — prevents data loss on mid-phase failure.
   - Re-read the file to confirm write succeeded.
9. Print progress: "[{N}/{total}] {screen_name} → {stitch_screen_id} ✓" or "✗ {error}"

### Step 2.7: Post-generation sanity check

- Count screens in `paths.stitch_screen_map`.
- **VALIDATE:** Count matches number of eligible screens.
  - If fewer → WARN "{N} screens failed to generate. See stitch-sync-report.md for details."
- **VALIDATE:** At least 1 screen succeeded.
  - If 0 screens succeeded → **BLOCK** "All screen generations failed. Check Stitch quota and project state. No reports written."
- Check for duplicate stitch_screen_ids (same ID for different BA screens):
  - If found → WARN "Duplicate stitch_screen_id detected: {id}. Possible AI hallucination or Stitch bug. Mark affected screens for re-generation."

---

## Phase 3 — Validation

### Step 3.1: Load generated screens

- Read `paths.stitch_screen_map`.
- **VALIDATE:** File exists and contains valid JSON.
  - If file missing → **BLOCK** "No screen map found. Phase 2 may not have run or failed completely."
- Filter to screens with `status: "ok"`.
  - If 0 OK screens → WARN "No successfully generated screens to validate." + skip validation.

### Step 3.2: Cross-screen consistency check

- For each generated screen, get screenshot via `mcp__stitch__get_screen(name, projectId)`.
- **VALIDATE each get_screen call:**
  - If call fails or returns no image data → mark screen as `validation: "skipped"`, record reason.
  - If timeout → skip screen, continue.
- Compare across screens: navbar region, logo placement, primary CTA color, font usage.
- Flag any drift with severity: `high` (different color), `medium` (spacing shift), `low` (minor).

### Step 3.3: Write reports

- Write `paths.stitch_sync_report`:
  - Generated: N screens (list with stitch IDs)
  - Skipped: M screens (with reasons)
  - Failed: K screens (with errors)
  - Validated: V screens (with consistency score)
  - Design system asset ID
- Write `paths.stitch_mismatch_report` (if drift detected):
  - Which screens drifted
  - What drifted (color, layout, typography)
  - Severity
  - Recommendation (re-run specific screen / adjust DESIGN.md / accept)

---

## Write Scope

Allowed repo writes:

- `plans/{slug}-{date}/05_tool-lanes/stitch/stitch-design-system-id.json`
- `plans/{slug}-{date}/05_tool-lanes/stitch/stitch-screen-map.json`
- `plans/{slug}-{date}/05_tool-lanes/stitch/stitch-sync-report.md`
- `plans/{slug}-{date}/05_tool-lanes/stitch/stitch-mismatch-report.md`

Forbidden repo writes:

- `srs.md`, `srs/spec.md`, `srs/flows.md`, `srs/states.md`, `srs/erd.md`
- `ascii-screen/*.md`
- `usecases/*.md`
- `userstories/*.md`
- `frd.md`
- `DESIGN.md`
- `shared-shell-contract.md`
- `backbone.md`
- Any canon BA artifact

## Stop Conditions

- Stitch MCP unavailable → **BLOCK** with setup instructions
- Missing or stale `srs-compile-receipt.json`
- Missing `ascii-screen/index.md`
- Missing `DESIGN.md`
- Missing `shared-shell-contract.md`
- Design system creation fails
- All screen generations fail
- RATE_LIMITED error from Stitch MCP
- Cross-reference validation errors (>0)

## Output

After the run, report:
- resolved project/module
- design system asset ID (or reused)
- screens attempted, succeeded, failed, skipped
- device type used
- consistency check results
- report paths written
