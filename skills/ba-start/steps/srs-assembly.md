# BA Start Step - SRS Assembly

## Checkpoint

Write `plans/{slug}-{date}/_checkpoint.md` as the **first action**:
```
step: srs-assembly
status: running
command: <exact invoked command>
started: <ISO timestamp>
updated: <ISO timestamp>
```
On complete, update `status: completed` and `updated`.

This step requires:

- `core/contract.yaml`
- `core/contract-behavior.md`

**Orchestration note:** Assembly (Step 11) is split into mechanical concat (Bash-friendly) and judgment-based consistency check (Opus). Do not use Opus context for the merge itself — it is deterministic concatenation in a fixed order.

## Step 10.1 - Produce validation pack `[JUDGMENT — delegate to ba-documentation-manager]`

Produce the validation and traceability pack from the completed SRS sections. Prefer `ba-documentation-manager` ownership when delegated.

Sections:

- Test Cases
- Glossary
- Traceability cross-references

Output: `paths.srs_group` with `group=f`

## Step 11 - Assembly and quality review

The orchestrator assembles the final SRS inline. Do not delegate assembly.

### Phase 11a — Merge groups `[MECHANICAL — deterministic concat]`

This is pure concatenation in a fixed order. No LLM judgment needed for the merge itself. Prefer Bash `cat` or sequential Read+Edit-append. The orchestrator should NOT "think" about what to merge — just follow the template order.

Assembly procedure:

1. Write the SRS skeleton to `paths.srs` using the `srs-template.md` heading structure.
2. For each group in template order (`A -> B -> C -> D -> E -> F`):
   - read the group fragment from `paths.srs_group`
   - edit-append it into the matching section of the skeleton
   - confirm the edit succeeded before moving on

### Phase 11b — Cross-artifact consistency check `[JUDGMENT — Opus]`

This is a true judgment point — the orchestrator must detect semantic mismatches across artifacts. Opus is justified here.

3. After all groups are appended, run a cross-artifact consistency check on the file on disk:
   - every UC step maps to a screen field or action and vice versa
   - Screen Contract Plus entries have matching manual wireframe constraints and final screen descriptions
   - UC actor actions use the same wording as screen User Actions
   - UC system responses match screen Behaviour Rules
   - alternate flows are reflected in screen error states
   - user story acceptance criteria are covered by UC postconditions and screen validation rules
   - final screen descriptions do not redefine `Portal ID`, `Nav Schema ID`, or active/highlight behavior captured in Group C or the wireframe pack
   - run `python3 scripts/validate-navigation-consistency.py --design {paths.design_doc} --screen-contract {paths.srs_group group=c}` when UI-backed screens and `paths.design_doc` exist
   - treat `MENU_SCHEMA_MISMATCH`, `NAV_SCHEMA_MISMATCH`, and `MENU_ACTIVE_MISSING` as blocking before final assembly is accepted

### Phase 11c — Cleanup `[MECHANICAL]`
4. Resolve placeholder references and ID conflicts inline.
5. Verify every SCR and UC traces back to user stories.
6. Delete group fragments only after the merged SRS is verified.

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

If a grouped pass fails, retry once. If it still fails, complete that group inline. The merge itself always runs inline.
