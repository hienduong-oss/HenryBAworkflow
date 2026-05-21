# BA-kit Token Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the compression-first token optimization design across BA-kit contract paths, source extraction, index-first read contracts, impact/package discipline, and runtime context budget checks.

**Architecture:** Add bounded index artifacts as first-class contract paths, then make source and downstream BA steps navigate through those indexes before reading large artifacts. Keep index files as navigators only; source artifacts remain authoritative.

**Tech Stack:** Bash test scripts, Python helper scripts, JSON contract, Markdown BA skill/step files, runtime parity fixtures.

---

## File Structure

- Modify `core/contract.yaml`: add index paths, command outputs, activation signals, context-size thresholds.
- Modify `core/contract-behavior.md`: update read-scope and token discipline rules for index-first navigation, impact invalidation, package read limits.
- Modify `scripts/source-extract.py`: generate `chunk-index.md`, reduce default chunk size, add metadata.
- Modify `scripts/ba-kit`: wire CLI defaults for `source-extract` and expose `context-budget`.
- Create `scripts/context-budget.py`: estimate command read budgets from contract paths and artifact sizes.
- Modify `scripts/test-contract-sync.sh`: validate new contract paths, templates, and Python scripts.
- Modify `templates/manifest.json`: register new index templates.
- Create `templates/source-chunk-index-template.md`.
- Create `templates/backbone-index-template.md`.
- Create `templates/user-stories-index-template.md`.
- Create `templates/srs-index-template.md`.
- Modify `skills/ba-start/steps/intake.md`: require source extraction for large text sources.
- Modify `skills/ba-start/steps/backbone.md`: output and require refresh of `backbone_index`.
- Modify `skills/ba-start/steps/frd.md`: read `backbone_index` before full backbone.
- Modify `skills/ba-start/steps/stories.md`: read `backbone_index`, output `stories_index`.
- Modify `skills/ba-start/steps/srs.md`: read `backbone_index` and `stories_index`, output `srs_index`.
- Modify `skills/ba-start/steps/impact.md`: add delta-first output schema and stale artifact reporting.
- Modify `skills/ba-start/steps/package.md`: use indexes for cross-reference discovery.
- Add runtime parity fixtures/goldens for source extraction, index-first routing, impact delta-first, package bounded reads.

## Task 1: Contract Paths And Templates

**Files:**
- Modify: `core/contract.yaml`
- Modify: `templates/manifest.json`
- Create: `templates/source-chunk-index-template.md`
- Create: `templates/backbone-index-template.md`
- Create: `templates/user-stories-index-template.md`
- Create: `templates/srs-index-template.md`
- Modify: `scripts/test-contract-sync.sh`

- [ ] **Step 1: Write failing contract-sync checks**

Add checks in `scripts/test-contract-sync.sh` that require `source_chunk_index`, `backbone_index`, `stories_index`, and `srs_index` under `contract.paths`, plus matching command outputs and templates in `templates/manifest.json`.

- [ ] **Step 2: Run failing test**

Run: `bash scripts/test-contract-sync.sh`
Expected: FAIL because the new contract paths and templates are absent.

- [ ] **Step 3: Add contract paths and templates**

Add the four paths and command outputs in `core/contract.yaml`. Create minimal index templates with freshness metadata fields: `index_type`, `source_artifact`, `source_hash`, `generated_at`, `generated_by_command`, `stale_status`, `coverage_summary`.

- [ ] **Step 4: Run passing contract-sync test**

Run: `bash scripts/test-contract-sync.sh`
Expected: PASS.

- [ ] **Step 5: Commit**

Run: `git add core/contract.yaml templates scripts/test-contract-sync.sh && git commit -m "feat: add token optimization index contracts"`

## Task 2: Source Extract Hardening

**Files:**
- Modify: `scripts/source-extract.py`
- Modify: `scripts/ba-kit`
- Modify: `skills/ba-start/steps/intake.md`
- Modify: `scripts/test-contract-sync.sh`

- [ ] **Step 1: Write failing source-extract test in contract sync**

Add a temporary fixture inside `scripts/test-contract-sync.sh` that runs `scripts/source-extract.py` on a large markdown file with `--chunk-chars 2000`, then asserts `summary.md`, `manifest.json`, `chunks/`, and `chunk-index.md` exist.

- [ ] **Step 2: Run failing test**

Run: `bash scripts/test-contract-sync.sh`
Expected: FAIL because `chunk-index.md` is not generated.

- [ ] **Step 3: Generate `chunk-index.md`**

Update `scripts/source-extract.py` to create `chunk-index.md` with one row per chunk, freshness metadata, candidate headings, keywords, and a short excerpt. Change default `--chunk-chars` to `2500`.

- [ ] **Step 4: Update CLI and intake rules**

Update `scripts/ba-kit` usage/default behavior for `source-extract`, and update `skills/ba-start/steps/intake.md` so large `md/txt` sources must use extraction.

- [ ] **Step 5: Run tests**

Run: `bash scripts/test-contract-sync.sh`
Expected: PASS.

- [ ] **Step 6: Commit**

Run: `git add scripts/source-extract.py scripts/ba-kit skills/ba-start/steps/intake.md scripts/test-contract-sync.sh && git commit -m "feat: add source chunk index extraction"`

## Task 3: Index-First Read Contracts

**Files:**
- Modify: `core/contract-behavior.md`
- Modify: `skills/ba-start/steps/backbone.md`
- Modify: `skills/ba-start/steps/frd.md`
- Modify: `skills/ba-start/steps/stories.md`
- Modify: `skills/ba-start/steps/srs.md`
- Modify: `skills/ba-start/steps/package.md`
- Modify: `core/token-budget.md`

- [ ] **Step 1: Write failing token-budget/contract checks**

Extend `scripts/test-contract-sync.sh` to assert read-scope text references `backbone_index`, `stories_index`, and `srs_index`.

- [ ] **Step 2: Run failing test**

Run: `bash scripts/test-contract-sync.sh`
Expected: FAIL because step files and behavior contract still reference full artifact reads as mandatory.

- [ ] **Step 3: Update read-scope contracts**

Update behavior and step files so downstream commands read indexes first and full artifacts only through targeted section reads or `READ_ESCALATION`.

- [ ] **Step 4: Refresh token budget**

Run `python` or PowerShell size checks manually, update `core/token-budget.md` baselines/max values only if the guardrail fails because of intentional contract growth.

- [ ] **Step 5: Run tests**

Run: `bash scripts/test-contract-sync.sh`
Expected: PASS.

- [ ] **Step 6: Commit**

Run: `git add core/contract-behavior.md skills/ba-start/steps core/token-budget.md scripts/test-contract-sync.sh && git commit -m "feat: enforce index-first BA read contracts"`

## Task 4: Impact, Package, And Runtime Budget

**Files:**
- Modify: `skills/ba-start/steps/impact.md`
- Modify: `skills/ba-start/steps/package.md`
- Modify: `core/contract.yaml`
- Create: `scripts/context-budget.py`
- Modify: `scripts/ba-kit`
- Modify: `scripts/test-contract-sync.sh`

- [ ] **Step 1: Write failing runtime budget checks**

Add `python3 -m py_compile scripts/context-budget.py` and a smoke invocation to `scripts/test-contract-sync.sh`.

- [ ] **Step 2: Run failing test**

Run: `bash scripts/test-contract-sync.sh`
Expected: FAIL because `scripts/context-budget.py` does not exist.

- [ ] **Step 3: Add runtime budget estimator**

Create `scripts/context-budget.py` to read `core/contract.yaml`, resolve a project root, compute sizes for command read scopes, and emit a compact table. Add `ba-kit context-budget` wrapper.

- [ ] **Step 4: Update impact and package discipline**

Add delta-first output schema to `impact.md`, stale artifact reporting, and package read restrictions based on index freshness.

- [ ] **Step 5: Add size signals and thresholds**

Add context-size activation signals to `core/contract.yaml` without making existing activation behavior fail closed before index coverage exists.

- [ ] **Step 6: Run tests**

Run: `bash scripts/test-contract-sync.sh`
Expected: PASS.

- [ ] **Step 7: Commit**

Run: `git add core/contract.yaml scripts/context-budget.py scripts/ba-kit scripts/test-contract-sync.sh skills/ba-start/steps/impact.md skills/ba-start/steps/package.md && git commit -m "feat: add runtime context budget discipline"`

## Final Verification

- [ ] Run `bash scripts/test-contract-sync.sh`.
- [ ] Run `bash scripts/test-runtime-parity.sh --check-structure`.
- [ ] Run `git status --short` and confirm only intended changes remain.
