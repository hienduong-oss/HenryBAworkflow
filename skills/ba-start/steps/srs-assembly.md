# BA Start Step - SRS Assembly

This step requires:

- `core/contract.yaml`
- `core/contract-behavior.md`

## Step 10.1 - Produce validation pack

Produce the validation and traceability pack from the completed SRS sections. Prefer `ba-documentation-manager` ownership when delegated.

Sections:

- Test Cases
- Glossary
- Traceability cross-references

Output: validation and traceability sections inside `paths.srs`.

## Step 11 - Assembly and quality review

The orchestrator assembles `paths.srs` inline from canonical module sources. Do not delegate assembly.

Assembly procedure:

1. Write the SRS skeleton to `paths.srs` using the `srs-template.md` heading structure.
2. Synthesize an Executive / BA Summary from backbone goals, user story scope, `srs/*`, `usecases/index.md`, `ascii-screen/index.md`, and receipt metadata. Keep it under 15 lines.
3. Resolve `paths.usecases_index` and `paths.ascii_screen_index`; use them to locate `usecases/*.md`, `ascii-screen/*.md`, and present `paths.srs_*` slices.
4. Compile source sections into matching SRS sections:
   - use cases into Use Cases, including diagrams
   - screen canon into Screen Descriptions, including states and ASCII
   - `srs/flows.md` and `srs/erd.md` into diagrams/data model
   - indexes into inventory and traceability summaries
5. Write `paths.srs_compile_receipt` with source paths and hashes.
6. Run cross-artifact consistency checks on disk:
   - every UC step maps to a screen field or action and vice versa
   - Screen Contract Plus entries have matching canon screen sources and final screen descriptions
   - UC actor actions use the same wording as screen User Actions
   - UC system responses match screen Behaviour Rules
   - alternate flows are reflected in screen error states
   - every UI-backed screen canon file has `ascii_status: current` and required `## ASCII Wireframe` state subsections
   - user story acceptance criteria are covered by UC postconditions and screen validation rules
   - final screen descriptions do not redefine `Portal ID`, `Nav Schema ID`, or active/highlight behavior captured in Group C, screen canon, or the shared shell contract
   - run `python3 scripts/validate-navigation-consistency.py --design {paths.design_doc} --screen-contract {paths.screen_field_contract}` when applicable
   - treat `MENU_SCHEMA_MISMATCH`, `NAV_SCHEMA_MISMATCH`, and `MENU_ACTIVE_MISSING` as blocking before final assembly is accepted
7. Resolve placeholder references and ID conflicts inline.
8. Verify every SCR and UC traces back to user stories.
9. Do not delete canonical source files. If a source pass fails, retry once; then complete inline. The merge itself always runs inline.
