# BA-kit Contract Behavior

Use this file as the canonical LLM policy layer for BA-kit.

- `core/contract.yaml` is the canonical data layer for paths, prerequisites, defaults, state enums, thresholds, and resolution sequences.
- This file is the canonical behavior layer for routing, recovery, execution locking, delegation discipline, and model-facing stop conditions.
- If this file and `core/contract.yaml` disagree on a literal path or threshold, trust `core/contract.yaml` for the value and this file for the policy intent.

## Required Read Order

1. Read `core/contract.yaml` for exact values.
2. Read the selected BA workflow or skill stub.
3. Read only the step file(s) needed for the active command.
4. Read templates or upstream artifacts only when the active step actually needs them.

## Shared Operating Rules

- Write BA deliverables in Vietnamese by default unless the user explicitly requests English.
- Use the defaults defined under `defaults.*`.
- Treat the backbone as the primary authoring source once it exists.
- Use exact artifact matching only. Never infer from "closest looking" filenames.
- Never silently choose a slug, dated set, or module by mtime.
- Keep module-scoped authoring inside `paths.module_root` and project-scoped compiled output inside `paths.compiled_root`.

## Argument Parsing

Parse arguments before doing any work.

1. Read tokens left to right.
2. Extract `--slug <slug>`, `--date <date>`, `--module <module_slug>`, and `--mode <lite|hybrid|formal>` when present.
3. The first remaining lifecycle token is the subcommand:
   - `intake`
   - `impact`
   - `backbone`
   - `frd`
   - `stories`
   - `srs`
   - `wireframes`
   - `package`
   - `status`
4. If no subcommand is present, run the full lifecycle from intake.
5. For `intake`, allow one free argument as the source path hint.
6. For `impact`, allow one free argument as the change file path hint.
7. For `frd`, `stories`, `srs`, and `wireframes`, enforce `commands.<name>.module_required`.
8. Reject unknown subcommands and unexpected free arguments instead of guessing.

## Natural-Language Routing

When the user does not explicitly name a subcommand, infer `impact` when all of these are true:

- the user refers to an existing project set or a downstream artifact already in progress
- the user says a requirement, rule, actor, acceptance criterion, screen behavior, or scope item changed, was added, or was removed
- the request is not obviously limited to wording, typo, formatting, or layout cleanup

Also infer `impact` when:

- exactly one project set can be resolved from disk, and
- the user sends a bare correction statement without explicitly asking to update, overwrite, regenerate, or rerun a named artifact

Do not mutate artifacts directly from a bare correction statement. Route to impact first.

## Resolution Rules

Use the resolution order from `resolution.*`.

### Slug

- Prefer explicit `--slug`.
- Otherwise inspect directories matching `patterns.project_dir` under `plans/`.
- Ignore legacy report trees as resolution sources.
- If more than one slug exists, stop and ask.

### Date

- Prefer explicit `--date`.
- Otherwise derive the date from the resolved project directory name.
- If more than one dated set exists for the slug, stop and ask.

### Module

- For commands where `commands.<name>.module_required` is `true`, prefer explicit `--module`.
- If the project contains exactly one module directory, use it.
- If multiple module directories exist, stop and ask.
- Never infer a module from partial filename matches.

## Legacy Detection

- Treat anything under `legacy.roots` as out-of-contract for current lifecycle execution.
- If legacy artifacts exist but modular artifacts do not, stop and tell the user to migrate or rerun.
- Do not mix legacy and modular artifacts in one silent pass.

## Prerequisite Behavior

- Use `commands.<name>.requires` plus `paths.*` to resolve the exact prerequisite file(s).
- If any required artifact is missing, print the exact missing path, the exact prior command to run, and stop.
- For `package`, block only when wireframe state is `missing`.
- If no wireframe-state marker exists, treat it as `not-applicable` only when the SRS set has no UI-backed screens or Screen Contract Plus section. Otherwise treat it as `missing`.

## Overwrite Behavior

Before mutating `backbone`, `frd`, `stories`, `srs`, `wireframes`, or `package`:

1. Check whether the target output path already exists.
2. If it exists, print the exact path and ask whether to overwrite.
3. If the user does not explicitly approve overwrite, stop without mutating.

## Context-Loss Recovery

If exploration consumes context or the host truncates conversation history:

1. Reconstruct the active target from the resolved command, slug, date, optional module, and on-disk artifacts.
2. Continue from the next unresolved step when those values are still unambiguous.
3. Do not ask the user to restate the original request merely because exploration consumed context.

## Accepted-Scope Execution Lock

After the user explicitly approves a mutating rerun step:

- keep the current step locked for the rest of the run
- do not reopen generic discovery
- do not fall back to prompts like "what do you want me to do next?"
- only break the lock when command, slug, date, module, or overwrite approval becomes genuinely ambiguous

## Delegation Contract

Use narrow handoff packets only.

- Trackers live under `paths.delegation_root`.
- Tracker states must use `states.delegation`.
- Heartbeat cadence uses `states.heartbeat_minutes`.
- Stall detection uses `states.stall_after_minutes`.

Packet rules:

- Pass objective, exact target path, write scope, trace IDs, and the few exact upstream excerpts needed.
- Do not attach full merged artifacts when exact excerpts or IDs are enough.
- If a packet grows beyond a concise brief plus targeted excerpts, repartition before delegating.
- Require the worker to stop and return exact missing context instead of guessing.
- If a worker returns `NEEDS_REPARTITION`, rerun only the overloaded slice.

## Wireframe-State Behavior

- Use `states.wireframe` only.
- `wireframes` is read-only on upstream BA artifacts.
- It may regenerate only the runtime `DESIGN.md`, wireframe input pack, wireframe map, and wireframe state.

## Packaging Behavior

- `package` is a validation-and-compile step, not a full rebuild.
- HTML output belongs under `paths.compiled_root`.
- Keep markdown artifacts as the source of truth.

## Token Discipline

- Read the selected step file, not the whole BA lifecycle.
- Read only the exact upstream artifacts needed by the active step.
- Use `templates/manifest.json` or CLI extraction helpers instead of loading full templates when only one group is needed.
- Reuse summaries and excerpts instead of rereading large raw sources when normalized artifacts already exist.

## Compaction Discipline (Presale)

Long-running orchestrations such as `/ba-presale` must protect the conversation context.

- After each completed presale phase, the lead writes a state card under `paths.presale_state_cards` (≤ ~300 tokens): phase id, output paths, key decisions, open issues, next gate.
- On context-loss recovery, reconstruct state from the most recent state card plus on-disk artifacts. Do not ask the user to restate the project.
- Sub-agent results MUST come back as short summaries (~50 tokens). The full output lives on disk at the agreed target path.
- Never inline templates into delegation packets. Reference template paths from `templates.*` and let the worker read on demand.
- For change requests, the lead generates a small "change packet" (delta only) and dispatches surgical edits, not full rewrites.

## Presale Lifecycle (`/ba-presale`)

`/ba-presale` is the upstream lifecycle that runs BEFORE `intake`. It produces a locked WBS + Proposal + QnA bundle and hands off cleanly to `/ba-start`.

### Subcommands

Recognize the following subcommands in addition to the BA-kit core set:

- `presale` — initialize lifecycle, run Bootstrap, then Domain Study. Stops at the Domain Study user gate.
- `presale next` — advance to the next presale phase (gated transitions only).
- `presale lock <phase>` — snapshot and freeze an artifact. Once locked, no mutation without `presale feedback`.
- `presale render` — render xlsx + docx finals from markdown sources via document-skills. Render is **never** automatic.
- `presale feedback` — accept client feedback log, generate change packet, dispatch surgical updates, re-run sync-check.
- `presale status` — report current presale phase, locked artifacts, pending gates.
- `presale handoff` — generate `intake.md`, source mirrors, and handoff manifest; bridge to `/ba-start`.
- A bare prompt during a presale phase edits the current artifact via Edit tool (no rerender).

### Multi-Agent Contract

- `presale-lead` (Opus) is the orchestrator. It owns lifecycle transitions, sync-check, conflict resolution, render dispatch, and handoff.
- `wbs-builder` (Sonnet) and `proposal-writer` (Sonnet) are workers. They write only to their assigned target path and return short summaries.
- The lead NEVER delegates assembly, merge, render, conflict arbitration, or handoff.
- Parallel WBS+Proposal dispatch must include identical Domain Primer reference and identical scope frame in both delegation packets.

### User Gates

Per `presale.user_gates`. After Domain Study, after WBS+Proposal sync-check, after QnA, and before handoff. The lead must stop and explicitly instruct the user how to advance (`/ba-presale next`).

### Auto-Bootstrap

- Bootstrap is fully automatic. Do NOT ask the user to organize files.
- Scan the project workspace, classify each file into `presale_inputs_*` directories. Move/copy only — do not modify file contents.
- Empty workspace + a text-only requirement → still proceed; capture the prompt as `00-inputs/requirements/_initial-prompt.md`.

### Conflict Resolution

When WBS and Proposal disagree, anchor the decision to the **requirement source of truth**, in priority order: client raw → answered QnA → validated Domain Primer → documented assumption. Do not resolve by "stronger side" or recency. Log the decision in `paths.presale_changelog`.

### Source Ref Discipline

Every fact in WBS, Proposal, and QnA carries an inline source ref using one of the formats in `presale.source_ref_formats`. A row or section without a source ref is blocked from final render. Source refs must survive render to xlsx/docx.

### Render Discipline

- Triggered only by `/ba-presale render`. Never auto-render on edit.
- Inputs: markdown content + CSV intermediate + style spec (`templates.output_style_spec`).
- Outputs: `paths.presale_wbs_xlsx`, `paths.presale_proposal_docx` only.
- Render must NOT mutate the markdown sources.

### Handoff to `/ba-start` (CRITICAL)

`presale handoff` produces:

1. `paths.intake` — generated from the source-of-truth bundle (`presale.handoff_bundle`).
2. `paths.handoff_intake_sources/` — mirror or symlink of every bundle file so backbone can re-read originals.
3. `paths.handoff_manifest` — a fact → source-ref traceability table.

Continuity check before declaring handoff complete:
- Every WBS phase appears in `intake.md` scope.
- Every Proposal commitment appears in `intake.md`.
- Every Pending or Blocked QnA appears in `intake.md` open questions.
- Missing item → block handoff with explicit error. Do not paper over.

Post-handoff, locked WBS + Proposal are the source of truth. If `/ba-start backbone` produces something contradicting them, flag for user review; do not silently overwrite.

### Forbidden in Presale

- Cross-project recall. The engine is the single source of truth (`presale.no_cross_project_recall = true`).
- Auto-rendering on every edit.
- Delegating assembly, merge, render, conflict arbitration, or handoff.
- Skipping the Domain Study user gate.
- Modifying locked artifacts without `/ba-presale feedback`.

## Large Artifact Write Protocol

When generating artifacts that exceed ~150 lines (e.g., `backbone`, `frd`, `stories`, `srs`), you MUST use **incremental writes**.
Writing entire documents in memory and flushing in one call causes `<max_tokens>` truncation and infinite retry loops.

1. **Write the skeleton first**: Create the target file with the template structure (headings, boilerplate, front matter) using a single write.
2. **Append group content sequentially**: For each logic group (e.g., one Epic, one Use Case), generate the fragment and append it into the correct section of the file. Complete one group before starting the next.
3. **Never attempt to assemble and flush the full artifact in memory**.
