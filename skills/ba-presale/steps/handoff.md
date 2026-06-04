# BA Presale Step — Handoff

Phase 4 of the presale lifecycle. Owner: `presale-lead` (inline, never delegate). Triggered by `/ba-presale handoff`.

## Checkpoint

Write `paths.presale_checkpoint` as the **first action**:
```
step: handoff
status: running
command: /ba-presale handoff
started: <ISO timestamp>
updated: <ISO timestamp>
progress: ""
last_write: ""
resume_hint: ""
```
After composing `intake.md` and after continuity check, update `progress` and `last_write`.
On complete, update `status: completed` and `updated`.
**Orchestration note:** Handoff is ~80% mechanical (file ops, template-fill, string matching). Only intake.md composition requires LLM synthesis. Use Bash for file operations, Sonnet-level effort for composition, and reserve Opus only if conflict resolution is needed during continuity check. See `presale.orchestration_mode` in `contract.yaml`.

This step requires:
- `paths.presale_domain_primer`
- `paths.presale_clarifications`
- `paths.presale_wbs` (+ `.csv`)
- `paths.presale_proposal`
- `paths.presale_wbs_xlsx`
- `paths.presale_proposal_docx`
- `rules/ba-presale-standards.md` §8

## Scope

Bridge presale to `/ba-start`. Compose `01_intake/intake.md` and `01_intake/plan.md` directly from presale artifacts — do NOT re-ask the user for any scope input already captured in Domain Primer / Clarifications / WBS / Proposal. Mirror presale analysis artifacts (not raw inputs — those live at `00_inputs/` shared by both flows) into `_sources/`. Run continuity check. Block on any failure.

## Pre-run description block (MANDATORY)

Before touching the filesystem, print this block in English (short, concise):

```
────────────────────────────────────────
🔵 /ba-presale handoff — Bridge to /ba-start
────────────────────────────────────────
Phase 4 — Compose intake.md from presale artifacts (no re-ask).

Will:
  1. Pre-flight: verify Domain Primer + Clarifications + WBS + Proposal exist
  2. Create plans/{slug}-{date}/01_intake/ + _sources/ mirror (presale analysis only, not raw inputs)
  3. Compose intake.md (§1 Goals → §7 Reference Bundle) from existing sources
  4. Compose plan.md (mode selection, next /ba-start commands)
  5. Run continuity check (WBS phases, Proposal commitments, clarifications)
  6. Block on any failure with explicit fix-list

Output:
  plans/{slug}-{date}/01_intake/intake.md
  plans/{slug}-{date}/01_intake/plan.md
  plans/{slug}-{date}/01_intake/handoff-manifest.md
  plans/{slug}-{date}/01_intake/_sources/  (mirror of presale analysis artifacts — raw inputs stay at 00_inputs/)

Next: /ba-start backbone

Proceed? (reply 'ok' to start, or type a different command)
────────────────────────────────────────
```

Wait for `ok` before continuing.

## Step 1 — Pre-flight `[MECHANICAL]`

Boolean file-existence checks. No LLM judgment needed.

Verify all of the following exist:
- `paths.presale_domain_primer`
- `paths.presale_clarifications` (with `Status=Answered` rows — no minimum threshold)
- `paths.presale_wbs` + `.csv`
- `paths.presale_proposal`
- `paths.presale_wbs_xlsx`
- `paths.presale_proposal_docx`

On missing file → block with explicit list and the command that produces it (e.g., `Run /ba-presale build to produce WBS + Proposal`).

## Step 2 — Create handoff structure `[MECHANICAL — Bash]`

Pure file operations. Use Bash `mkdir -p` directly.

Create (idempotent):
- `plans/{slug}-{date}/01_intake/`
- `plans/{slug}-{date}/01_intake/_sources/`

## Step 3 — Mirror sources `[MECHANICAL — Bash]`

Pure file operations. Use Bash `cp -r` or `ln -s`. No LLM needed.

Symlink (copy if symlinks unavailable) presale analysis artifacts into `_sources/`. Raw inputs are NOT mirrored — they live at `00_inputs/` (shared across both flows):

| Source | Mirrored as |
|--------|-------------|
| `00_presale/00-domain-primer.md` | `_sources/00-domain-primer.md` |
| `00_presale/05-clarifications.md` | `_sources/05-clarifications.md` |
| `00_presale/10-wbs-content.md` | `_sources/10-wbs-content.md` |
| `00_presale/20-proposal-content.md` | `_sources/20-proposal-content.md` |

## Step 4 — Compose intake.md `[JUDGMENT — Sonnet-level synthesis]`

This is the one step that needs LLM synthesis: extracting, rephrasing, and structuring facts from multiple source artifacts into a coherent intake document. However, it does NOT need Opus — the sources are already validated and locked. Sonnet-level composition is sufficient. The lead runs this inline but should treat it as template-fill + light synthesis, not deep analysis.

Write `plans/{slug}-{date}/01_intake/intake.md` directly from presale artifacts. Vietnamese (matches `/ba-start` defaults). Every fact carries `[src:...]` ref back to the source-of-truth file.

**Inline manifest generation:** As you write each section of `intake.md`, simultaneously append the corresponding fact→source rows to `handoff-manifest.md`. This avoids a second pass over the document. See Step 6 for the manifest header and bundle versions table (written after intake.md is complete).

Structure:

```markdown
# Intake — {client_name} / {project_name}

> Generated from /ba-presale handoff. All facts trace to source via [src:...] refs.
> Presale bundle date: {YYYY-MM-DD} | Handoff version: v1.0

## 1. Business Goals
<extract from Proposal §1.1 Business Context + §1.4 Objectives + 00_inputs/requirements>
- Goal: ...  [src:proposal:§1.1] [src:client:RFP§1]

## 2. Stakeholders
<extract from 00_inputs/discussions + Proposal §9.2 Team Structure + answered
Clarifications Q{n} in Stakeholders category>
| Role | Side | Influence |
|------|------|-----------|
| ... | client | ... [src:clarify:Q1] |

## 3. Scope
### 3.1 In-scope
<extract from WBS phases / work packages + Proposal §7.1>
- {Phase / WP}  [src:wbs:1.1] [src:proposal:§7.1]

### 3.2 Out-of-scope
<extract from WBS §5 Exclusions + Proposal §7.2>
- {Item}  [src:wbs:§5] [src:proposal:§7.2]

## 4. Constraints & Assumptions
<extract from Proposal §7.3 + WBS §4 + Domain Primer §5 + Clarifications assumptions block>
- Constraint: ...  [src:proposal:§7.3]
- Assumption A1: ...  [src:assumption:A1] [src:clarify:Q8]

## 5. Clarified Points (from /ba-presale clarify)
<every Clarifications row with Status=Answered>
- Q1 (Stakeholders): {question} → {answer}  [src:clarify:Q1]
- Q2 (Scope):        {question} → {answer}  [src:clarify:Q2]
- ...

## 6. Remaining Open Questions (if any)
<every Clarifications row still Draft / Skipped at handoff>
<if none, state "All clarifications addressed before handoff.">
- Q{n} (Category, Skipped): ...  [src:clarify:Q{n}]

## 7. Risks
<extract from Domain Primer §6 + Proposal §7>
| ID | Risk | Severity | Mitigation |
|----|------|----------|------------|
| R1 | ... | H | ... [src:domain:§6.R1] |

## 8. Reference Bundle
- Client raw:         ../00_inputs/  (shared across presale + ba-start)
- Domain context:     _sources/00-domain-primer.md
- Clarifications:     _sources/05-clarifications.md
- Scope authority:    _sources/10-wbs-content.md
- Commitments:        _sources/20-proposal-content.md
- Rendered client:    ../00_presale/_output/10-wbs-final.xlsx
                      ../00_presale/_output/20-proposal-final.docx
```

Write incrementally (skeleton first, append each section) per BA-kit Large Artifact Write Protocol. For each section written, append the corresponding rows to `handoff-manifest.md` before moving to the next section.

## Step 5 — Compose plan.md `[MECHANICAL — template fill]`

Deterministic template fill from WBS phases. Minimal LLM needed — just extract phase names and map to module slugs.

Write `plans/{slug}-{date}/01_intake/plan.md`:

```markdown
# Plan — {client_name} / {project_name}

> Generated from /ba-presale handoff.
> Engagement mode: {hybrid | lite | formal}  (default: hybrid)

## Source of Truth
- Intake:    01_intake/intake.md
- Backbone:  (to be generated by /ba-start backbone)

## Proposed Module Breakdown
<derive modules from WBS §2 phases / work packages>
- {module_slug_1}  — {short description}  [src:wbs:P1]
- {module_slug_2}  — {short description}  [src:wbs:P2]

## Next Steps (/ba-start)
1. /ba-start backbone              — lock system-level backbone + portal matrix
2. /ba-start frd --module {slug}   — FRD per module
3. /ba-start stories --module {slug}
4. /ba-start srs --module {slug}
5. /ba-start wireframes --module {slug}  (only if UI-backed)
6. /ba-start package               — compile final HTML
```

## Step 6 — Finalize handoff manifest `[MECHANICAL — template fill]`

Manifest rows were written inline during Step 4. This step only adds the header and bundle versions table.

Write the header and footer of `plans/{slug}-{date}/01_intake/handoff-manifest.md`:

```markdown
# Handoff Manifest — {slug}-{date}

| Fact in intake.md | Section | Source ref |
|-------------------|---------|------------|
{rows already written inline during Step 4}

## Bundle Versions
- Domain Primer:     {date}
- Clarifications:    v{X.Y} ({answered}/{N} answered)
- WBS:               v{X.Y}
- Proposal:          v{X.Y}
```

## Step 7 — Continuity check `[MECHANICAL — Bash/Grep FIRST]` (BLOCKING)

**Execution rule:** MUST use Bash/Grep for all string-matching checks. Only escalate to LLM judgment when a semantic mismatch (not exact string) requires interpretation. Do NOT use LLM for checks that Grep can answer deterministically.

**Source ref pattern:** `[src:...]` refs in `intake.md` may use any of these formats — all are valid:
- `[src:wbs:1.1]`, `[src:wbs:P1]`, `[src:wbs:§2]`
- `[src:proposal:§7.1]`, `[src:proposal:§1.1]`
- `[src:clarify:Q1]`, `[src:assumption:A1]`
- `[src:client:<filename>§<section>]`, `[src:domain:§<n>]`

Grep pattern for ref presence check: `\[src:[a-z]`

```bash
# Example Bash checks (adapt paths to resolved slug/date)
grep -c "\[src:[a-z]" plans/{slug}-{date}/01_intake/intake.md
grep -i "P1\|phase 1\|Phase 1" plans/{slug}-{date}/01_intake/intake.md
```

Verify ALL of:

1. Every WBS phase (P1–Pn) appears in `intake.md` §3.1 In-scope.
2. Every Proposal commitment from §7.1 (In-Scope) appears in `intake.md` §3.1 or §4.
3. Every Proposal Exclusion from §7.2 (Out-of-Scope) appears in `intake.md` §3.2.
4. Every Clarifications row with Status=Answered appears in `intake.md` §5.
5. Every Clarifications row with Status=Skipped appears in `intake.md` §6 OR §4 (as assumption).
6. Every fact in `intake.md` has at least one `[src:...]` ref.
7. Every `[src:...]` ref in `intake.md` resolves to a real source (file + section exist).

On ANY failure → block handoff with explicit list:

```
❌ Continuity check FAILED:
   - WBS phase P3 not found in intake.md §3.1
   - Proposal §7.1 deliverable "Training pack" not in intake.md §3.1
   - Clarifications Q4 (Answered) not in intake.md §5
   - intake.md §1.2 missing source ref

Fix intake.md and re-run /ba-presale handoff.
```

## Step 8 — State card `[MECHANICAL]`

Write `paths.presale_state_cards/04-handed-off.md` (≤300 tokens, Vietnamese):
- intake.md + plan.md paths + versions
- handoff-manifest.md path
- bundle versions snapshot
- next command: `/ba-start backbone --slug {slug} --date {date}`

## Step 9 — Confirmation `[MECHANICAL]`

```
✅ Handoff complete.

Generated:
  plans/{slug}-{date}/01_intake/intake.md
  plans/{slug}-{date}/01_intake/plan.md
  plans/{slug}-{date}/01_intake/handoff-manifest.md
  plans/{slug}-{date}/01_intake/_sources/  (mirror, presale analysis only)

Presale bundle (read-only reference for downstream):
  plans/{slug}-{date}/00_presale/*

Next command:
  /ba-start backbone --slug {slug} --date {date}

⚠️  WBS + Proposal are now source of truth for downstream BA-kit.
   /ba-start backbone must not silently contradict them.
```

## Forbidden

- Delegating any step here. Lead does it all inline.
- Re-asking the user for scope/stakeholder/goal inputs already in Domain Primer / Clarifications / WBS / Proposal.
- Skipping the continuity check.
- Generating intake.md without source refs.
- Mutating presale artifacts during handoff (presale bundle is read-only at this stage).
- Auto-running `/ba-start backbone` after handoff. User must trigger explicitly.

## Memory Capture

Handoff is the transition point from presale to `/ba-start`. After continuity check passes, promote key presale facts to global memory for use during backbone:

| What to capture | Target shard | Trigger |
|---|---|---|
| Project slug, date, engagement mode, module breakdown | Global memory (`project` type) | After handoff completes |
| Key scope decisions (in-scope phases, out-of-scope items) | Global memory (`project` type) | After continuity check passes |
| Remaining open questions (Status=Skipped) that need resolution in backbone | Global memory (`project` type) | When open questions exist at handoff |
| Stakeholder roles confirmed in intake.md | Global memory (`project` type) | After intake.md is composed |

**Note:** These global memory entries serve as the seed for the project memory shard that `/ba-start backbone` will initialize. Set `Confidence: high` for client-confirmed facts, `medium` for agent-inferred items.
