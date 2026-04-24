# BA Start Step - Status

This step requires:

- `core/contract.yaml`
- `core/contract-behavior.md`

## Memory Read Scope

- **Must read:** `core/contract.yaml`, `core/contract-behavior.md`
- **May read:** `paths.project_memory` header fields, `paths.memory_index` (activation state + shard freshness)
- **Must NOT read:** `log.md` (unless `--audit` flag), `warm/` shards, `cold/`

## Scope

Inspect the selected project set and print a checklist with artifact status, last-modified date, and any active delegated worker slices.

## Prerequisites

- Resolve slug and date using the shared contract.
- If slug or date resolution is ambiguous, stop and ask.

## Output Format

Print a checklist like this:

```text
Project: {slug}
Date set: {date}

[System Paths]
- [x] 01_intake/intake.md — 2026-03-26
- [x] 01_intake/plan.md — 2026-03-26
- [x] 02_backbone/backbone.md — 2026-03-26

[Module: auth-flow]
- [x] 03_modules/auth-flow/frd.md — 2026-03-26
- [x] 03_modules/auth-flow/user-stories.md — 2026-03-26
- [ ] 03_modules/auth-flow/srs.md — missing
- [ ] 03_modules/auth-flow/wireframe-input.md — missing

[Compiled]
- [x] 04_compiled/compiled-frd.html — 2026-03-26
- [x] 04_compiled/compiled-srs.html — 2026-03-26

[Designs]
- [ ] designs/{slug}/DESIGN.md — missing
- [!] wireframe handoff — skipped — 2026-03-26

[Memory]
- [x] 02_backbone/project-memory.md — 2026-03-26
- [x] 02_backbone/project-memory/index.md — 2026-03-26
- [ ] delegation/packets — not initialized
```

Status rules:

- For regular artifacts, print `exists` or `missing` with the last-modified date when present.
- For wireframe handoff, print the explicit wireframe state plus the marker date.
- When wireframe handoff is `completed`, also list the detected runtime design file, wireframe input pack, and wireframe map.
- Print compact memory, shard index, activation, owner, freshness, file-back, and packet registry metadata from `paths.project_memory` and `paths.memory_index` only.
- For delegated slices under `paths.delegation_root`, print the tracker state directly and mark `likely stalled` when the last heartbeat exceeds `states.stall_after_minutes`.
