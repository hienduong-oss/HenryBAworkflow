# BA Start Step - Backbone

## Checkpoint

Write `plans/{slug}-{date}/_checkpoint.md` as the **first action** before reading any artifact:
```
step: backbone
status: running
command: <exact invoked command>
started: <ISO timestamp>
updated: <ISO timestamp>
progress: ""
last_write: ""
resume_hint: ""
```
After each incremental section write, update `progress` (e.g., "Epic 2/5 done"), `last_write` (artifact path), and `resume_hint` (e.g., "Continue from Epic 3").
On complete, update `status: completed` and `updated`.

This step requires:

- `core/contract.yaml`
- `core/contract-behavior.md`

## Memory Read Scope

- **Must read:** `core/contract.yaml`, `core/contract-behavior.md`, `paths.intake`
- **Must read when it exists:** `paths.plan`
- **Must read when optioning is completed:** the selected option file only
- **May read:** `paths.project_memory`, `paths.memory_index` (navigation only), `paths.memory_hot_vocabulary`, `paths.memory_hot_decisions`
- **Must NOT read:** `log.md`, `cold/`, `warm/` shards

**Memory freshness check:** Before using `paths.project_memory`, verify its `Last Refresh Source` header matches the current backbone run or a later step. If stale (last refreshed before the current intake/backbone), read it for context but flag it for refresh at the end of this run. Do not block on staleness — flag and continue.

## Governance Gate

Before mutating this artifact:
1. Always verify write authority for the target artifact and its owning memory shard.
2. For first-pass creation (when `paths.backbone` does not yet exist), skip only the impact-run requirement.
3. For reruns (artifact already exists): confirm an approved impact run (skip only for `wording-only` changes).
4. If either check fails: emit `GOVERNANCE_BLOCK: {reason}` and stop.
5. After mutation completes: offer to file the change into canonical memory using `templates/project-memory-fileback-record-template.md`.

## Scope

Run Step 5 only.

## Prerequisites

- Resolve slug and date using the shared contract.
- Require `paths.intake`.
- If intake is missing, print the exact missing path and stop.
- Read `paths.plan` when it exists.
- Run a narrow backbone preflight:
  - read only `paths.intake` and `paths.plan` when it exists
  - do not scan other folders once slug and date are resolved
  - when `paths.plan` records `options status: recommended` or `options status: in-progress`, stop because optioning is unresolved
  - when `paths.plan` records `options status: completed` or `options status: skipped`, treat that as the backbone decision gate
  - require `paths.plan` to state either `options status: skipped`, `options status: completed`, or `options status: not-needed` before proceeding
  - if completed, require a `selected option`
  - if completed, read only the selected option file as the decision overlay
  - never require `paths.options_root` to exist before honoring the decision-ledger gate

## Output

- `paths.project_home`
- `paths.backbone`
- `paths.project_memory`

## Step 5 — Build the Requirements Backbone

Create the persisted source-of-truth artifact using [../../../templates/requirements-backbone-template.md](../../../templates/requirements-backbone-template.md).

The backbone must contain:

- scope lock summary
- selected engagement mode (`lite`, `hybrid`, or `formal`)
- business goals and success metrics
- actors and feature map
- system-level portal matrix for UI-backed scope
- FR/NFR draft inventory
- preliminary story map
- UI/screen coverage assessment
- artifact emission gates
- assumptions, risks, and open questions

After writing the backbone, initialize or refresh `paths.project_memory` using [../../../templates/project-memory-template.md](../../../templates/project-memory-template.md).

Also refresh `paths.project_home` using [../../../templates/project-home-template.md](../../../templates/project-home-template.md) so non-technical BAs can resume without understanding slug/date/module internals.

Project Home refresh must summarize scope lock, artifact gates, next safe step, and runtime quick prompts. It is a dashboard only; do not duplicate full requirements or replace `backbone.md`.

The project memory must persist only the reusable anti-hallucination layer:

- canonical vocabulary and naming
- approved scope, actor, navigation, and rule decisions
- accepted assumptions with triggers for re-validation
- rejected assumptions or false trails that must not reappear
- accepted corrections and push-back triggers

Backbone rules:

- treat the backbone as the primary authoring source after intake
- do not draft FRD, stories, or SRS directly from raw intake once the backbone exists
- when UI-backed scope exists, lock portal ownership and route-group ownership here before any module-level screen work starts
- promote only the selected option's portal/module/actor/constraint decisions
- do not import rejected options or the full comparison into `backbone.md`
- keep the artifact concise and decision-oriented
- keep `project-memory.md` runtime-neutral so Claude Code, Codex, and Antigravity can all resume from the same accepted facts

## Memory Architecture

- `backbone.md` is the primary scope truth and mutating artifact source.
- `project-memory.md` (compact/summary form) is the anti-drift support layer for simple projects.
- `project-memory/` shard tree is the structured memory extension for complex projects.

**Compact mode:** only `project-memory.md` exists; backward compatible.
**Shard mode:** `project-memory.md` + `project-memory/` tree; use when index navigation benefit justifies the structure.

`project-memory/index.md` routes agents to the right shards — it must not become a second monolith. Detail lives in hot/warm/cold shards, not in the index.

`project-memory/cold/` is never loaded by default — only via explicit escalation with a stated reason.

## Activation Contract

Activation levels: `Base` (single BA, single module), `Modular` (two or more modules/owners), `Program` (cross-module dependencies or two or more concurrent delegation slices).

- Use `activation.thresholds` from `core/contract.yaml` for all threshold comparisons.
- Compute signals from `activation.signals`.
- Auto-escalation is allowed. Auto-downgrade requires explicit refresh.
- Persist activation state inside `paths.memory_index` when shard mode is active; record in `paths.project_memory` header when compact mode is active.
- When runtime mismatch is detected between stored and computed activation level: freeze to `Base` and emit `ACTIVATION_FREEZE: computed level {X} conflicts with stored level {Y}; frozen to Base pending explicit refresh.`

## Multi-BA Governance

Memory ownership: `project-memory.md`, `index.md`, `hot/*.md` → Lead BA only. `warm/modules/{module_slug}.md` → Module BA (cross-module entries require Lead BA approval).

Conflict escalation: module BA writing a global hot shard → `GOVERNANCE_CONFLICT: {actor} does not own {path}; escalate to Lead BA.`

Promotion rules — canonical memory changes only after an approved rerun:
1. Detect change affecting accepted terminology, decisions, or push-back triggers.
2. Run `impact` to trace scope.
3. Get explicit user approval of the impact and proposed rerun path.
4. Execute the approved mutating rerun.
5. Promote using `templates/project-memory-fileback-record-template.md`.
6. Append traceable entry to `log.md` when shard mode is active.

File-back approval: Lead BA approves global/cross-module changes; Module owner approves module-local warm shard; end-user approval required when content changes accepted business scope or policy.

Every filed-back memory item must carry: `source_artifact`, `source_ids`, `promotion_target`, `approved_by`, `approved_role`, `approved_at`, `approval_basis`, `approval_trigger`, `impact_ref`, `supersedes`.

## Delegation Contract (when delegating backbone sub-tasks)

- Trackers live under `paths.delegation_root`. States must use `states.delegation`.
- Heartbeat cadence: `states.heartbeat_minutes`. Stall detection: `states.stall_after_minutes`.
- Packet rules: pass objective, exact target path, write scope, trace IDs, and targeted upstream excerpts only. Do not attach full merged artifacts.
- If a packet grows beyond a concise brief plus targeted excerpts, repartition before delegating.
- If a worker returns `NEEDS_REPARTITION`, rerun only the overloaded slice.
