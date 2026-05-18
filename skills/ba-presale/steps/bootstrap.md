# BA Presale Step — Bootstrap

Phase 0 of the presale lifecycle. Owner: `presale-lead` (Sonnet). Runs automatically when user invokes bare `/ba-presale`, then auto-chains into `steps/domain-study.md`.

## Checkpoint

Write `plans/{slug}-{date}/00_presale/_checkpoint.md` as the **first action** (create `00_presale/` dir if needed):
```
step: bootstrap
status: running
command: /ba-presale
started: <ISO timestamp>
updated: <ISO timestamp>
```
On complete, update `status: completed` and `updated`.

**Orchestration note:** Bootstrap is 100% mechanical (file ops, classification by filename pattern). The auto-chain to domain-study is deterministic — no branching, no evaluation needed. This entire step runs at Sonnet cost level per `presale.models.bootstrap`.

This step requires:
- `core/contract.yaml` (`paths.presale_*`)
- `rules/ba-presale-standards.md` §2

## Scope

Auto-derive workspace slug + date from the current working directory, classify existing files into `00_inputs/` (shared raw-input store at project root), and create the `plans/{slug}-{date}/00_presale/` skeleton. **Never ask the user to organize files. Never ask for slug/date unless cwd is clearly not a project folder.**

## Pre-run description block (MANDATORY)

Before touching the filesystem, print this block in English (short, concise):

```
────────────────────────────────────────
🔵 /ba-presale — Bootstrap + Domain Research
────────────────────────────────────────
Phase 0+1 — Workspace setup and domain synthesis.

Will:
  1. Derive slug = basename(cwd), date = today
  2. Create 00_presale/ skeleton inside existing project folder
  3. Classify existing files → 00_inputs/{requirements,discussions,technical,references}
  4. Read all inputs + run thorough WebSearch (always, every project)
  5. Synthesize Domain Primer (Vietnamese, 8 sections)

Output:   plans/{slug}-{date}/00_presale/00-domain-primer.md
Next gate: USER review of research findings

Proceed? (reply 'ok' to start, or type a different command)
────────────────────────────────────────
```

Wait for `ok` before continuing. Any other reply → cancel and respond accordingly.

## Step 1 — Auto-derive workspace

Rules (in order):
1. If `--slug` and `--date` explicitly provided → use them.
2. Else derive from cwd:
   - `slug` = `basename(cwd)` converted to kebab-case: lowercase, spaces and underscores → `-`, strip non-`[a-z0-9-]`, collapse repeated `-`, trim leading/trailing `-`.
   - `date` = today in `YYYY-MM-DD` format.
3. Validation:
   - cwd MUST NOT be `/`, `$HOME`, `/tmp`, or the bakit install directory — in those cases STOP and ask user for explicit workspace path or project folder.
   - cwd MUST NOT be inside `bakit/` itself.
   - derived slug MUST be non-empty after kebab-case normalization.
4. Print 1-line confirmation in English:
   ```
   Bootstrapping presale at {cwd} (slug={slug}, date={date})
   ```

## Step 2 — Create skeleton

The project folder (`plans/{slug}-{date}/`) is assumed to already exist (user created it or it was set up externally). Bootstrap creates the shared raw-input store at project root AND the presale sub-structure.

Create (idempotent — skip if exists):
- `plans/{slug}-{date}/00_inputs/{requirements,discussions,technical,references}/` (shared across presale + ba-start)
- `plans/{slug}-{date}/00_presale/`
- `plans/{slug}-{date}/00_presale/_state-cards/`
- `plans/{slug}-{date}/00_presale/_changelog/`
- `plans/{slug}-{date}/00_presale/_output/`

Do NOT create `plans/{slug}-{date}/` itself or `01_intake/` — those are created by their owning phases (handoff creates `01_intake/`).

All presale artifact paths: use `paths.presale_*` from `core/contract.yaml` — do NOT hardcode. Raw input path: use `paths.raw_inputs`.

## Step 3 — Re-run detection

If `plans/{slug}-{date}/00_presale/00-domain-primer.md` already exists, STOP and ask:

```
⚠️ Existing presale artifacts detected at plans/{slug}-{date}/00_presale/.

  - Domain Primer: exists
  - Clarifications: {exists | missing}
  - WBS/Proposal: {exists | missing}

How to proceed?
  (a) continue — resume from current state (default)
  (b) reset   — archive existing to _changelog/archive-{timestamp}/, start fresh
  (c) new     — bump date suffix to create plans/{slug}-{date}-v2/
```

Only proceed after user choice.

## Step 4 — Scan and classify

Walk cwd top-level and one level deep (exclude `plans/`, `.git/`, `.claude/`, `node_modules/`, `venv/`, hidden dirs). Classify each file:

| Class | Filename patterns | Target |
|-------|------------------|--------|
| requirements | rfp, scope, brief, business, requirement, spec, sow | `00_inputs/requirements/` |
| discussions | meeting, note, email, chat, call, transcript, summary | `00_inputs/discussions/` |
| technical | api, schema, payload, erd, sequence, swagger, openapi, postman, sample | `00_inputs/technical/` |
| references | anything else useful (industry, competitor, regulation, standard) | `00_inputs/references/` |

Rules:
- Filename keywords first. When ambiguous, read first ~500 chars to infer class.
- Still unsure → `references/`.
- **Move** (not copy) files living in cwd root only.
- **Skip** files already under `00_inputs/` (idempotent).
- **Never modify** file contents.

## Step 5 — Empty workspace fallback

If cwd contains zero classifiable files:
- Capture the user's originating prompt (or last user message) into `plans/{slug}-{date}/00_inputs/requirements/_initial-prompt.md`.
- Proceed to Step 6.

## Step 6 — State card

Write `plans/{slug}-{date}/00_presale/_state-cards/00-bootstrap.md` (≤300 tokens, Vietnamese):
- slug, date, cwd
- file counts per class
- anomalies / unclassified files
- next gate: domain-study

## Step 7 — Auto-chain to Domain Study `[MECHANICAL]`

No user gate here. This is deterministic — bootstrap always chains to domain-study. No LLM evaluation needed for the routing decision. Read and execute `steps/domain-study.md` immediately.

## Forbidden

- Asking user to organize files.
- Asking user for slug/date when cwd is a valid project folder.
- Modifying file contents.
- Re-classifying files already in `00_inputs/` (idempotent).
- Creating `presale/{slug}-{date}/...` at repo root (legacy layout — removed).

## Presale Context-Loss Recovery

When context is lost mid-presale:

**Step 1 — Check checkpoint first:**
Read `plans/{slug}-{date}/00_presale/_checkpoint.md`.
- If `status: running`: a step was interrupted. Report to user with resume options (same format as `ba-next` check_checkpoint step). Wait for user choice before proceeding.
- If `status: completed` or file missing: proceed to Step 2.

**Step 2 — Read state cards:**
Read `plans/{slug}-{date}/00_presale/_state-cards/` — each card is ≤300 tokens and records phase id, output paths, key decisions, open issues, and next gate.

1. Identify the highest-numbered card to determine the last completed phase.
2. Resume from the next gate indicated in that card.
3. Only read full presale artifacts (`00-domain-primer.md`, `05-clarifications.md`, `10-wbs-content.md`, `20-proposal-content.md`) when the state card references a specific open issue that requires artifact context.
4. Do not re-run completed phases. State cards are authoritative for phase completion status.
