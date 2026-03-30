# BA-kit Getting Started

## Purpose

This guide shows how to install BA-kit and use it in Claude Code and Codex.

## 1. Clone The Repository

```bash
git clone https://github.com/anhdam2/bakit.git
cd bakit
```

## 2. Choose Your Runtime

BA-kit supports two usage modes:
- **Claude Code**: install BA-kit assets into `~/.claude`
- **Codex**: open the repo and use the root `AGENTS.md`

## 3. Install For Claude Code

Run:

```bash
./install.sh
```

What this installs:
- skills to `~/.claude/skills/`
- agents to `~/.claude/agents/`
- rules to `~/.claude/rules/ba-kit/`
- templates to `~/.claude/templates/`
- the shared update command to `~/.local/bin/ba-kit`

Then restart Claude Code if it is already open.

To update later, run one command:

```bash
ba-kit update
```

This checks the registered BA-kit source repo, blocks when the repo has local changes or unfinished merge/rebase state, runs `git pull --ff-only`, then reruns the installers for any previously installed runtimes.

## 4. Use BA-kit In Claude Code

The single entry point is still `/ba-start`, but it now supports resumable subcommands.

Full workflow:

```text
/ba-start
```

Step-level reruns:

```text
/ba-start intake docs/raw/warehouse-rfp.pdf
/ba-start frd --slug warehouse-rfp
/ba-start stories --slug warehouse-rfp
/ba-start srs --slug warehouse-rfp
/ba-start wireframes --slug warehouse-rfp
/ba-start package --slug warehouse-rfp
/ba-start status --slug warehouse-rfp
```

Default `/ba-start` handles the full BA lifecycle:
1. Parse raw input into an intake form
2. Gap analysis and clarifying questions
3. Work plan generation
4. FRD production
5. User story generation
6. SRS production
7. Wireframe generation from the use cases and screen contract
8. Final screen description production
9. HTML packaging for intake, FRD, user stories, and unified SRS deliverables

### Claude Example

```text
/ba-start
Here is our requirements doc: docs/raw/warehouse-rfp.pdf
```

When prompted, provide the file path or paste your requirements text. The skill will:
1. Parse and normalize the input into a structured intake form
2. Identify gaps (missing stakeholders, unclear scope, no success criteria)
3. Ask 3-8 clarifying questions
4. Generate a scoped work plan
5. Produce FRD, user stories, use cases, Screen Contract Lite, wireframes, final screen descriptions, and browser-editable HTML output

For rerun commands:
- pass `--slug <slug>` when more than one project exists
- if one slug has multiple dated artifact sets, BA-kit should stop and ask which set to use
- use `/ba-start status --slug <slug>` to inspect completion before rerunning a downstream step

## 5. Use BA-kit In Codex

Codex does not need `install.sh`.

Instead:
1. Open this repository in Codex
2. Make sure the root `AGENTS.md` is visible in the repo
3. Tell Codex to use `skills/ba-start/SKILL.md` as the playbook
4. Point Codex to the correct template under `templates/`
5. If you have the Codex-converted bundle, run `bash scripts/install-codex-ba-kit.sh` once to copy the skill and agents into `~/.codex` and register Codex agents in `~/.codex/config.toml`
6. If you use the installer, make sure `node` is available because the registration step runs on Node.js
7. The installer also records the source repo for the shared update command `ba-kit update`

### Codex Example

```text
Use AGENTS.md and skills/ba-start/SKILL.md.
Parse the requirements in docs/raw/warehouse-rfp.pdf.
Include use cases, Screen Contract Lite, final screen descriptions, linked requirements, test cases, and wireframes.
Reference Pencil artifacts under designs/customer-portal/ and map each SRS screen to its target frame.
```

If the Codex conversion is installed, you can point Codex directly at the bundled skill:

```text
Use ~/.codex/skills/ba-start/SKILL.md and the registered BA agents under ~/.codex/agents.
Parse the requirements in docs/raw/warehouse-rfp.pdf.
Produce an intake form, FRD, user stories, use case specifications, Screen Contract Lite, wireframes, final screen descriptions, and a browser-editable HTML output.
```

For partial reruns in Codex, be explicit about the target slug and dated set when ambiguity exists. Example:

```text
Use AGENTS.md and skills/ba-start/SKILL.md.
Run only the wireframe rerun path for slug warehouse-rfp.
If multiple dated sets exist for that slug, stop and ask me which date to use.
Use the persisted `wireframe-input-{date}-{slug}.md` when it exists, or rebuild it from exact fallback sources before generating wireframes.
Then report `/ba-start status` semantics with artifact dates, wireframe state, and any wireframe input/map artifacts.
```

See [codex-setup.md](./codex-setup.md) for more prompt patterns.

Runtime defaults for both Claude Code and Codex:
- BA deliverables are written in Vietnamese by default unless the user explicitly requests English
- the dated artifact-set token is `YYMMDD-HHmm` across report filenames and `plans/{date}-{slug}/plan.md`
- Shadcn UI is the default wireframe design system unless explicitly overridden

`plans/` is a local runtime workspace. BA-kit writes generated plans and report artifacts there during an engagement, but those files are not meant to stay version-controlled in the toolkit repository.

## 5.1 Update BA-kit In One Command

Once you have installed BA-kit for Claude Code, Codex, or both, update it with:

```bash
ba-kit update
```

Or from inside the agents:

```text
/ba-kit-update
```

Expected behavior:
- read the registered source repo from the local install manifests
- fail fast if the repo has local edits, conflict state, or multiple conflicting source repos
- run `git pull --ff-only`
- rerun `install.sh` and/or `scripts/install-codex-ba-kit.sh` for the runtimes already installed from that repo

## 6. Add Pencil Wireframes For SRS Work

Use Pencil only for wireframes in BA-kit.

Store `.pen` files under:

```text
designs/[initiative-slug]/
```

Example:

```text
designs/customer-portal/auth-flow.pen
designs/customer-portal/dashboard-core.pen
designs/customer-portal/exports/auth-flow/SCR-01-login.png
designs/customer-portal/exports/dashboard-core/SCR-02-dashboard.png
```

Rules:
- a single `.pen` file may contain multiple frames
- keep screen IDs aligned between the SRS and Pencil frame names
- link each SRS screen to both the `.pen` artifact and the specific frame it uses
- use the `.pen` file as the wireframe source of truth
- use Shadcn UI as the default design system baseline unless you explicitly request another system
- keep the SRS focused on behavior, validation, states, navigation, and traceability
- treat the packaged HTML suite as the editable stakeholder copy: update text, swap images, and add or remove blocks directly in the browser without editing the source HTML

## 7. Deliverables

A full `/ba-start` engagement produces:

| Deliverable | Template | Location |
| --- | --- | --- |
| Intake form | `intake-form-template.md` | `plans/reports/intake-{slug}-{date}.md` |
| Intake HTML | `scripts/md-to-html.py` | `plans/reports/intake-{slug}-{date}.html` in the shared BA-kit document shell |
| FRD | `frd-template.md` | `plans/reports/frd-{date}-{slug}.md` |
| FRD HTML | `scripts/md-to-html.py` | `plans/reports/frd-{date}-{slug}.html` with rendered Mermaid diagrams |
| SRS | `srs-template.md` | `plans/reports/srs-{date}-{slug}.md` |
| User stories | `user-story-template.md` | `plans/reports/user-stories-{date}-{slug}.md` |
| User stories HTML | `scripts/md-to-html.py` | `plans/reports/user-stories-{date}-{slug}.html` in the shared BA-kit document shell |
| Wireframe input pack | `wireframe-input-template.md` | `plans/reports/wireframe-input-{date}-{slug}.md` |
| Wireframes | Pencil MCP | `designs/{slug}/{artifact-name}.pen` plus `designs/{slug}/exports/{artifact-name}/SCR-xx-{name}.png` |
| Wireframe map | `wireframe-map-template.md` | `plans/reports/wireframe-map-{date}-{slug}.md` |
| Wireframe state | BA-kit routing metadata | `plans/reports/wireframe-state-{date}-{slug}.md` |
| SRS HTML | `scripts/md-to-html.py` | `plans/reports/srs-{date}-{slug}.html` as the primary browser-editable stakeholder copy |

If you need a clean read-only stakeholder handoff, generate HTML with:

```bash
python scripts/md-to-html.py --no-editor plans/reports/srs-{date}-{slug}.md
```

## 8. Know Where To Look

- Runtime instructions for Codex: [AGENTS.md](../AGENTS.md)
- Claude-oriented project instructions: [CLAUDE.md](../CLAUDE.md)
- Codex-specific setup notes: [codex-setup.md](./codex-setup.md)
- Skill catalog: [skill-catalog.md](./skill-catalog.md)
- Methodology guide: [ba-methodology-guide.md](./ba-methodology-guide.md)
- Pencil naming convention: [designs/README.md](../designs/README.md)

## 9. Practical Tips

- Start with `/ba-start` and let the skill guide you through the lifecycle
- Use subcommands when a later step must be rerun without redoing intake and FRD work
- Always provide raw input (file or text) when starting an engagement
- For UI scope, provide the `.pen` artifact path and target frames explicitly, or let the skill generate and map them
- Use `--slug` for rerun commands whenever more than one project may exist
- Treat `/ba-start status` as the checkpoint view: it prints artifact dates plus wireframe state (`completed`, `skipped`, `not-applicable`, `missing`) and any persisted wireframe input/map artifacts
- Ask for assumptions and open questions before asking for finalization
- Use Mermaid diagrams for process or data views
