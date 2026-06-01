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
- **May read:** `paths.project_memory`, `paths.memory_index`, `paths.memory_hot_*`, selected `warm/` shard; downstream artifacts (frd, stories, srs, wireframes); `log.md` only when user requests audit
- **Must NOT read:** `cold/` (unless escalated)
- **Note:** `impact` is the only broad-read command.

**Memory freshness check:** Before using `paths.project_memory`, check its `Last Refresh Source` header. If it predates the last approved backbone or impact run, read it for context but note which entries may be stale. After the impact analysis is approved, offer to refresh the affected memory entries as part of the rerun path.

## Promotion Guidance

After impact analysis and user approval of a rerun path:
1. Document which memory shards/vocabulary/decisions need updating.
2. Prepare file-back record outline using `templates/project-memory-fileback-record-template.md`.
3. Pass outline to user for review before mutating step executes.

## Scope

Run the change-impact triage path only. **Do not mutate artifacts by default.**

Impact analysis is read-only. Approved write mode is opt-in:
- User must explicitly approve before any artifact is written.
- When approved, impact may write: `paths.change_request`, `paths.impact_report`, and update `paths.shared_staleness`.
- `core/contract.yaml` records `impact.mutable=false` and `outputs=[]` for the default analysis-only mode.
- Approved write mode uses `change_request` and `impact_report` templates and appends stale artifact records to `paths.shared_staleness`.

## Prerequisites

- Resolve slug, date, and module scope through the shared contract.
- Require change input: direct file path or pasted change text.
- Require `paths.intake`. If missing, print exact path and stop.
- Read `paths.backbone` when it exists.
- Read module-scoped downstream artifacts only when relevant to suspected impact:
  `paths.frd`, `paths.userstories_index`, `paths.usecases_index`, `paths.ascii_screen_index`, `paths.srs_spec`, `paths.srs_flows`, `paths.srs_states`, `paths.srs_erd`, `paths.srs`, `paths.screen_field_contract`, `paths.tool_lane_state`, `paths.make_guidelines`, `paths.make_prompt_pack`, `paths.prototype_conformance_checklist`, `paths.prototype_conformance_report`, `paths.design_doc`, `paths.plan`, `paths.shared_traceability`, `paths.shared_staleness`, `paths.shared_definitions`

## Decision Rules

Treat the current source of truth in this order:

1. `backbone`
2. otherwise `intake`

Reverse lane detection: if `paths.reverse_baseline_lock` exists, apply reverse classification before forward-lifecycle rules.

Classify the change into one or more buckets:

Standard: `wording-only`, `clarification-only`, `backbone-change`, `scope-lock-change`, `ui-impact`

Reverse lane (when reverse_baseline_lock exists):
- `as_built_drift` — code exists but is undocumented or contradicts baseline
- `future_state_request` — desired behavior not yet in code
- `mixed_change` — both; must be split before promotion
- `unverifiable_in_v1` — cannot classify from source alone; do not guess

Never merge `as_built_drift` and `future_state_request` into one rerun recommendation.

Impact anchors:

- intake: business problem, goals, out-of-scope, success metrics
- backbone: scope lock summary, feature map, FR/NFR backbone, actors, portal matrix, story map, UI coverage, artifact gates
- FRD: feature wording, workflows, business rules, integration points
- user stories: `userstories/us-*.md` story intent and acceptance criteria
- SRS source set: `usecases/uc-*.md` flows, `ascii-screen/*.md` screen behavior, `srs/spec.md` FR/NFR/rules, `srs/flows.md` module flows, `srs/states.md` state registry, `srs/erd.md` data model
- shared artifacts: `shared/traceability.md`, `shared/staleness.md`, `shared/definitions.md`
- UI artifacts: normalized screen-field contract, runtime `DESIGN.md` assumptions, tool-lane state, prompt/control pack, and review checklist/report

## Routing Rules

- Goals, out-of-scope, success metrics, scope decisions → route to `intake` first.
- Feature scope, FR/NFR intent, actors, acceptance-criteria intent, portal ownership, global nav schema → route to `backbone` first.
- Story wording or testable acceptance detail within existing backbone intent → route to `stories` (outputs `userstories/`).
- Use case flow, validation behavior, error states, screen behavior within existing backbone+story intent → route to `srs` (outputs `usecases/`, `ascii-screen/`, `srs/`).
- Screen inventory, state variants, navigation, overlays, field interactions → mark `ui-impact`; rerun `srs` after upstream rerun.
- Shared definitions or traceability gaps → route to `srs` rerun; do not update `shared/definitions.md` or `shared/traceability.md` directly without user approval.
- Never recommend `package` as first remediation step after a real requirement change.

Reverse lane routing (when reverse_baseline_lock exists):
- `as_built_drift` → `ba-start reverse promote --slug <slug> --evidence-ids <ids>`
- `future_state_request` → forward lifecycle (backbone / stories / srs)
- `mixed_change` → `ba-start reverse impact --slug <slug> --evidence-ids <ids>` to split first
- `unverifiable_in_v1` → surface to user; do not guess lane

## Output

Print: project/date, change type, source of truth, affected nodes, stale artifacts, read escalation, recommended path, exact commands, and focused questions only.

```text
Impact Delta

affected_node_ids: [scope | actor | FR/NFR | story | UC | SCR | rule | message IDs]
owner_artifact: [intake | backbone | stories | srs | wireframe artifacts | reverse_evidence_ledger]
stale_artifacts: [indexes or artifacts that must be refreshed by the rerun]
read_escalation: [none | READ_ESCALATION: impact read {path} due to {reason}]
reverse_lane: [absent | as_built_drift | future_state_request | mixed_change | unverifiable_in_v1]
guardrail_code: [none | reverse hard-guardrail code]
```

Rules:
- Map change to `affected_node_ids` before opening broad downstream context.
- Use `owner_artifact` to choose the smallest rerun path.
- Include index files in `stale_artifacts` when a CR can invalidate backbone_index, userstories_index, usecases_index, ascii_screen_index, srs_compile_receipt, shared_traceability, shared_staleness, screen_field_contract, tool_lane_state, make_guidelines, make_prompt_pack, prototype_conformance_checklist, or prototype_conformance_report.
- When stale artifacts are identified, recommend updating `paths.shared_staleness` with the stale artifact list and refresh commands. In approved write mode only, write the update directly.
- If CR cannot be mapped to a node, emit `read_escalation` and ask focused questions.
- When `reverse_lane` is not `absent`, print the exact reverse lane command before forward lifecycle commands.
- When a reverse hard guardrail is the blocker, set `guardrail_code` before any forward lifecycle command.
- Never omit `reverse_lane` field when `reverse_baseline_lock` exists.

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
