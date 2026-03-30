# BA-kit Skill Catalog

## Purpose

This catalog explains the single BA-kit skill, what it produces, and which agents support it.

## Skill

| Skill | When to Use | Related Templates | Related Agents | Typical Output |
| --- | --- | --- | --- | --- |
| `ba-start` | Full BA engagement or resumable step-level reruns from raw input to packaged deliverables | `intake-form-template.md`, `frd-template.md`, `user-story-template.md`, `srs-template.md`, `wireframe-input-template.md`, `wireframe-map-template.md` | `requirements-engineer`, `ui-ux-designer`, `ba-documentation-manager`, `ba-researcher` | Intake form + HTML, FRD + HTML, user stories + HTML, grouped SRS artifacts, wireframe input pack, wireframes, wireframe map, final browser-editable SRS HTML, quality review, artifact status |

## Workflow

`/ba-start` with no subcommand handles the entire lifecycle:

1. Accept raw input (file or text)
2. Parse and normalize into intake form
3. Gap analysis and clarifying questions
4. Work plan generation
5. FRD production
6. User story generation
7. Use case specification production
8. Screen Contract Lite production
9. Wireframe generation from the persisted wireframe input pack
10. Final screen description production with the persisted wireframe map when wireframes are completed
11. Unified browser-editable HTML packaging and quality review across all major BA artifacts

## Invocation

```text
/ba-start
/ba-start intake <file>
/ba-start frd --slug <slug>
/ba-start stories --slug <slug>
/ba-start srs --slug <slug>
/ba-start wireframes --slug <slug>
/ba-start package --slug <slug>
/ba-start status --slug <slug>
```

## Subcommands

| Command | Purpose | Prerequisite |
| --- | --- | --- |
| `intake` | Parse input, normalize intake, package intake HTML, and save the work plan | Raw file or pasted text |
| `frd` | Produce the FRD and FRD HTML only | Matching intake artifact |
| `stories` | Produce user stories and user-stories HTML only | Matching FRD artifact |
| `srs` | Produce grouped SRS artifacts, wireframe input pack, wireframes, wireframe map, and merged SRS | Matching FRD and user stories |
| `wireframes` | Re-run Step 9 from the persisted wireframe input pack or exact fallback sources | Wireframe input pack, or exact Group B + Group C / merged SRS fallback |
| `package` | Run quality review, validate existing packaged HTML artifacts, and regenerate unified SRS HTML | Merged SRS and non-missing wireframe state |
| `status` | Print artifact checklist with dates | Resolved slug and dated set |

Subcommand targeting rules:

- Use `--slug <slug>` first when rerunning an existing project.
- If exactly one slug exists in `plans/reports/`, BA-kit may use it automatically.
- If multiple slugs exist, BA-kit should stop and ask the user to choose.
- If one slug has multiple dated artifact sets, BA-kit should stop and ask which dated set to use.

## Agent Delegation

| Agent | Role in Workflow |
| --- | --- |
| `requirements-engineer` | FRD, user stories, use cases, Screen Contract Lite, final screen descriptions, validation |
| `ui-ux-designer` | Pencil wireframe generation from use cases and screen contract |
| `ba-documentation-manager` | Quality review, consistency, packaging |
| `ba-researcher` | Domain research when external context is needed |

Delegation is intentionally partitioned. Large SRS work should be split into grouped slices and passed downstream as narrow handoff packets with exact excerpts and trace IDs, not as full merged artifacts. If one delegated slice becomes too large to keep consistent, repartition and rerun only that slice.

Use [`templates/sub-agent-handoff-template.md`](../templates/sub-agent-handoff-template.md) as the default packet structure when delegation is non-trivial.
For non-trivial delegated work, also create a tracker under `plans/{date}-{slug}/delegation/` so `/ba-start status` can expose `queued`, `running`, `blocked`, `needs-repartition`, `completed`, or likely stalled slices.

## HTML Editing

Packaged HTML artifacts are meant to be edited in the browser. Update copy, swap images, and add or remove blocks directly in the rendered HTML instead of hand-editing source HTML.

`/ba-start status` reports regular artifacts as exists or missing with last-modified dates. Wireframes are reported as `completed`, `skipped`, `not-applicable`, or `missing` from the explicit wireframe-state marker, and completed runs should expose both the persisted wireframe input pack and wireframe map. Delegated slices should also appear from their trackers, with likely stalled slices flagged when heartbeats go stale.

## Expected Quality Bar

- Outputs reference business goals
- Every requirement has acceptance criteria
- Use cases cover primary and alternate flows
- Screen descriptions use field tables with Display/Behaviour/Validation rules
- Every SRS requirement, use case, and screen traces to user stories
- Diagrams use Mermaid
- Risks, assumptions, and open questions are visible
