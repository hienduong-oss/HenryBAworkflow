# BA Presale Step — Status

Owner: `presale-lead`. Triggered by `/ba-presale status`. Read-only.

## Scope

Report the current state of the presale lifecycle for the resolved project. No mutation.

## Pre-run description block (MANDATORY)

Print this block in English (short, concise) before reading state:

```
────────────────────────────────────────
🔵 /ba-presale status — Inspection (read-only)
────────────────────────────────────────
Will:
  1. Resolve project workspace (auto from cwd)
  2. Read _state-cards/ + _changelog/ + _output/
  3. Print phase, artifact freshness, render status, suggested next command

No files will be modified.
────────────────────────────────────────
```

No confirmation required — proceed directly (read-only).

## Step 1 — Resolve project

Use `--slug` / `--date` if provided. Otherwise derive from cwd per `steps/bootstrap.md` Step 1 rules (`slug = basename(cwd)` kebab-case, `date = today`). If no matching `plans/{slug}-{date}/00_presale/` exists, try resolving to the most recent `plans/{slug}-*` directory for the same slug.

On no match → print:
```
⚠️  No presale workspace found at plans/{slug}-*/00_presale/.
   Run /ba-presale to bootstrap a new workspace.
```

## Step 2 — Inspect

Read:
- `plans/{slug}-{date}/00_presale/_state-cards/*` — latest of each phase
- `plans/{slug}-{date}/00_presale/_changelog/*` — count entries
- `plans/{slug}-{date}/00_presale/_output/*` — list rendered files + mtimes
- `plans/{slug}-{date}/00_presale/05-clarifications.md` — count Status=Answered/Draft/Skipped (if exists)
- `plans/{slug}-{date}/01_intake/intake.md` — exists? (indicates handoff complete)

## Step 3 — Print report

```
📊 BA Presale Status — {slug}-{date}

Workspace:        plans/{slug}-{date}/
Inputs:           {req}/{disc}/{tech}/{ref} files under 00_presale/00-inputs/

Phase artifacts:
  Domain Primer:    {✅ exists | ❌ missing}  (last edit: {date})
  Clarifications:   {✅ v{X.Y} — {Answered}/{N} answered | ❌ missing}
  WBS:              {✅ v{X.Y} — {N} rows | ❌ missing}
  Proposal:         {✅ v{X.Y} — §1–§11 {complete|partial} | ❌ missing}

Rendered outputs:
  xlsx:             {date} ({KB} KB) | never rendered
  docx:             {date} ({KB} KB) | never rendered

Sync & changelog:
  Last sync-check:  {status} ({date})
  Changelog entries: {N}

Handoff:
  intake.md:        {✅ generated | ❌ not yet}
  plan.md:          {✅ generated | ❌ not yet}

Current phase:    {phase from latest state card}
Next suggested:
  → {/ba-presale clarify | /ba-presale build | /ba-presale handoff | /ba-start backbone}
```

## Forbidden

- Mutating any file.
- Re-running checks. Just read state on disk.
- Triggering WebSearch or any network call.
