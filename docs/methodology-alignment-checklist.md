# Methodology Alignment Checklist

> **When to use:** Before executing any change to BA-kit — merge, implement, update, refactor, or add a new skill/script/rule. This checklist ensures every change aligns with or explicitly extends the methodology documented in `METHODOLOGY.md`.
>
> Claude must run this checklist before proceeding with any BA-kit change. If any check fails or is uncertain, surface it to the user before executing.

---

## Step 1 — Classify the Change

Identify which category the change falls into:

| Category | Examples |
|----------|---------|
| **A — New skill or command** | `/brainstorm`, `/ba-notion`, new `/ba-start` subcommand |
| **B — New artifact type** | New doc template, new frontmatter schema, new output format |
| **C — New runtime behavior** | New guardrail, new gate, new validation script, new index type |
| **D — Structural refactor** | Shard architecture, file reorganization, contract.yaml changes |
| **E — Upstream merge** | PR from `anhdam2/bakit` or other upstream |
| **F — Rule/convention update** | Changes to `core/contract-behavior.md`, `core/contract.yaml`, `.claude/rules/` |
| **G — Documentation only** | Changes to `docs/`, `METHODOLOGY.md`, `CLAUDE.md`, `README.md` |

---

## Step 2 — Run the Alignment Checks

Answer each question. For upstream merges (Category E), apply to **each PR individually**.

### Check 1 — Methodology Coverage
> Does `METHODOLOGY.md` already cover the BA standard or approach this change implements?

- **Yes** → note which section. Proceed to Check 2.
- **No** → determine if the change introduces a new methodology (needs a new METHODOLOGY.md section) or is purely infrastructure (no methodology entry needed).
- **Uncertain** → surface to user before proceeding.

**Methodology areas to check against:**
- Presale: Domain Research, BABOK 8-category elicitation, PMI WBS, Proposal v4.0, Sync-Check, Traceability
- Requirements: BABOK v3 elicitation, Jeff Patton story mapping, MoSCoW, IEEE 830/ISO 29148, Wiegers/IIBA UC, Cockburn goal levels, INVEST, Gherkin/BDD, Story Splitting
- Proprietary: Screen Contract Plus, Portal Matrix, Source Traceability, Snapshot Truth, As-Built Separation, Automated QC Gate
- Pre-intake: Brainstorm elicitation (BABOK v3)
- Reverse mode: IEEE 830 as-built, Snapshot Truth, No-Broad-Read, Reverse-Web Pipeline

### Check 2 — Artifact Traceability
> Does the change produce, modify, or consume BA artifacts?

- **Yes** → verify the artifact carries or preserves traceability obligations:
  - Frontmatter: `type`, `status`, `created`, `updated`, `changelog`
  - Cross-references: `links`, inline `[src:...]` refs where applicable
  - Open questions: `[ ]` markers inherited by downstream skills
- **No** → skip to Check 3.

### Check 3 — Quality Gate Impact
> Does the change affect UC artifacts, SRS screens, user stories, or acceptance criteria?

- **Yes** → confirm the `qc-uc-review` gate still fires correctly after the change. If the change modifies gate behavior, verify the gate profile table in METHODOLOGY.md is still accurate.
- **No** → skip to Check 4.

### Check 4 — Reverse Mode Boundary
> Does the change touch reverse mode commands, scripts, or artifacts?

- **Yes** → verify:
  - As-built vs future-state separation is preserved
  - `reverse_baseline_lock` is respected
  - No broad reads introduced without `READ_ESCALATION`
  - Snapshot Truth principle not violated
- **No** → skip to Check 5.

### Check 5 — Local Customization Preservation
> Does the change risk overwriting local-only additions?

Local-only sections that must never be silently overwritten:
- `core/contract-behavior.md`: Memory Governance sections (Project Memory Contract, Memory Architecture Contract, Activation Contract, Multi-BA Governance Contract)
- `core/contract-behavior.md`: Delegation Loop Bounds
- `core/contract.yaml`: `presale_detection` block
- `.claude/rules/ba-kit/`: all rule files
- `CLAUDE.md` (bakit): Vietnamese instructions, presale flow, checkpoint logic

- **Change touches any of the above** → explicitly confirm local content is preserved before applying.
- **No overlap** → proceed.

---

## Step 3 — Determine Action

| Result | Action |
|--------|--------|
| All checks pass | Proceed with change |
| Check 1 fails — new methodology needed | Draft new METHODOLOGY.md section first, get user approval, then proceed |
| Check 1 fails — infrastructure only | Note "no methodology entry needed" in commit message, proceed |
| Check 2/3/4 fails | Fix the gap before marking change complete |
| Check 5 fails | Resolve conflict explicitly — do not auto-overwrite local content |
| Any check uncertain | Surface to user before proceeding |

---

## Quick Reference: Change Category → Checks Required

| Category | Check 1 | Check 2 | Check 3 | Check 4 | Check 5 |
|----------|---------|---------|---------|---------|---------|
| A — New skill | ✅ required | ✅ if artifact-producing | ✅ if UC/story/screen | ✅ if reverse | ✅ always |
| B — New artifact type | ✅ required | ✅ required | ✅ if UC/story/screen | ✅ if reverse | ✅ always |
| C — New runtime behavior | ✅ required | — | ✅ if gate-related | ✅ if reverse | ✅ always |
| D — Structural refactor | ✅ verify no regression | ✅ verify traceability intact | ✅ verify gate intact | ✅ verify reverse intact | ✅ always |
| E — Upstream merge | ✅ per PR | ✅ per PR | ✅ per PR | ✅ per PR | ✅ per PR |
| F — Rule/convention update | ✅ required | — | — | — | ✅ always |
| G — Documentation only | ✅ verify accuracy | — | — | — | — |

---

## Methodology Alignment Sign-Off

When all checks pass, include in the commit message or merge note:

```
methodology-check: pass
  - Check 1: [section name in METHODOLOGY.md, or "infrastructure — no entry needed"]
  - Check 2: [traceability preserved / not applicable]
  - Check 3: [qc gate unaffected / verified / not applicable]
  - Check 4: [reverse boundary respected / not applicable]
  - Check 5: [local content preserved / not applicable]
```

If a new METHODOLOGY.md section was added as part of this change, note:

```
methodology-check: pass (new section added)
  - New section: [section title]
```

---

## Reference

Full methodology with step-level mapping and source citations: `METHODOLOGY.md`
Quality standards detail: `docs/ba-methodology-guide.md`
BA conventions and rules: `.claude/rules/ba-kit/`
