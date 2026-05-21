# BA Start Step - Impact

## Checkpoint

Write `plans/{slug}-{date}/_checkpoint.md` as the **first action**:
```
step: impact
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

- **Must read:** `core/contract.yaml`, `core/contract-behavior.md`, `paths.intake`, `paths.backbone`
- **May read:** `paths.project_memory`, `paths.memory_index`, `paths.memory_hot_*`, selected `warm/` module shard (Modular/Program only); relevant downstream artifacts (frd, stories, srs, wireframe artifacts); `log.md` only when user explicitly requests audit/recent history
- **Must NOT read:** `cold/` (unless explicitly escalated)
- **Note:** `impact` is the only broad-read command. Only it may read across `warm/` module shards by default in Modular/Program activation.

**Memory freshness check:** Before using `paths.project_memory`, check its `Last Refresh Source` header. If it predates the last approved backbone or impact run, read it for context but note which entries may be stale. After the impact analysis is approved, offer to refresh the affected memory entries as part of the rerun path.

## Promotion Guidance

After completing impact analysis and the user approves a rerun path:
1. Document which memory shards, vocabulary terms, or decisions would need updating after the rerun.
2. Prepare a file-back record outline using `templates/project-memory-fileback-record-template.md`.
3. Pass the outline to the user for review before the mutating step executes.

## Scope

Run the change-impact triage path only. Do not mutate artifacts.

## Prerequisites

- Resolve slug, date, and module scope through the shared contract.
- Require a change input as either:
  - a direct file path free argument, or
  - pasted change text in the conversation
- Require `paths.intake`.
- If intake is missing, print the exact missing path and stop.
- Read `paths.backbone` when it exists.
- Read module-scoped downstream artifacts only when they exist and are relevant to the suspected impact:
  - `paths.frd`
  - `paths.stories`
  - `paths.srs`
  - `paths.wireframe_input`
  - `paths.wireframe_map`
  - `paths.wireframe_state`
  - `paths.design_doc`
  - `paths.plan` when it adds gate context

## Decision Rules

Treat the current source of truth in this order:

1. `backbone`
2. otherwise `intake`

Classify the change into one or more of these buckets:

- `wording-only`
- `clarification-only`
- `backbone-change`
- `scope-lock-change`
- `ui-impact`

Impact anchors:

- intake: business problem, goals, out-of-scope, success metrics
- backbone: scope lock summary, feature map, FR/NFR backbone, actors, portal matrix, story map, UI coverage, artifact gates
- FRD: feature wording, workflows, business rules, integration points
- user stories: story intent and acceptance criteria
- SRS: use cases, Screen Contract Plus, validation rules, screen inventory, final screen descriptions
- wireframe artifacts: manual wireframe constraint pack, runtime `DESIGN.md` assumptions, handoff checklist, wireframe state

## Routing Rules

- If the change touches goals, out-of-scope, success metrics, or scope decisions, route to `intake` first.
- If the change touches feature scope, FR/NFR intent, actors, acceptance-criteria intent, portal ownership, or global navigation schema, route to `backbone` first.
- If the change stays within existing backbone intent but changes story wording or testable acceptance detail, route to `stories`.
- If the change stays within existing backbone and story intent but changes use case flow, validation behavior, error states, or screen behavior, route to `srs`.
- If the change affects screen inventory, state variants, navigation, active/highlight behavior, overlays, or field interactions that manual wireframes must show, mark `ui-impact` and include `wireframes` after the required upstream rerun.
- Never recommend `package` as the first remediation step after a real requirement change.

## Output

Print:

- project and date set
- detected current step
- change type
- source of truth to update
- current source of truth used for analysis
- affected_node_ids
- owner_artifact
- stale_artifacts
- read_escalation
- affected artifacts
- unaffected artifacts
- recommended path
- exact commands
- only the focused questions that are truly required

Use this delta-first output schema:

```text
Impact Delta

affected_node_ids: [scope | actor | FR/NFR | story | UC | SCR | rule | message IDs]
owner_artifact: [intake | backbone | stories | srs | wireframe artifacts]
stale_artifacts: [indexes or artifacts that must be refreshed by the rerun]
read_escalation: [none | READ_ESCALATION: impact read {path} due to {reason}]
```

Rules:

- Map the change to `affected_node_ids` before opening broad downstream context.
- Use `owner_artifact` to choose the smallest rerun path.
- Include index files in `stale_artifacts` when a CR can invalidate `paths.backbone_index`, `paths.stories_index`, `paths.srs_index`, `paths.wireframe_input`, or `paths.wireframe_map`.
- If a CR cannot be mapped to a node, emit `read_escalation` and ask focused questions instead of scanning the full artifact set.

## Broad-Read Exception

`impact` is the only command that may read across `warm/` module shards by default when Modular or Program activation is detected. `log.md` may be read only when the user explicitly requests audit or recent-history context.

## Escalation Rule

A command may escalate its read scope only when: the index explicitly routes to an additional shard; the user states an explicit audit or context need; missing shard routing would otherwise require guessing.

Emit: `READ_ESCALATION: {command} read {path} due to {reason}.`

## Memory Capture

After impact analysis is approved and rerun path is confirmed, promote to project memory:

| What to capture | Target shard | Trigger |
|---|---|---|
| Approved change decision (what changed, why, which artifacts affected) | `hot/approved-decisions.md` (MEM-DEC) | After user approves rerun path |
| Rejected change (scope items explicitly rejected during impact review) | `hot/pushback-triggers.md` | When user explicitly rejects a proposed change |
| Stale decisions identified during impact read | `hot/approved-decisions.md` — flag `Confidence: low` | When a decision has not been touched across ≥2 impact runs |
| Updated vocabulary terms (if change introduces new actors, portals, or terms) | `hot/canonical-vocabulary.md` | When new canonical terms are confirmed |

**Note:** `impact` is the primary trigger for refreshing stale memory entries. After each approved impact run, check `hot/approved-decisions.md` for entries whose `Ngày chốt` predates this run by ≥2 impact cycles — surface them for re-confirmation.
