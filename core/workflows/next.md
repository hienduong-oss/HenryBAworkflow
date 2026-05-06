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
- otherwise detect a single existing project set from exact BA-kit artifact patterns
- if ambiguous, stop and ask the user to choose
- when the next exact command would be module-scoped (`frd`, `stories`, `srs`, or `wireframes`), resolve the module using the contract rules before emitting the command
- if multiple module directories exist, stop and ask instead of emitting an incomplete module-scoped command
</step>

<step name="inspect_artifacts">
Inspect the resolved artifact set and determine which of these exist:
- intake
- plan
- options index
- option files
- comparison file
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
Apply the first matching rule:

1. no intake -> next step `ba-start intake`
2. intake exists and `paths.plan` says options are `recommended` or `in-progress` -> `ba-start options --slug <slug>`
3. intake exists and `paths.plan` is missing, invalid, or says `completed` without `selected option` -> `ba-start status --slug <slug>`
4. intake exists, `paths.plan` says options are `not-needed`, and no backbone -> `ba-start backbone --slug <slug>`
5. intake exists, `paths.plan` says options are `skipped`, or `completed` with `selected option` recorded in `paths.plan`, and no backbone -> `ba-start backbone --slug <slug>`
6. backbone exists and FRD is explicitly required but missing -> `ba-start frd --slug <slug> --module <module_slug>`
7. backbone exists but user stories are missing -> `ba-start stories --slug <slug> --module <module_slug>`
8. SRS is required and missing -> `ba-start srs --slug <slug> --module <module_slug>`
9. wireframe-input exists and wireframe-state is missing while wireframe handoff is required -> `ba-start wireframes --slug <slug> --module <module_slug>`
10. final markdown exists but required packaged HTML is missing -> `ba-start package --slug <slug>`
11. everything required already exists -> `ba-start status --slug <slug>`

When FRD/SRS/wireframe-handoff gates are unclear, explain the uncertainty and recommend `ba-start status --slug <slug>` instead of guessing.
</step>

<step name="display">
Print:

```text
BA Next

Project: {slug}
Date set: {date}
Project Home: {PROJECT-HOME.md exists/missing}
Next command: /ba-start ...
BA-facing next step: ...
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
