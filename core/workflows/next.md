<purpose>
Detect the next logical BA step from the current BA-kit artifact set.

This command is the BA equivalent of a lightweight state machine. It reads the current project artifacts and recommends the next exact command.
</purpose>

<required_reading>
Read the installed BA playbook, `contract.yaml`, and `contract-behavior.md` before computing the next step.
</required_reading>

<process>

<step name="resolve_project">
Resolve the target slug and dated set using the artifact contract.

Rules:
- prefer explicit `--slug`
- otherwise detect a single existing project set from exact BA-kit artifact patterns (presale or ba-start)
- if ambiguous, stop and ask the user to choose
</step>

<step name="detect_lifecycle">
Determine which lifecycle the project is in:

- **Presale** — `00_presale/` folder exists in the project root (cwd or resolved slug folder).
- **BA-start** — `plans/{slug}-{date}/01_intake/intake.md` exists.
- **Both** — presale is complete and ba-start has begun; treat as ba-start lifecycle.
- **Neither** — no artifacts found; recommend `/ba-presale` if raw client material exists, otherwise `/ba-start`.
</step>

<step name="inspect_presale_artifacts">
If lifecycle is **presale**, inspect which of these exist:

- `00_presale/00-inputs/` (bootstrap done)
- `00_presale/00-domain-primer.md` (Phase 1 done)
- `00_presale/05-clarifications.md` (Phase 2 done)
- `00_presale/10-wbs-content.md` + `00_presale/20-proposal-content.md` (Phase 3 done)
- `00_presale/_output/*.xlsx` + `00_presale/_output/*.docx` (auto-render done)
- `plans/{slug}-{date}/01_intake/intake.md` (Phase 4 / handoff done)
</step>

<step name="determine_next_presale_step">
If lifecycle is **presale**, apply the first matching rule:

1. `00-inputs/` missing or empty → next step `/ba-presale` (bootstrap + domain study)
2. `00-domain-primer.md` missing → next step `/ba-presale` (domain study)
3. `05-clarifications.md` missing → next step `/ba-presale clarify`
4. `10-wbs-content.md` or `20-proposal-content.md` missing → next step `/ba-presale build`
5. xlsx/docx missing but wbs/proposal content exists → next step `/ba-presale build` (re-render)
6. intake.md missing → next step `/ba-presale handoff`
7. intake.md exists → presale complete; switch to ba-start inspection below
</step>

<step name="inspect_artifacts">
If lifecycle is **ba-start**, inspect the resolved artifact set and determine which of these exist:
- intake
- backbone
- frd
- user stories
- srs
- wireframe-input
- wireframe-map
- wireframe-state
- packaged FRD/SRS HTML

Read the backbone gate section when it exists. Use it to decide whether FRD, SRS, wireframes, or packaging are required.
</step>

<step name="determine_next_step">
If lifecycle is **ba-start**, apply the first matching rule:

1. no intake → next step `ba-start intake`
2. intake exists but no backbone → `ba-start backbone --slug <slug>`
3. backbone exists and FRD is explicitly required but missing → `ba-start frd --slug <slug>`
4. backbone exists but user stories are missing → `ba-start stories --slug <slug>`
5. SRS is required and missing → `ba-start srs --slug <slug>`
6. wireframe-input exists and wireframe-state is missing while wireframe handoff is required → `ba-start wireframes --slug <slug>`
7. final markdown exists but required packaged HTML is missing → `ba-start package --slug <slug>`
8. everything required already exists → `ba-start status --slug <slug>`

When FRD/SRS/wireframe-handoff gates are unclear, explain the uncertainty and recommend `ba-start status --slug <slug>` instead of guessing.
</step>

<step name="display">
Print:

```text
BA Next

Project: {slug}
Lifecycle: presale | ba-start
Date set: {date}
Next command: /ba-presale ... | /ba-start ...
Reason: ...
```

Do not mutate artifacts during this command.
</step>

</process>

<success_criteria>
- [ ] Project set resolved exactly or ambiguity surfaced
- [ ] Current artifact set inspected from exact patterns
- [ ] Next BA command recommended from the current state
- [ ] No artifacts mutated
</success_criteria>
