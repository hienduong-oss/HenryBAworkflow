# BA-kit Contract Behavior

Shared LLM policy for all BA-kit commands. Read this file after `core/contract.yaml`.
Step-specific policy lives in the matching `steps/*.md` file.

- `core/contract.yaml` is the canonical data layer (paths, prerequisites, defaults, state enums, thresholds).
- This file is the canonical shared behavior layer (routing, recovery, locking, stop conditions).
- If this file and `core/contract.yaml` disagree on a literal path or threshold, trust `core/contract.yaml` for the value and this file for the policy intent.

## Required Read Order

1. Read `core/contract.yaml` for exact values.
2. Read the selected skill stub (SKILL.md).
3. Read only the step file(s) needed for the active command.
4. Read templates or upstream artifacts only when the active step actually needs them.

## Shared Operating Rules

- Write BA deliverables in Vietnamese by default unless the user explicitly requests English.
- Use the defaults defined under `defaults.*`.
- Treat the backbone as the primary authoring source once it exists.
- Use exact artifact matching only. Never infer from "closest looking" filenames.
- Never silently choose a slug, dated set, or module by mtime.
- Keep module-scoped authoring inside `paths.module_root` and project-scoped compiled output inside `paths.compiled_root`.
- Treat `paths.project_home` as the BA-facing dashboard for resume/status guidance. It is not a source of truth and must not override `backbone`, `intake`, or module artifacts.

## Argument Parsing

Parse arguments before doing any work.

1. Read tokens left to right.
2. Extract `--slug <slug>`, `--date <date>`, `--module <module_slug>`, and `--mode <lite|hybrid|formal>` when present.
3. The first remaining lifecycle token is the subcommand: `intake`, `impact`, `options`, `backbone`, `frd`, `stories`, `srs`, `wireframes`, `package`, `status`, `next`.
4. Friendly aliases: "continue/resume" → `next`, "đánh giá thay đổi" → `impact`, "brainstorm phương án" → `options`, "chốt option" → `options`, "chuẩn bị handoff UI" → `wireframes`, "xuất gói bàn giao" → `package`, "kiểm tra trạng thái" → `status`.
5. If no subcommand is present, run the full lifecycle from intake.
6. For `intake`, allow one free argument as the source path hint.
7. For `impact`, allow one free argument as the change file path hint.
8. For `frd`, `stories`, `srs`, and `wireframes`, enforce `commands.<name>.module_required`.
9. Reject unknown subcommands and unexpected free arguments instead of guessing.

## Natural-Language Routing

Infer `impact` when all of these are true:
- the user refers to an existing project set or a downstream artifact already in progress
- the user says a requirement, rule, actor, AC, screen behavior, or scope item changed, was added, or was removed
- the request is not obviously limited to wording, typo, formatting, or layout cleanup

Also infer `impact` when exactly one project set can be resolved from disk and the user sends a bare correction statement without explicitly asking to update, overwrite, regenerate, or rerun a named artifact.

Do not mutate artifacts directly from a bare correction statement. Route to `impact` first.

Collaboration intent (module claim, review handoff, conflict check, PR, commit, push, merge) routes to `ba-collab`. GitHub actions require explicit approval after showing files and action plan.

## Resolution Rules

### Slug
- Prefer explicit `--slug`.
- Otherwise inspect directories matching `patterns.project_dir` under `plans/`.
- If more than one slug exists, stop and ask.

### Date
- Prefer explicit `--date`.
- Otherwise derive from the resolved project directory name.
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

## Options Decision-Ledger Gate

When `paths.options_root` exists as an active decision cycle, treat `plan.md` as the execution decision ledger. `backbone` must not proceed until the ledger records either `selected option` or `skipped`.

## Overwrite Behavior

Before mutating `backbone`, `frd`, `stories`, `srs`, `wireframes`, or `package`:
1. Check whether the target output path already exists.
2. If it exists, print the exact path and ask whether to overwrite.
3. If the user does not explicitly approve overwrite, stop without mutating.

## Checkpoint Protocol

Every step writes a `_checkpoint.md` at the project root before doing any work, and updates it when done.

**Paths:**
- `/ba-start` steps: `plans/{slug}-{date}/_checkpoint.md`
- `/ba-presale` steps: `plans/{slug}-{date}/00_presale/_checkpoint.md`

**Write on start** (before any artifact mutation):
```
step: <step name>
status: running
command: <exact command that was invoked>
started: <ISO timestamp>
updated: <ISO timestamp>
progress: ""
last_write: ""
resume_hint: ""
```

**Update during** (after each incremental write for long steps like srs, backbone, frd):
- Set `progress` to a short human-readable note (e.g., "UC-03/7 done")
- Set `last_write` to the artifact path just written
- Set `resume_hint` to what comes next (e.g., "Continue from UC-04")

**Update on complete:**
```
status: completed
updated: <ISO timestamp>
```

**Rules:**
- Write the checkpoint file as the very first action of a step — before reading any artifact.
- A `status: running` checkpoint that is older than the current session means the step was interrupted.
- Never delete a checkpoint file. Overwrite it in place.
- `progress`, `last_write`, and `resume_hint` are optional but must be filled for steps using the Large Artifact Write Protocol.

## Context-Loss Recovery

If exploration consumes context or the host truncates conversation history:
1. **Read `_checkpoint.md` first.** If `status: running` exists, report the interrupted step to the user before doing anything else.
2. Reconstruct the active target from the resolved command, slug, date, optional module, and on-disk artifacts.
3. If `resume_hint` is present in the checkpoint, use it to skip already-completed sub-steps.
4. Continue from the next unresolved step when those values are still unambiguous.
5. Do not ask the user to restate the original request merely because exploration consumed context.

*Presale context-loss recovery: see `steps/bootstrap.md`.*

## Accepted-Scope Execution Lock

After the user explicitly approves a mutating rerun step:
- keep the current step locked for the rest of the run
- do not reopen generic discovery
- do not fall back to prompts like "what do you want me to do next?"
- only break the lock when command, slug, date, module, or overwrite approval becomes genuinely ambiguous

## Token Discipline

- Read the selected step file, not the whole BA lifecycle.
- Read only the exact upstream artifacts needed by the active step.
- Use `templates/manifest.json` or CLI extraction helpers instead of loading full templates when only one group is needed.
- Reuse summaries and excerpts instead of rereading large raw sources when normalized artifacts already exist.

## Large Artifact Write Protocol

When generating artifacts that exceed ~150 lines (`backbone`, `frd`, `stories`, `srs`), use **incremental writes**:
1. Write the skeleton first: target file with template structure (headings, boilerplate, front matter).
2. Append group content sequentially: one logic group (e.g., one Epic, one Use Case) at a time.
3. Never attempt to assemble and flush the full artifact in memory.

## Active Push-back and Fail-Closed Behavior

When uncertainty is material, stop and ask instead of filling the gap with plausible prose.

Material uncertainty includes: ambiguous scope, actor ownership, or target module; conflicting terminology between artifacts; unclear acceptance behavior, validation rules, or error handling; unclear portal ownership, navigation schema, or active-menu behavior; a change statement that could touch multiple source-of-truth layers with different rerun paths.

Fail-closed rules:
- If a required fact is missing, mark it as an assumption or open question instead of presenting it as settled.
- If a downstream artifact would require guessing an upstream decision, stop and route back to the owning step.
- If a correction invalidates a persisted assumption, record the rejected assumption in `paths.project_memory` on the next approved mutating rerun.

## Runtime-Neutral HITL Contract

BA-kit is a playbook, not a UI product. HITL behavior must be enforced through artifact routing and contract rules, not through screen interactions.
- Core guarantees stay identical across Claude Code, Codex, and Antigravity.
- Runtime-local memory is never authoritative. Persist reusable project memory on disk under `paths.project_memory`.
- A runtime adapter may translate command syntax or question prompts, but must preserve the same resolution, stop conditions, approval gates, and rerun rules.

## Project Memory Compaction Rule

When `paths.project_memory` (compact mode) exceeds 80 lines:
1. Retain only: confirmed vocabulary, active decisions, active push-back triggers, accepted assumptions still in scope.
2. Move superseded/rejected entries to `paths.memory_cold` with a `superseded_by` trace.
3. Rewrite the file in place — do not append.
4. Record the compaction event as a one-line entry in `log.md` when shard mode is active.

Trigger compaction before writing new entries when the file is already over 80 lines. Do not let it grow unbounded across runs.

**MEM-COR consolidation trigger:** When `hot/approved-decisions.md` accumulates ≥5 `MEM-COR-*` entries on the same topic:
1. Merge them into a single `MEM-DEC-*` entry with `Confidence: high`.
2. Move the individual `MEM-COR-*` entries to `cold/` with `superseded_by: <new MEM-DEC-ID>` trace.
3. Record the consolidation in `log.md`.

## Decision Staleness Rule

A decision entry in `hot/approved-decisions.md` is considered stale when it has not been referenced or refreshed across ≥2 approved `impact` runs since its `Ngày chốt`.

When stale decisions are detected:
1. Flag the entry in the `Shard Health` table of `paths.memory_index` with status `stale`.
2. On the next `impact` run, surface the stale entries to the user for re-confirmation or archival.
3. Do not silently use a stale decision as authoritative — note its staleness when referencing it.
4. After user re-confirms: update `Ngày chốt` and set `Confidence: high`. After user archives: move to `cold/` with `superseded_by: archived`.

## Log Rotation Rule

`log.md` is append-only by default. Rotate when either condition is met:
- Entry count exceeds 30, or
- Oldest entry is more than 90 days old.

Rotation: move all entries older than the 20 most recent into `paths.memory_cold` as `archive-log-{YYYYMMDD}.md`. Keep the 20 most recent entries in `log.md`. Emit a one-line rotation notice at the top of the retained log.

## Granular Artifact Intervention

Minimum intervention units when they exist: goal/metric IDs, actor IDs, feature IDs, FR/NFR IDs, story IDs and ACs, use case IDs and step rows, screen IDs, rule codes and message codes, glossary terms.

## Delegation Loop Bounds

**NEEDS_REPARTITION:** If a sub-agent returns `NEEDS_REPARTITION`, the orchestrator repartitions and re-dispatches once. If the second dispatch also returns `NEEDS_REPARTITION`, stop and surface to user with the exact overloaded section and the smallest viable split proposal. Do not dispatch a third time.

**Stall detection:** `states.stall_after_minutes` is the threshold. When a delegation tracker has been in `running` state past this threshold without a heartbeat update, the orchestrator must mark it `stalled` and surface to user: exact tracker path, last heartbeat timestamp, and what was in progress. Do not silently wait or re-dispatch a stalled worker.

When a user change can be attached to one or more stable nodes, update only the narrowest source-of-truth artifact that owns those nodes.
