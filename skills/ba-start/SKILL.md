---
name: ba-start
description: Single entry point for BA-kit. Accepts raw requirements (file or text), normalizes into an intake form, clarifies gaps, produces FRD, user stories, SRS, wireframes, and packages deliverables.
argument-hint: "[intake|frd|stories|srs|wireframes|package|status] [file|--slug]"
---

# BA Start

Use this skill to run an end-to-end business analysis engagement from raw input to packaged deliverables. This remains the single BA-kit skill, but it now supports step-level subcommands for resumable and partial runs.

## Invocation

```text
/ba-start
/ba-start intake <file>
/ba-start intake
/ba-start frd --slug <slug>
/ba-start stories --slug <slug>
/ba-start srs --slug <slug>
/ba-start wireframes --slug <slug>
/ba-start package --slug <slug>
/ba-start status --slug <slug>
```

## Priority Contract

Read this section first. Only continue to the detailed step sections when you need the exact production instructions for the selected command.

### Fast execution order

1. Parse `ARGUMENTS` before doing any work.
2. Resolve the subcommand: `intake`, `frd`, `stories`, `srs`, `wireframes`, `package`, or `status`.
3. Apply output defaults:
   - write BA deliverables in Vietnamese unless the user explicitly requests English
   - use `YYMMDD-HHmm` as the artifact-set `{date}` token
   - default UI-backed wireframes to Shadcn UI unless the user explicitly overrides it
4. Resolve the target scope with exact matching only:
   - explicit `--slug <slug>` first
   - otherwise use a single detected slug only
   - if multiple slugs exist, stop and ask
   - if multiple dated sets exist for the slug, stop and ask
5. Check prerequisites for the chosen command.
6. If any prerequisite is missing, print the missing exact path, print the exact prior subcommand to run, and stop.
7. Before mutating `frd`, `stories`, `srs`, `wireframes`, or `package`, if the target output already exists, ask whether to overwrite or stop.

### Command routing summary

| Command | Runs | Must read first | Produces |
| --- | --- | --- | --- |
| no subcommand | Full workflow | raw input | intake, FRD, stories, SRS, wireframes, package |
| `intake` | Steps 1-5 | raw input | intake + intake HTML + plan |
| `frd` | Step 6 | intake | FRD + FRD HTML |
| `stories` | Step 7 | FRD | user stories + user stories HTML |
| `srs` | Steps 8-11 | FRD + user stories | grouped SRS + wireframe-input + merged SRS + wireframes |
| `wireframes` | Step 9 only | wireframe-input or exact wireframe source set | `.pen`, exports, wireframe-map, wireframe-state |
| `package` | Step 12 only | merged SRS + non-missing wireframe-state | SRS HTML + delivery summary |
| `status` | inspection only | none | checklist output |

### Non-negotiable stop conditions

- Never silently choose a slug or dated set by mtime.
- Never use broad `*-{slug}*` matching when exact artifact patterns are available.
- `wireframes` is read-only on upstream BA artifacts. It may regenerate only design outputs, `wireframe-map`, and the wireframe-state marker.
- `package` must block only when wireframe state is `missing`.
- If no wireframe-state marker exists, treat it as `not-applicable` only when the SRS set has no UI-backed screens or Screen Contract Lite section. Otherwise treat it as `missing`.

## Shared Routing And State Rules

### Core operating defaults

- Write BA deliverables in Vietnamese by default unless the user explicitly requests English.
- Treat the artifact-set `{date}` token as `YYMMDD-HHmm` consistently across report filenames and `plans/{date}-{slug}/plan.md`.
- For UI-backed scope, use Shadcn UI as the default wireframe and UI-handoff design-system baseline unless the user explicitly overrides it.

### Argument parsing

Parse `ARGUMENTS` before doing any work.

1. Read tokens left to right.
2. Extract `--slug <slug>` if present.
3. The first remaining token that matches one of these values is the subcommand:
   - `intake`
   - `frd`
   - `stories`
   - `srs`
   - `wireframes`
   - `package`
   - `status`
4. If there is no subcommand:
   - run the full workflow
   - if one free argument remains, treat it as the initial file path or pasted-input hint for Step 1
5. For `intake`, one free argument may be a direct file path.
6. For `frd`, `stories`, `srs`, `wireframes`, `package`, and `status`, reject unexpected free arguments, print the supported syntax, and stop.
7. If the first token looks like an unknown subcommand, print the supported subcommand list and stop.

### Routing rules

- No subcommand means full workflow. Keep the existing lifecycle order intact.
- `intake` runs Steps 1-5 only.
- `frd` runs Step 6 only.
- `stories` runs Step 7 only.
- `srs` runs Steps 8-11 and includes wireframes by default.
- `wireframes` runs Step 9 only as a re-run path from the persisted wireframe input pack or exact fallback sources.
- `package` runs Step 12 only.
- `status` inspects current artifacts and prints a checklist with dates.

### Slug resolution

Subcommands that operate on an existing project must resolve the target project slug in this order:

1. Use the explicit `--slug <slug>` value when provided.
2. Otherwise inspect `plans/reports/` for exact BA-kit artifact patterns and collect unique candidate slugs.
3. If exactly one candidate slug exists, use it.
4. If multiple candidate slugs exist, print the candidate list, ask the user to choose a slug or rerun with `--slug`, and stop.

For mutating subcommands (`frd`, `stories`, `srs`, `wireframes`, `package`), never silently choose a slug by mtime.

### Dated set resolution

After resolving the slug, resolve the target dated artifact set.

1. Inspect exact filenames for the selected slug:
   - `plans/reports/intake-{slug}-{date}.md`
   - `plans/reports/frd-{date}-{slug}.md`
   - `plans/reports/user-stories-{date}-{slug}.md`
   - `plans/reports/srs-{date}-{slug}.md`
   - `plans/reports/srs-{date}-{slug}-group-c.md`
   - `plans/reports/wireframe-input-{date}-{slug}.md`
   - `plans/reports/wireframe-map-{date}-{slug}.md`
   - `plans/reports/wireframe-state-{date}-{slug}.md`
   - `plans/{date}-{slug}/plan.md`
2. Build candidate `{date}` sets from exact filename matches only.
3. If exactly one dated set exists for the slug, use it.
4. If multiple dated sets exist for that slug and the command is `frd`, `stories`, `srs`, `wireframes`, `package`, or `status`, print the available dates, ask the user to choose the target dated set, and stop until the user chooses.
5. Never silently select the latest dated set by mtime.

### Exact artifact matching

Use exact filename patterns, not broad `*-{slug}*` matching. Print the specific missing artifact path when a prerequisite check fails.

### Legacy artifact detection

Before mutating `frd`, `stories`, `srs`, `wireframes`, `package`, or `status`:

1. Check whether `plans/reports/` contains legacy BA-kit report names such as:
   - `plans/reports/002-intake-form.md`
   - `plans/reports/002-gap-analysis.md`
   - `plans/reports/002-*.md`
2. If legacy reports are present but the current exact-pattern artifacts for the selected slug/date are missing, stop and report:
   - that a legacy artifact suite was detected
   - that the current playbook will not infer slug/date or prerequisite state from legacy filenames
   - the exact next action: rerun `intake`, migrate the old reports manually, or point the agent at the current-contract artifacts
3. Do not mix legacy-named reports with the current exact-pattern lifecycle in one silent pass.

### Prerequisite reference

| Command | Requires | Produces |
| --- | --- | --- |
| `intake` | Raw input (file or pasted text) | `plans/reports/intake-{slug}-{date}.md`, `plans/reports/intake-{slug}-{date}.html`, `plans/{date}-{slug}/plan.md` |
| `frd` | `plans/reports/intake-{slug}-{date}.md` | `plans/reports/frd-{date}-{slug}.md`, `plans/reports/frd-{date}-{slug}.html` |
| `stories` | `plans/reports/frd-{date}-{slug}.md` | `plans/reports/user-stories-{date}-{slug}.md`, `plans/reports/user-stories-{date}-{slug}.html` |
| `srs` | `plans/reports/frd-{date}-{slug}.md`, `plans/reports/user-stories-{date}-{slug}.md` | `plans/reports/srs-{date}-{slug}.md`, `plans/reports/wireframe-input-{date}-{slug}.md`, and any supporting `srs-{date}-{slug}-group-*.md` files |
| `wireframes` | `plans/reports/wireframe-input-{date}-{slug}.md` or exact fallback sources for pack generation | `designs/{slug}/*.pen`, `designs/{slug}/exports/**`, `plans/reports/wireframe-map-{date}-{slug}.md`, `plans/reports/wireframe-state-{date}-{slug}.md` |
| `package` | `plans/reports/srs-{date}-{slug}.md`; wireframes may be completed, skipped, or not-applicable | `plans/reports/srs-{date}-{slug}.html`, delivery summary |
| `status` | None | Checklist output only |

### Missing prerequisite behavior

If a required artifact is missing:

1. Print the missing exact path.
2. Print the exact subcommand to run first.
3. Stop. Do not chain forward automatically.

### Overwrite handling

Before mutating `frd`, `stories`, `srs`, `wireframes`, or `package`:

1. Check whether the target artifact already exists.
2. If it exists, print the path and ask whether to overwrite or stop.
3. If the user declines or does not approve, stop without mutating anything.

### Context-loss recovery

If exploration consumed too much context or the host truncates part of the conversation:

1. Reconstruct the current target from the already-resolved subcommand, slug, dated set, and on-disk prerequisite artifacts.
2. Continue from the next unresolved step when those values are still unambiguous.
3. Do not ask the user to restate the original request just because intermediate exploration consumed context.
4. Ask the user again only when one of these is genuinely unknown:
   - the target subcommand
   - the slug
   - the dated set
   - overwrite approval for an existing target artifact
5. When recovering, print a short status line with:
   - current command
   - resolved slug
   - resolved date
   - next exact step
6. Do not restart broad artifact discovery after the target scope has already been accepted.

### Accepted-scope execution lock

For mutating rerun commands (`frd`, `stories`, `srs`, `wireframes`, `package`):

1. Once the user has explicitly approved the next step, treat the target command as locked for the current run.
2. After that approval, do not fall back to generic prompts such as:
   - "What would you like me to help with?"
   - "What would you like me to do with this document?"
   - "Please restate what you need"
3. Continue from the resolved command, slug, dated set, and exact prerequisites on disk unless one of those values is genuinely unknown.
4. If context pressure occurs after the lock is established, print a short recovery line and resume the exact step instead of reopening discovery.
5. Reading one prerequisite artifact does not reset the execution lock.

### Delegated run tracking

When a non-trivial BA slice is delegated to a sub-agent, persist a dedicated run-status tracker under:

`plans/{date}-{slug}/delegation/{owner}-{slice}.md`

Rules:

1. The orchestrator creates the tracker before spawning the worker.
2. Use one tracker file per delegated slice so two workers never edit the same tracker.
3. The tracker must record:
   - owner
   - slice name
   - target artifact
   - current status: `queued`, `running`, `completed`, `needs-repartition`, `blocked`, `failed`, or `stalled`
   - started time
   - last heartbeat time
   - stall threshold in minutes
   - expected outputs
   - latest milestone or blocker
4. The delegated packet must include the exact tracker path.
5. The worker updates the tracker:
   - immediately on start by changing status to `running`
   - after each major milestone
   - at least every 5 minutes during long-running work
   - on exit with `completed`, `needs-repartition`, `blocked`, or `failed`
6. If no heartbeat arrives within 10 minutes and the target artifact has not advanced, treat the slice as `stalled` instead of waiting blindly.
7. On a suspected stall, stop broad waiting behavior and do one of:
   - inspect the tracker and current target artifact
   - rerun the same slice with a narrower packet
   - ask the user whether to retry or stop if the next action is ambiguous
8. The `status` subcommand should surface active delegation trackers for the selected slug/date and flag likely stalls.

### Wireframe state model

Persist an explicit wireframe-state marker after every Step 9 run at:

`plans/reports/wireframe-state-{date}-{slug}.md`

Use this structure:

```md
# Wireframe State

- Slug: {slug}
- Date: {date}
- State: completed | skipped | not-applicable | missing
- Source: plans/reports/wireframe-input-{date}-{slug}.md OR exact fallback source set
- Input Pack: plans/reports/wireframe-input-{date}-{slug}.md
- Mapping: plans/reports/wireframe-map-{date}-{slug}.md
- Artifacts:
  - designs/{slug}/{artifact-name}.pen
- Exports:
  - designs/{slug}/exports/{artifact-name}/SCR-xx-name.png
- Updated: YYYY-MM-DD
- Notes: short rationale
```

State meanings:

- `completed`: `.pen` artifacts and expected exports were generated.
- `skipped`: the user explicitly chose to skip wireframes in Step 9.
- `not-applicable`: the selected scope has no UI-backed screens or no Screen Contract Lite requirement.
- `missing`: wireframes are required for the selected SRS set but the artifacts are absent or the run failed before completion.

`package` must block only when the state is `missing`.

`status` must print the explicit wireframe state and the marker last-modified date. If no marker exists:

- treat the state as `not-applicable` only when the selected SRS set has no UI-backed screens or Screen Contract Lite section
- otherwise treat it as `missing`

## Full Workflow

When no subcommand is provided, run the complete lifecycle in order:

1. `intake`
2. `frd`
3. `stories`
4. `srs`
5. `package`

Preserve the current behavior of the full workflow: accept raw input, perform clarification, produce all downstream artifacts, generate wireframes before final screen descriptions, and finish with packaged HTML deliverables.

## Subcommand: intake

Run Steps 1-5 only.

### Prerequisites

- Requires raw input as a file path or pasted text.
- If no input argument is provided, prompt the user for either a file path or pasted text.
- `--slug <slug>` may override the derived project slug.

### Step 1 - Accept input

Ask the user to provide one of:

- A file path (PDF, MD, TXT, image, DOCX)
- Pasted text containing requirements or business context

File reading approach:

- PDF: use native PDF-capable reading tooling
- Markdown or text: read directly
- Images: use multimodal reading
- Word (`.docx`): use multimodal extraction or ask the user to export to PDF or Markdown first

### Step 2 - Parse and normalize

Read the source material and extract content into the [intake-form-template.md](../../templates/intake-form-template.md) structure:

- Project name, date, requester
- Business context (problem, goals, stakeholders mentioned)
- Raw requirements (extracted verbatim)
- Screens or UI mentioned
- Processes or workflows mentioned
- Constraints, assumptions, compliance needs
- Open questions identified during parsing

Save the completed intake form to `plans/reports/intake-{slug}-{date}.md`.

### Step 3 - Gap analysis

Review the normalized intake against a BA completeness checklist:

- Are stakeholders identified with roles and influence?
- Is there a clear problem statement and measurable goal?
- Are scope boundaries defined (in-scope vs out-of-scope)?
- Are success criteria or KPIs stated?
- Are compliance or regulatory obligations mentioned?
- Are UI screens described enough to wireframe?
- Are processes described enough to map?

Flag each gap explicitly.

### Step 4 - Ask clarifying questions

Present the identified gaps to the user as 3-8 targeted questions. Focus on:

- Output language
- Missing stakeholders or decision makers
- Ambiguous scope boundaries
- Unstated success criteria
- Regulatory or compliance context
- Priority and sequencing preferences

Incorporate the answers back into the intake form.

Export the intake artifact to the shared BA-kit HTML shell:

```bash
python scripts/md-to-html.py plans/reports/intake-{slug}-{date}.md
```

Output: `plans/reports/intake-{slug}-{date}.html`

### Step 5 - Generate work plan

Based on the normalized intake, produce a scoped work plan covering:

#### Deliverable selection

| Condition | Deliverable | Template |
| --- | --- | --- |
| Detailed functional spec needed | FRD | `frd-template.md` |
| Agile team needs stories | User stories | `user-story-template.md` |
| System spec with screens, use cases, or test cases | SRS | `srs-template.md` |
| UI screens mentioned | Wireframes | `designs/{slug}/` via Pencil MCP, grouped by flow or module with frame-level screen mapping |

SRS default routing: include SRS alongside FRD when the intake contains any of:

- UI screens or screen descriptions
- System-level interactions (APIs, integrations, data flows)
- Mobile or web application scope
- Test case or acceptance testing expectations

#### Agent delegation

| Agent | When |
| --- | --- |
| `requirements-engineer` | FRD, user stories, SRS production |
| `ui-ux-designer` | Pencil wireframe generation from SRS screens |
| `ba-documentation-manager` | Final packaging and quality review |
| `ba-researcher` | Domain research when external context is needed |

Execution order:

`Intake -> FRD -> User Stories -> SRS -> Wireframes -> Quality Review`

UI design system default: unless the user explicitly asks for another system, use Shadcn UI as the default component and layout baseline for wireframes and UI-oriented handoff artifacts.

Save the work plan to `plans/{date}-{slug}/plan.md`.

## Subcommand: frd

Run Step 6 only.

### Prerequisites

- Resolve the slug and dated set using the shared rules.
- Require `plans/reports/intake-{slug}-{date}.md`.
- If the intake artifact is missing, print the exact missing path, tell the user to run `/ba-start intake`, and stop.
- Trust the user intent. Do not re-check whether the work plan selected FRD.
- Run a narrow FRD preflight before reading content:
  - read only `plans/reports/intake-{slug}-{date}.md` and `plans/{date}-{slug}/plan.md` when it exists
  - do not scan unrelated files in `plans/reports/` once the target slug/date is resolved
  - if only legacy-named report suites exist for the apparent project, stop with the legacy artifact detection message instead of inferring from them

### Output

- `plans/reports/frd-{date}-{slug}.md`
- `plans/reports/frd-{date}-{slug}.html`

### Step 6 - Produce FRD

FRD execution rules:

- Start from the exact intake artifact only, plus the exact plan path when it exists.
- If the user already confirmed that FRD authoring should proceed, continue from the resolved intake instead of reopening scope discovery.
- Do not ask what the user wants to do with the document after the FRD step has been accepted.

Produce the FRD using [frd-template.md](../../templates/frd-template.md):

- Functional overview
- User personas
- Feature list with MoSCoW priorities
- Workflows (Mermaid)
- Data requirements
- Business rules
- Integration points
- Acceptance criteria

Save to `plans/reports/frd-{date}-{slug}.md`.

Export FRD to HTML for rendered Mermaid workflows:

```bash
python scripts/md-to-html.py plans/reports/frd-{date}-{slug}.md
```

Output: `plans/reports/frd-{date}-{slug}.html`

## Subcommand: stories

Run Step 7 only.

### Prerequisites

- Resolve the slug and dated set using the shared rules.
- Require `plans/reports/frd-{date}-{slug}.md`.
- If the FRD artifact is missing, print the exact missing path, tell the user to run `/ba-start frd --slug {slug}`, and stop.
- Run a narrow stories preflight before reading content:
  - read only `plans/reports/frd-{date}-{slug}.md`
  - read `plans/{date}-{slug}/plan.md` only when it exists and only if it adds needed scope context
  - do not scan unrelated files in `plans/reports/` once the target slug/date is resolved
  - if only legacy-named report suites exist for the apparent project, stop with the legacy artifact detection message instead of inferring from them

### Output

- `plans/reports/user-stories-{date}-{slug}.md`
- `plans/reports/user-stories-{date}-{slug}.html`

### Step 7 - Produce user stories

Stories execution rules:

- Start from the exact FRD artifact only, plus the exact plan path when it is genuinely needed.
- If the user already confirmed that user-story generation should proceed, continue from the resolved FRD instead of reopening discovery.
- Do not ask what the user wants to do with the document after the stories step has been accepted.

Generate Agile user stories from the FRD feature list using [user-story-template.md](../../templates/user-story-template.md):

- Epic and feature breakdown
- User stories with acceptance criteria (Given/When/Then)
- INVEST validation
- Story-to-screen alignment when UI exists

User stories with their acceptance criteria become the primary input for SRS, wireframes, and downstream artifacts. Every SRS functional requirement, use case, and screen description should trace back to one or more user stories.

Save to `plans/reports/user-stories-{date}-{slug}.md`.

Export user stories to HTML using the shared BA-kit shell:

```bash
python scripts/md-to-html.py plans/reports/user-stories-{date}-{slug}.md
```

Output: `plans/reports/user-stories-{date}-{slug}.html`

## Subcommand: srs

Run Steps 8-11 only. This path includes wireframes by default.

### Prerequisites

- Resolve the slug and dated set using the shared rules.
- Require:
  - `plans/reports/frd-{date}-{slug}.md`
  - `plans/reports/user-stories-{date}-{slug}.md`
- If a required artifact is missing, print the exact missing path, tell the user which subcommand to run first, and stop.
- Run an SRS preflight before reading content:
  - read only the resolved intake, FRD, user stories, and `plans/{date}-{slug}/plan.md` when it exists
  - do not scan unrelated files in `plans/reports/` once the target slug/date is resolved
  - if only legacy-named report suites exist for the apparent project, stop with the legacy artifact detection message instead of inferring from them

### Output

- `plans/reports/srs-{date}-{slug}-group-a.md`
- `plans/reports/srs-{date}-{slug}-group-b.md`
- `plans/reports/srs-{date}-{slug}-group-c.md`
- `plans/reports/srs-{date}-{slug}-group-d.md`
- `plans/reports/srs-{date}-{slug}-group-e.md`
- `plans/reports/srs-{date}-{slug}-group-f.md`
- `plans/reports/srs-{date}-{slug}.md`
- `plans/reports/wireframe-input-{date}-{slug}.md`
- Any wireframe artifacts and the wireframe-state marker produced during Step 9

### Step 8 - Produce SRS core, use cases, and Screen Contract Lite

SRS is the largest artifact. Produce it in dependency order so wireframes are generated before final screen descriptions are expanded.

SRS preflight execution rules:

- Start from the exact prerequisite set only. Do not read every report in `plans/reports/` to "understand the full picture".
- Trust the accepted scope. If the user has already confirmed that SRS authoring should proceed, continue from the resolved FRD and user stories instead of reopening discovery.
- Pull in extra analysis artifacts only when the exact SRS slice needs them and cite the exact path or section.
- If an extra artifact is useful but non-essential, note it as optional context instead of blocking the run.

Provide the relevant upstream context to the SRS production owner:

- Matching intake summary
- FRD features and business rules
- User stories with acceptance criteria

Sub-agent context management:

- Pass only relevant sections of upstream artifacts, not full documents.
- Group A receives: intake summary, FRD features and business rules, user stories.
- Group B receives: Group A FR table and user stories.
- Group C receives: Group B use cases and user stories.
- Group D receives: Group A FR table and FRD technical sections.
- Group E receives: Group B use cases, Group C screen contract, and wireframe mapping.
- Group F receives: FR IDs, UC IDs, SCR IDs, and the final group outputs.
- When a group would produce more than 15 use cases or 10 screens, split into sub-groups.

Sub-agent handoff packet:

- Every delegated packet must include only:
  - objective and target artifact path
  - exact write scope
  - delegation status tracker path
  - exact upstream excerpts needed for that slice
  - FR, UC, SCR, or story IDs needed for traceability
  - expected output sections
  - heartbeat cadence and stall threshold
- Do not pass full merged artifacts when a section excerpt is sufficient.
- Do not repeat the full playbook, full rules, and full templates inside every delegated call. The orchestrator should resolve the workflow first, then pass only the relevant constraints.
- If the handoff packet cannot fit into one concise brief with a few targeted excerpts, repartition before spawning.

Delegation fallback:

- If a delegated worker lacks required context, it must stop and return the exact missing sections or IDs instead of inferring.
- If a delegated worker receives a scope that is too large to keep consistent, it must return `NEEDS_REPARTITION` with:
  - the overloaded artifact or section
  - the reason the scope is too large
  - the smallest viable split proposal
  - the exact upstream sections needed for the rerun
- On `NEEDS_REPARTITION`, rerun only the affected group or subgroup. Do not restart the whole SRS pipeline.

Delegation packet template:

```md
# Delegation Packet

- Owner: [requirements-engineer | ui-ux-designer | ba-documentation-manager | ba-researcher]
- Objective: [single concrete goal]
- Target Artifact: [exact path]
- Allowed Write Scope: [exact section(s) or file(s)]
- Delegation Status Path: [plans/{date}-{slug}/delegation/{owner}-{slice}.md]
- Heartbeat Cadence: [default: every major milestone and at least every 5 minutes]
- Stall Threshold Minutes: [default: 10]
- Trace IDs:
  - FR: [...]
  - UC: [...]
  - SCR: [...]
  - Stories: [...]
- Required Upstream Excerpts:
  - [artifact path + exact section]
  - [artifact path + exact section]
- Constraints:
  - [template/rule/design-system constraint only if relevant]
- Expected Output:
  - [exact sections or deliverables]
- Stop Conditions:
  - stop if required upstream context is missing
  - stop if scope is too large to keep terminology and traceability consistent
```

Repartition response template:

```md
NEEDS_REPARTITION

- Overloaded Scope: [artifact/section]
- Reason: [why the current slice is too large or underspecified]
- Smallest Viable Split:
  - [slice 1]
  - [slice 2]
- Required Upstream Inputs For Rerun:
  - [exact path + section]
  - [exact IDs]
```

#### Group A - Core

Sections:

- Purpose and Scope
- Overall Description
- Functional Requirements table

Output: `plans/reports/srs-{date}-{slug}-group-a.md`

#### Group B - Behavioral

Sections:

- Use Case Specifications

Output: `plans/reports/srs-{date}-{slug}-group-b.md`

Consistency rules:

- Each use case links to user stories and screens.
- Actor actions use the same terminology as the user stories and FRD.

#### Group C - Screen Contract Lite

Sections:

- Screen Contract Lite
- Screen Inventory

Output: `plans/reports/srs-{date}-{slug}-group-c.md`

Consistency rules:

- Each primary screen links to its use cases and user stories.
- Screen Contract Lite must define screen IDs, entry and exit conditions, key actions, and required states.
- Modal, dialog, drawer, and overlay screens with their own interaction logic are primary screens, not supporting states.

#### Step 8.1 - Build wireframe input pack

After Group B and Group C are complete, assemble a persisted wireframe input artifact before any design work starts.

Source inputs:

- `plans/reports/srs-{date}-{slug}-group-b.md`
- `plans/reports/srs-{date}-{slug}-group-c.md`
- relevant FRD and user-story excerpts needed for traceability

Save to `plans/reports/wireframe-input-{date}-{slug}.md`.

The wireframe input pack must contain:

- artifact set information and app type
- exact use case excerpts needed for each primary screen
- Screen Contract Lite
- Screen Inventory
- proposed artifact grouping plan
- stop conditions for missing context or overloaded screen sets

#### Group D - Technical

Sections:

- Non-functional requirements
- Data flow diagrams
- ERD
- API specifications
- Constraints

Output: `plans/reports/srs-{date}-{slug}-group-d.md`

### Step 9 - Generate wireframes from use cases and Screen Contract Lite

Run the Step 9 workflow exactly as defined in the `wireframes` subcommand below, but treat it as part of the SRS pipeline and keep the same `{date}` set.

### Step 10 - Produce final screen descriptions

After Step 9 resolves, expand the full Screen Descriptions from:

- Use Case Specifications
- Screen Contract Lite
- `plans/reports/wireframe-map-{date}-{slug}.md` when wireframe state is `completed`
- Supporting frame inventory

If wireframes are `skipped` or `not-applicable`, expand the screen descriptions from use cases and Screen Contract Lite only, and keep Pencil references explicitly absent.

If wireframe state is `completed` but `plans/reports/wireframe-map-{date}-{slug}.md` is missing, stop and rerun `/ba-start wireframes --slug {slug}` before expanding final screen descriptions.

Output: `plans/reports/srs-{date}-{slug}-group-e.md`

Screen field table format:

| Field Name | Field Type | Description |
| --- | --- | --- |
| [Field] | [Type] | Display: [...] / Behaviour: [...] / Validation: [...] |

The description column contains up to three rule categories as needed:

- Display Rules: visibility, defaults, read-only conditions, formatting
- Behaviour Rules: on-change actions, auto-fill, cascading, navigation triggers
- Validation Rules: required, format, range, cross-field, error messages

### Step 10.1 - Produce validation pack

Produce the validation and traceability pack from the completed SRS sections.

Sections:

- Test Cases
- Glossary
- Traceability cross-references

Output: `plans/reports/srs-{date}-{slug}-group-f.md`

### Step 11 - Assembly and quality review

After all groups complete:

1. Merge groups into a single SRS following `srs-template.md` section order.
2. Run a cross-artifact consistency check:
   - Every UC step maps to a screen field or action and vice versa.
   - Screen Contract Lite entries have matching wireframes and final screen descriptions.
   - UC actor actions use the same wording as screen User Actions.
   - UC system responses match screen Behaviour Rules.
   - UC alternate flows are reflected in screen Error or States.
   - Field names are identical between UC steps, screen field tables, and wireframe labels.
   - User story acceptance criteria are covered by UC postconditions and screen Validation Rules.
3. Resolve UC placeholder references in screens.
4. Resolve ID conflicts across namespaces.
5. Verify every SCR and UC traces back to user stories.
6. Save to `plans/reports/srs-{date}-{slug}.md`.
7. Delete group fragments only after the merged SRS is verified.

Execution order:

```text
Group A
  -> Group B
  -> Group D
Group B -> Group C
Group C -> Wireframes
Wireframes -> Group E
Group E -> Group F
Group F -> Assembly
```

Failure handling: if a grouped pass fails, retry once. If it still fails, complete that group inline.

## Subcommand: wireframes

Run Step 9 only. This path must be read-only on upstream artifacts and regenerate only design outputs, `wireframe-map`, and the explicit wireframe-state marker.

### Prerequisites

- Resolve the slug and dated set using the shared rules.
- Resolve the wireframe source in this order:
  1. `plans/reports/wireframe-input-{date}-{slug}.md`
  2. exact pair `plans/reports/srs-{date}-{slug}-group-b.md` + `plans/reports/srs-{date}-{slug}-group-c.md`
  3. `plans/reports/srs-{date}-{slug}.md` only when Use Case Specifications, Screen Contract Lite, and Screen Inventory are already assembled there
- If source 2 or 3 is used, build or refresh `plans/reports/wireframe-input-{date}-{slug}.md` before generating wireframes.
- If none of the sources exist, print all expected paths, tell the user to run `/ba-start srs --slug {slug}`, and stop.

### Output

- `designs/{slug}/{artifact-name}.pen`
- `designs/{slug}/exports/{artifact-name}/SCR-xx-name.png`
- `plans/reports/wireframe-map-{date}-{slug}.md`
- `plans/reports/wireframe-state-{date}-{slug}.md`

### Step 9.1 - Resolve wireframe input pack

Use `plans/reports/wireframe-input-{date}-{slug}.md` as the primary wireframe generation source.

If the pack is missing but fallback sources exist:

- assemble the pack first from exact use case excerpts, Screen Contract Lite, and Screen Inventory
- save it before continuing

Parse the input pack to build the generation plan:

- group related screens into one or more Pencil artifacts by flow, module, or journey
- treat modal, dialog, and drawer overlays with flow impact as primary screens
- for each primary screen, derive required supporting frames from the documented states, validation rules, table or list behavior, and feedback surfaces

### Step 9.2 - Ask for wireframe preference

If Step 9 runs as part of the full `/ba-start` or `/ba-start srs` pipeline and the user has not explicitly asked to skip or manually choose screens, default to:

- Generate all wireframes automatically

If Step 9 runs through the standalone `wireframes` subcommand without an explicit preference, ask:

```text
The screen contract defines {N} primary screens. How should I generate wireframes?
- Generate all wireframes automatically
- Let me pick which screens
- Skip wireframes
```

If the user skips:

- persist `plans/reports/wireframe-state-{date}-{slug}.md` with `State: skipped`
- stop without changing upstream artifacts

If the scope has no UI-backed screens:

- persist the marker with `State: not-applicable`
- stop

If wireframes are expected but generation fails before completion:

- persist the marker with `State: missing`
- stop and report the failure

### Step 9.3 - Generate Pencil wireframes and mapping

For each approved screen group:

1. Read the linked use case excerpts, Screen Contract Lite entries, and Screen Inventory rows from the wireframe input pack.
2. Verify that the wireframe intent matches the same actions, flow steps, and required states.
3. Use `web-app` or `mobile-app` guidelines as appropriate.
4. Use Shadcn UI as the default design-system baseline unless the user explicitly overrides it.
5. Create or update one `.pen` artifact per approved screen group.
6. Create one frame per primary screen and one frame per required supporting state or view.
7. Validate screenshots against the Use Cases and Screen Contract Lite.
8. Record screen-to-artifact-to-frame mapping, including supporting frames and export targets, for every generated artifact.
9. Save each artifact to `designs/{slug}/{artifact-name}.pen`.

### Step 9.4 - Export wireframes to PNG

Export each relevant primary frame to PNG for embedding in the final SRS HTML:

```text
designs/{slug}/exports/{artifact-name}/SCR-xx-name.png
```

After successful export:

- persist `plans/reports/wireframe-map-{date}-{slug}.md` with the final artifact, frame, and export mapping
- persist `plans/reports/wireframe-state-{date}-{slug}.md` with `State: completed`
- list the input-pack, mapping, artifact, and export paths in the marker

## Subcommand: package

Run Step 12 only.

### Prerequisites

- Resolve the slug and dated set using the shared rules.
- Require `plans/reports/srs-{date}-{slug}.md`.
- If the merged SRS is missing, print the exact path, tell the user to run `/ba-start srs --slug {slug}`, and stop.
- Read `plans/reports/wireframe-state-{date}-{slug}.md` when present.
- If the wireframe state is `missing`, print the marker path, tell the user to run `/ba-start wireframes --slug {slug}`, and stop.
- If the wireframe state is `completed`, `skipped`, or `not-applicable`, continue.

### Output

- `plans/reports/srs-{date}-{slug}.html`
- Delivery summary

### Step 12 - Package deliverables

Run a final packaging and quality pass:

- Keep the default `package` scope narrow: validate the existing artifact set, then regenerate only `plans/reports/srs-{date}-{slug}.html`.
- Do not treat `package` as a full rebuild of intake, FRD, user-stories, and SRS HTML in one delegated pass unless the user explicitly asks for a full HTML repack.
- Verify all deliverables follow their templates.
- Check cross-references between FRD, user stories, and SRS.
- Verify user-story traceability: every SRS FR, UC, and SCR maps to at least one user story.
- Run a cross-artifact consistency audit:
  - UC actor actions match screen User Actions.
  - Screen Contract Lite entries match both the wireframes and the final screen descriptions.
  - When wireframes are completed, wireframe-map entries match the final Pencil artifact paths, frame names, and exported PNG references used by the SRS.
  - UC system responses match screen Behaviour Rules.
  - Field names are identical across UC steps, screen field tables, and wireframes.
  - User story acceptance criteria are covered by UC postconditions and screen Validation Rules.
  - FRD features are fully covered by user stories and SRS requirements.
- Validate naming conventions and file structure.
- Verify the target SRS HTML, plus any already-existing intake/FRD/user-stories HTML artifacts, use the shared BA-kit HTML shell and document metadata header.
- Flag broken links or missing sections.
- Produce a delivery summary.

### Step 12.1 - Generate unified SRS HTML with embedded wireframes

Convert the merged SRS markdown to HTML with wireframe images embedded inline:

```bash
python scripts/md-to-html.py plans/reports/srs-{date}-{slug}.md
```

Output: `plans/reports/srs-{date}-{slug}.html`

The final HTML should present:

- Use Case Specifications
- Wireframe images for primary screens when present
- Final Screen Descriptions
- Remaining SRS sections needed for traceability and review

### Step 12.2 - Final output structure

```text
plans/
  reports/
    intake-{slug}-{date}.md
    intake-{slug}-{date}.html
    frd-{date}-{slug}.md
    frd-{date}-{slug}.html
    user-stories-{date}-{slug}.md
    user-stories-{date}-{slug}.html
    srs-{date}-{slug}.md
    srs-{date}-{slug}.html
    wireframe-input-{date}-{slug}.md
    wireframe-map-{date}-{slug}.md
    wireframe-state-{date}-{slug}.md
  {date}-{slug}/
    plan.md
    delegation/
      requirements-engineer-group-a.md
      ui-ux-designer-auth-flow.md
designs/
  {slug}/
    auth-flow.pen
    checkout.pen
    exports/
      auth-flow/
        SCR-01-login.png
        SCR-02-otp.png
      checkout/
        SCR-05-review-order.png
```

The HTML files are the primary stakeholder deliverables. The Markdown files remain the editable BA sources.

## Subcommand: status

Inspect the selected project set and print a checklist with artifact name, exists or missing status, last-modified date, and any active delegated worker slices.

### Prerequisites

- Resolve the slug and dated set using the shared rules.
- If slug or dated set resolution is ambiguous, print the choices and stop until the user selects one.

### Output format

Print a checklist like this:

```text
Project: {slug}
Date set: {date}

- [x] intake-{slug}-{date}.md — 2026-03-26
- [x] intake-{slug}-{date}.html — 2026-03-26
- [x] plans/{date}-{slug}/plan.md — 2026-03-26
- [x] frd-{date}-{slug}.md — 2026-03-26
- [x] frd-{date}-{slug}.html — 2026-03-26
- [ ] user-stories-{date}-{slug}.md — missing
- [ ] user-stories-{date}-{slug}.html — missing
- [ ] srs-{date}-{slug}.md — missing
- [ ] wireframe-input-{date}-{slug}.md — missing
- [ ] wireframe-map-{date}-{slug}.md — missing
- [!] wireframes — skipped — 2026-03-26

Delegated slices:

- [~] requirements-engineer-group-b — running — last heartbeat 2026-03-26 15:42
- [!] ui-ux-designer-auth-flow — likely stalled — last heartbeat 2026-03-26 15:31 (>10m threshold)
```

Status rules:

- For regular artifacts, print `exists` or `missing` with the last-modified date when present.
- For wireframes, print the explicit wireframe state (`completed`, `skipped`, `not-applicable`, or `missing`) plus the marker date.
- When wireframes are `completed`, also list the detected input pack, wireframe map, `.pen` artifact paths, and export folders under `designs/{slug}/`.
- For delegated slices under `plans/{date}-{slug}/delegation/`, print:
  - `queued`, `running`, `completed`, `needs-repartition`, `blocked`, or `failed` directly from the tracker
  - `likely stalled` when the tracker says `running` or `queued` but the last heartbeat is older than the tracker threshold
  - the last heartbeat timestamp and latest milestone or blocker when present

## Deliverables

- Normalized intake form
- Intake HTML in the shared BA-kit document shell
- Gap analysis summary
- Scoped BA work plan
- FRD in Markdown and HTML
- User stories in Markdown and HTML
- SRS working fragments for grouped production
- Wireframe input pack for resumable Step 9 generation
- Unified SRS with use cases, wireframe-backed screen descriptions, NFRs, and test cases
- SRS HTML with embedded wireframes and rendered diagrams
- Pencil wireframes in `.pen` plus selected `.png` exports
- Wireframe map with persisted screen-to-frame linkback
- Wireframe-state marker for reruns, status, and packaging decisions
- Quality review summary
- Delegated run-status trackers for non-trivial sub-agent slices under `plans/{date}-{slug}/delegation/`

## Templates

- [intake-form-template.md](../../templates/intake-form-template.md)
- [frd-template.md](../../templates/frd-template.md)
- [user-story-template.md](../../templates/user-story-template.md)
- [srs-template.md](../../templates/srs-template.md)
- [wireframe-input-template.md](../../templates/wireframe-input-template.md)
- [wireframe-map-template.md](../../templates/wireframe-map-template.md)
- [delegation-status-template.md](../../templates/delegation-status-template.md)
- [sub-agent-handoff-template.md](../../templates/sub-agent-handoff-template.md)

## Agent Delegation

| Agent | Role |
| --- | --- |
| `requirements-engineer` | FRD, user stories, SRS groups, traceability |
| `ui-ux-designer` | Pencil wireframe generation |
| `ba-documentation-manager` | Quality review and packaging |
| `ba-researcher` | Domain research when needed |

## Quality Check

- Intake form has no blank required sections.
- Every gap is resolved or listed as an open question.
- FRD covers all features with priorities and acceptance criteria.
- User stories follow INVEST and have Given/When/Then acceptance criteria.
- SRS flow follows: FRD -> User Stories -> Use Case Specification -> Screen Contract Lite -> Wireframes -> Final Screen Descriptions -> Unified HTML.
- SRS covers functional requirements, use cases, screen contract lite, final screens, NFRs, and test cases.
- Every FR, UC, and SCR links to at least one user story.
- Screen Contract Lite exists for every primary screen before wireframes are generated.
- Screen field tables use the Display/Behaviour/Validation description format.
- Cross-artifact consistency is enforced across UC steps, screen fields, actions, and wireframe labels.
- Wireframes are generated from the use cases and Screen Contract Lite before final screen descriptions are expanded.
- Every UC actor action has a matching screen User Action.
- Every UC system response has a matching screen Behaviour Rule.
- Wireframes match their SRS screen descriptions field by field.
- Wireframes use Shadcn UI by default unless the user explicitly requests another system.
- SRS screens link to `.pen` artifacts and frame references unless wireframes were explicitly skipped or not applicable.
- Screen IDs stay aligned between SRS and Pencil frame names.
- Modal, drawer, and dialog overlays with flow impact are modeled as primary screens.
- Supporting state frames implied by screen behavior exist in `.pen` and are listed in the SRS screen inventory.
- Cross-references between FRD, user stories, and SRS are consistent.

## Token Efficiency

- Pass minimal context to downstream workers.
- Reuse the intake summary instead of the raw source once normalization is complete.
- Read templates once and pass only the relevant sections to each artifact owner.
- Split large use case or screen sets into smaller groups when needed.
- For wireframes, pass only the assigned screen slices rather than the full SRS.
- Prefer slim handoff packets: objective, write scope, trace IDs, and a few quoted excerpts. If you are tempted to attach full upstream documents, repartition first.
- Do not combine content generation, full cross-artifact audit, and packaging into the same delegated call when the artifact set is already large.
- If one delegated slice still feels too large after summarization, stop and split it again rather than hoping the worker keeps the whole context consistent.
