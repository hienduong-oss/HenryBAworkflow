# BA-kit Internal Artifact Compactness Design

## Goal

Reduce BA-kit runtime context growth by making non-user-facing generated artifacts short, structured, and purpose-fit. The policy applies by artifact purpose, not by file extension.

## Problem

BA-kit now creates additional indexes, memory files, state files, handoff packets, and manifests to reduce full-artifact reads. These files are useful, but if written like user-facing documents they can become another token burden.

Internal artifacts should let an agent decide what to read or do next with minimal context. A user may inspect them quickly, but they are not polished deliverables.

## Artifact Profiles

BA-kit should classify generated outputs into three profiles:

| Profile | Purpose | Preferred Format | Style |
| --- | --- | --- | --- |
| `user_facing` | Deliverables intended for BA/stakeholder reading or package output | `.md`, `.html` | Clear, complete, polished |
| `agent_facing` | Navigators, indexes, packets, memory summaries, handoff briefs | compact `.md` unless machine-only | Short tables/lists, IDs, paths, freshness, route hints |
| `machine_facing` | State, manifests, counters, deterministic metadata | `.json`, `.yaml`, `.ndjson` when append-only | Parseable, no prose except labels |

The profile is more important than the extension. A `.md` file can still be internal if its job is agent navigation.

## Format Policy

- Use `.md` for `user_facing` deliverables and for `agent_facing` artifacts that benefit from fast human inspection.
- Use `.json` for manifests, state snapshots, counters, freshness metadata, and script-generated machine data.
- Use `.yaml` for stable configuration or contract-like data only.
- Use `.html` only for compiled package outputs.
- Use `.ndjson` for append-only machine logs only when human reading is not a priority.
- Avoid `.md` logs that grow unbounded in normal read scope.

## Compact Internal Artifact Style

All `agent_facing` artifacts must:

- state source artifact, source hash or freshness marker, generated command, and stale status when applicable
- provide IDs, paths, section names, owners, and short route hints
- avoid duplicating source-of-truth requirement text
- prefer tables or short bullet lists over narrative sections
- keep excerpts short and only when needed for routing
- include explicit escalation guidance when the index is insufficient

They must not:

- become summaries of the full project
- repeat full acceptance criteria, SRS content, or long source excerpts
- include polished explanation intended for stakeholders
- require downstream agents to read them as source of truth

## Initial Scope

Apply first to generated internal artifacts:

- `paths.source_chunk_index`
- `paths.backbone_index`
- `paths.stories_index`
- `paths.srs_index`
- `paths.project_memory`
- `paths.memory_index`
- `paths.memory_hot_*`
- `paths.memory_module_warm`
- `paths.wireframe_state`
- `paths.wireframe_map`
- delegation packets and review packets

Do not compact these user-facing/source-of-truth outputs in this phase:

- `paths.intake`
- `paths.backbone`
- `paths.frd`
- `paths.stories`
- `paths.srs`
- `paths.srs_group`
- `paths.project_home`
- `paths.collab_home`
- `paths.module_home`
- compiled HTML outputs

## Contract Changes

Add an `artifact_profiles` section to `core/contract.yaml` that maps path keys to one of:

- `user_facing`
- `agent_facing`
- `machine_facing`

Add a compactness rule to `core/contract-behavior.md`:

- internal artifacts are navigators or machine state, not deliverables
- generated internal `.md` files should be bounded and skim-readable
- if an internal artifact needs substantial prose, move that content to the source-of-truth artifact or revise the command flow

## Template Guardrails

Add contract-sync checks for selected internal templates:

- index templates should stay under a small byte threshold
- packet/state templates should stay bounded
- internal templates should contain source/freshness fields when relevant

The guardrail should detect accidental prose growth, not block intentional contract changes. Threshold changes must be explicit in the test or token budget.

## Runtime Behavior

When generating an internal artifact, the agent should:

1. identify the artifact profile
2. choose the smallest useful format
3. write route metadata first
4. include only targeted excerpts when needed
5. reference source-of-truth paths instead of duplicating content
6. mark stale/unknown status instead of guessing

When reading, downstream steps should read internal artifacts for navigation only, then open targeted source sections if needed.

## Success Criteria

- BA-kit can distinguish user deliverables from internal runtime artifacts.
- New internal artifacts default to compact style.
- Index/state/packet files remain useful for agent routing without becoming monolithic summaries.
- Users can still inspect internal `.md` files quickly when needed.
- Machine-only data is stored in parseable files instead of prose-heavy markdown.

## Out of Scope

- Rewriting all existing runtime docs for size.
- Converting every internal `.md` file to JSON/YAML.
- Changing user-facing deliverable templates.
- Removing current indexes or source-of-truth markdown artifacts.
