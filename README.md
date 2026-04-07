# BA-kit

BA-kit is a business analysis toolkit for agentic coding environments. It packages a two-layer command model (freeform router + lifecycle engine), focused agent roles, workflow rules, shared core references, and reusable templates so discovery, requirements, and handoff work follow a consistent solo-IT-BA-friendly operating model in Claude Code and Codex.

## What It Includes

- 6 BA skills: `ba-do` (freeform router), `ba-start` (lifecycle engine), `ba-impact` (change triage), `ba-next` (next-step advisor), `ba-kit-update`, `ba-notion`
- 4 agent roles for structured delegation
- 2 workflow and quality rule files
- shared core workflows and artifact contract reference (`core/`)
- reusable document and wireframe workflow templates, including a requirements backbone
- Project instructions and configuration for BA engagements

Start here for practical setup and usage: [docs/getting-started.md](./docs/getting-started.md)

## How A BA Uses BA-kit

BA-kit is meant to be used as a BA workstation, not just a template repo.

A solo BA typically uses it like this:

1. Start with raw input: BRD draft, RFP, meeting notes, process notes, screenshots, or pasted requirements.
2. Run `/ba-do <description>` for freeform requests — it routes to the right BA-kit command automatically.
3. Or run `/ba-start` directly when the lifecycle step is already known.
4. Lock scope and build the `backbone` as the single source of truth for the engagement.
5. Emit only the artifacts the engagement actually needs:
   - `lite`: intake + backbone + stories
   - `hybrid` default: backbone + stories + selective FRD/SRS + critical wireframes
   - `formal`: full FRD + SRS + wireframes + packaged handoff
6. When a requirement changes mid-engagement, run `/ba-impact` to triage before editing artifacts.
7. Use `/ba-next` to see the recommended next command based on current artifact state.
8. Use rerun commands like `frd`, `stories`, `srs`, `wireframes`, and `package` only when that slice needs to be refreshed.
9. Use `status` to see what exists, what is missing, and whether any delegated slice is stalled.

The intended working style is:

- write once in the backbone, then derive downstream artifacts
- avoid producing full SRS and full wireframes unless the project really needs them
- keep outputs traceable enough for product, dev, QA, vendor, or stakeholder handoff

### Typical BA Scenarios

| Scenario | Recommended Mode | Typical Output |
| --- | --- | --- |
| Discovery / backlog shaping | `lite` | intake, backbone, user stories |
| Solo IT BA on product or internal system | `hybrid` | backbone, stories, targeted FRD/SRS, critical wireframes |
| Vendor handoff / regulated change / formal approval | `formal` | full FRD, full SRS, wireframes, FRD/SRS HTML |

### Core Commands For A BA

```text
/ba-do <description>
/ba-start
/ba-start intake docs/raw/warehouse-rfp.pdf
/ba-impact --slug warehouse-rfp
/ba-next --slug warehouse-rfp
/ba-start backbone --slug warehouse-rfp
/ba-start stories --slug warehouse-rfp
/ba-start srs --slug warehouse-rfp
/ba-start wireframes --slug warehouse-rfp
/ba-start package --slug warehouse-rfp
/ba-start status --slug warehouse-rfp
```

### What You Get Back

- normalized intake
- scoped work plan
- requirements backbone
- FRD and user stories when needed
- selective or full SRS depending on mode
- wireframes for critical or approved screens
- FRD/SRS HTML deliverables for stakeholder review

## Dependencies

Use this as the practical dependency checklist.

| Dependency | Needed For | Required |
| --- | --- | --- |
| Claude Code CLI | Running BA-kit as an installed Claude workflow | Core for Claude runtime |
| Codex with repo-level `AGENTS.md` support | Running BA-kit directly inside Codex | Core for Codex runtime |
| Bash-compatible shell | Running `install.sh`, `ba-kit update`, and helper scripts | Yes |
| Python 3 | HTML packaging via `scripts/md-to-html.py` | Required for packaging |
| Node.js | Running `scripts/install-codex-ba-kit.sh` and Codex agent registration | Required only for Codex converted install |
| Pencil / Pencil MCP runtime | Generating `.pen` wireframes and PNG exports in the `wireframes` step | Required only for Pencil wireframes |
| Google Stitch MCP runtime | Generating wireframes via Google Stitch in the `wireframes` step | Required only for Stitch wireframes |
| Notion MCP runtime | Publishing BA artifacts into Notion via `/ba-notion` | Required only for Notion publishing |

Notes:

- If you do not need wireframes, BA-kit can still run intake, backbone, stories, FRD, and non-wireframe SRS work without a wireframe runtime.
- If your BA workflow includes UI-backed screens and you want BA-kit to generate wireframes, your agent runtime must expose a supported wireframe tool (Pencil MCP or Google Stitch MCP).
- BA-kit detects available wireframe tooling at runtime and adapts its generation strategy accordingly.
- If you skip packaging, Python 3 is not required for the analysis steps themselves.
- If you do not publish into Notion, a Notion MCP runtime is not required.

## Prerequisites

- A supported runtime:
  - Claude Code CLI with access to `~/.claude/`
  - or Codex with repo-level `AGENTS.md` support
- Bash-compatible shell for running installers and helper commands
- Python 3 if you want HTML packaging
- Node.js if you want to run `scripts/install-codex-ba-kit.sh`
- Pencil / Pencil MCP or Google Stitch MCP if you want generated wireframes

## Installation

### Claude Code Installation

1. Clone or copy this repository locally.
2. Run:

```bash
./install.sh
```

3. Restart Claude Code if it is already running.

The installer also installs a shared update command:

```bash
ba-kit doctor
ba-kit update
ba-kit status --slug warehouse-rfp
```

It checks the registered BA-kit source repo for dirty state or unfinished merge/rebase work, runs `git pull --ff-only`, then reinstalls Claude and Codex assets that were previously installed from that repo.
`ba-kit doctor` and `ba-kit status` also surface update availability when the registered upstream has newer commits.

The installer copies:
- the BA skill directories under `skills/` to `~/.claude/skills/`
- `agents/` to `~/.claude/agents/`
- `rules/` to `~/.claude/rules/ba-kit/`
- `templates/` to `~/.claude/templates/`
- `core/` workflows and references to `~/.claude/ba-kit/`

## Use With Codex

BA-kit supports Codex through the root [AGENTS.md](./AGENTS.md) file and repo-local playbooks:
- Codex should read [AGENTS.md](./AGENTS.md) for persistent repository instructions
- `skills/` acts as BA reference playbooks
- `rules/` and `templates/` provide workflow and artifact structure
- `designs/` stores wireframe artifacts for SRS screen wireframes

Codex does not require `./install.sh` or installation into `~/.claude`. Open the repository with `AGENTS.md` present, then explicitly direct Codex to use the relevant BA playbook from `skills/`. The root `AGENTS.md` now carries the minimum non-negotiable BA defaults, but `skills/ba-start/SKILL.md` is still the required workflow source for non-trivial BA tasks.

If you are using the Codex-converted bundle, install it into the local Codex runtime with:

```bash
bash scripts/install-codex-ba-kit.sh
```

That script copies the converted assets from `codex/skills/**` and `codex/agents/**` into `~/.codex/skills` and `~/.codex/agents`, then appends any missing agent registrations into `~/.codex/config.toml` without duplicating existing entries.

The Codex installer also refreshes the shared `ba-kit` update command and records the source repo so future updates can be done with:

```bash
ba-kit doctor
ba-kit update
```

See [docs/codex-setup.md](./docs/codex-setup.md) for prompt patterns and setup guidance.

Core defaults across Claude Code and Codex:
- BA deliverables are written in Vietnamese by default unless the user explicitly requests English.
- The dated artifact-set token uses `YYMMDD-HHmm` consistently across `plans/reports/final/*`, `plans/reports/drafts/*`, and `plans/{date}-{slug}/plan.md`.
- The default engagement mode is `hybrid`: build the backbone first, then emit only the downstream artifacts the engagement actually needs.
- When UI scope exists, the project `DESIGN.md` controls the design system baseline; Shadcn UI is the default when no override is specified.

`plans/` is a local BA workspace, not shipped example content. Keep generated `plans/reports/final/*`, `plans/reports/drafts/*`, and `plans/{date}-{slug}/plan.md` local to your engagement and out of version control.

## Workflow And Commands

Freeform entry:

```text
/ba-do <description>
```

Full workflow:

```text
/ba-start
```

Change triage and next-step advisor:

```text
/ba-impact --slug warehouse-rfp
/ba-next --slug warehouse-rfp
```

Resumable subcommands:

```text
/ba-start intake docs/raw/warehouse-rfp.pdf
/ba-start impact --slug warehouse-rfp
/ba-start backbone --slug warehouse-rfp
/ba-start frd --slug warehouse-rfp
/ba-start stories --slug warehouse-rfp
/ba-start srs --slug warehouse-rfp
/ba-start wireframes --slug warehouse-rfp
/ba-start package --slug warehouse-rfp
/ba-start status --slug warehouse-rfp
```

Default `/ba-start` still runs the full lifecycle:
1. Parsing raw input into a structured intake form
2. Gap analysis and clarifying questions
3. Scope lock and mode selection
4. Requirements backbone production
5. Gated FRD and user story generation
6. Selective SRS production
7. Project `DESIGN.md` approval and wireframe generation when justified
8. Final screen description production
9. Unified browser-editable HTML packaging for the emitted artifacts

Use `/ba-impact` at any point to triage a requirement change before mutating artifacts. Use `/ba-next` to see the recommended next command.

For rerun commands, resolution order is:
1. Explicit `--slug <slug>`
2. A single detected project across `plans/reports/final/` and `plans/reports/drafts/`
3. Otherwise stop and ask the user to choose

If one slug has multiple dated artifact sets, `/ba-start` should stop and ask which dated set to use instead of silently taking the latest one.

## Skills

| Skill | Purpose |
| --- | --- |
| `ba-do` | Freeform natural-language router — dispatches to the right BA-kit command automatically |
| `ba-start` | Lifecycle engine with full workflow plus `intake`, `impact`, `backbone`, `frd`, `stories`, `srs`, `wireframes`, `package`, and `status` subcommands |
| `ba-impact` | Change-impact triage — analyzes requirement changes without mutating artifacts and recommends next commands |
| `ba-next` | Next-step advisor — inspects the current artifact set and recommends the next BA command |
| `ba-kit-update` | Maintenance entry point that runs `ba-kit update` to pull and reinstall BA-kit |
| `ba-notion` | Maintenance entry point that publishes BA markdown artifacts into Notion via MCP with create, append, overwrite, or fill-gaps behavior |

## Agent Roles

| Agent | Focus |
| --- | --- |
| `requirements-engineer` | Requirements elicitation, structuring, validation |
| `ui-ux-designer` | Wireframe generation from SRS screens |
| `ba-documentation-manager` | Deliverable quality, consistency, and packaging |
| `ba-researcher` | Domain, market, and solution research |

## Template Library

Templates live in `./templates/` and cover:
- Requirements backbone
- SRS (software requirements specification)
- FRD (functional requirements document)
- User stories
- Intake form
- Wireframe input packs for resumable Step 9 generation
- Wireframe maps for persisted SRS linkback

Wireframe artifacts for SRS screen sections live under `./designs/`. See [designs/README.md](./designs/README.md) for the naming convention.

For UI-backed work, the project `DESIGN.md` (`designs/{slug}/DESIGN.md`) controls the design system baseline. Shadcn UI is the default when no override is specified.

BA-kit packages FRD and SRS into one shared HTML shell with consistent metadata, visual chrome, and in-browser editing controls. SRS HTML remains the primary stakeholder handoff, and FRD HTML provides the aligned functional review copy for the same engagement.

Wireframe images in packaged HTML now default to a fit-to-document viewport instead of rendering at full page width, and clicking or double-clicking an image opens a larger preview so tall screens remain readable. Mermaid diagrams are bootstrapped explicitly after `DOMContentLoaded` so packaged documents render diagrams more reliably in browser review copies.

`/ba-start status` reports regular artifacts as exists or missing with last-modified dates, including the persisted backbone. Wireframes use explicit states: `completed`, `skipped`, `not-applicable`, or `missing`. Non-trivial delegated slices should also surface from trackers under `plans/{date}-{slug}/delegation/`, including likely stalled runs when heartbeats go stale.

## Configuration

BA-kit uses [`.ck.json`](./.ck.json) to define project paths, plan naming, methodology defaults, and quality assertions. The default methodology is `hybrid`.

## Example Scenarios

### New Product Discovery

Use `/ba-start` with a raw requirements document to produce an intake form, a requirements backbone, user stories with AC, selective FRD/SRS slices, and wireframes only where they help review or handoff. Use `/ba-start status --slug <slug>` to inspect progress after an interrupted session. Or simply use `/ba-do` with a natural-language description and let BA-kit route to the right command.

### ERP Process Improvement

Use `/ba-start` with process descriptions as input. The skill produces FRD with workflows, user stories for the delivery team, and SRS with technical specs. When a process rule changes mid-engagement, use `/ba-impact` to triage before editing artifacts.

### Regulated Workflow Change

Use `/ba-start` with regulatory context. The SRS captures compliance constraints, the FRD covers business rules, and user stories include acceptance criteria tied to regulations. Use `/ba-next` to see the recommended next step at any point.

## Contributing

Keep additions aligned with BA-kit principles:
- practical over theoretical
- reusable templates over ad hoc prose
- traceability over ambiguity
- Mermaid for diagrams

When changing skills, also update templates, core references, or rules if the workflow contract changes. See [CONTRIBUTING.md](./CONTRIBUTING.md) for contribution expectations and validation steps.

## Compatibility And Disclaimer

BA-kit is an independent toolkit for use with Claude Code and Codex.

Claude, Claude Code, OpenAI, and Codex are trademarks or product names of their respective owners. Their use in this repository describes compatibility only and does not imply affiliation, endorsement, or sponsorship.

BA-kit provides workflow guidance, templates, and automation helpers only. It does not constitute legal, regulatory, compliance, or other professional advice. Users remain responsible for validating generated outputs before business, technical, contractual, or governance use.

## License

This project is licensed under the [MIT License](./LICENSE).
