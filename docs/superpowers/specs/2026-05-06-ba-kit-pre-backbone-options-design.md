# Design Spec: Pre-Backbone Solution Options Flow for BA-kit

## 1. Design Summary

BA-kit should support an optional `options` step between `intake` and `backbone`.

The purpose of this step is to let the agent and BA:

- explore 1-3 viable solution directions from the normalized intake
- package those directions cleanly enough for stakeholder review
- force an explicit decision before the first official source-of-truth artifact is built

This step is not a replacement for `backbone`.

It is a pre-decision layer that helps:

- reduce costly rewrites of `backbone.md`
- avoid locking into one solution shape too early
- create stakeholder-facing comparison material when multiple directions are realistic

## 2. Goals

Primary goals:

- reduce downstream backbone churn by pushing solution-shape decisions earlier
- create a clean deliverable that BA can use internally or send to stakeholders for option selection

Secondary goals:

- help the agent avoid premature convergence from the intake alone
- keep official execution artifacts separate from exploratory options
- preserve fail-closed behavior when a decision is still unresolved

## 3. Non-Goals

This design does not aim to:

- turn intake into a full solution-design phase by default
- replace `backbone.md` as the post-decision source of truth
- generate full FRD, stories, or SRS content for each option
- allow silent fallback from unresolved optioning into backbone generation

## 4. Recommended Lifecycle Change

Current high-level shape:

```text
intake -> plan -> backbone
```

Proposed high-level shape:

```text
intake -> recommendation gate
       -> skip options -> plan decision note -> backbone
       -> run options -> option pack + comparison -> select/skip -> plan decision note -> backbone
```

Decision behavior:

- after intake, the agent recommends either `go direct to backbone` or `run options`
- BA chooses whether to enter the `options` step
- if `options` is entered, backbone cannot proceed until `plan.md` records either `selected option` or `skipped`

## 5. Source-of-Truth Rules

Artifact roles after this change:

- `01_intake/intake.md`
  - normalized requirements, gaps, assumptions, open questions
  - must not be polluted with detailed solution-option authoring
- `01_intake/options/*`
  - pre-decision solution exploration and comparison artifacts
  - reviewable by BA and stakeholders
  - not authoritative after a final option is chosen
- `01_intake/plan.md`
  - execution decision ledger
  - records whether options were skipped or completed
  - records which option was chosen and what command comes next
- `02_backbone/backbone.md`
  - the first official source of truth after decision lock
  - built from `intake.md` plus the chosen option overlay when optioning occurred

## 6. Why Not Inline Options Into Existing Artifacts

Rejected approach 1: inline options inside `intake.md` or `plan.md`

Why rejected:

- mixes normalized requirements with solution shaping
- weakens the meaning of intake as a mostly factual artifact
- makes stakeholder-facing option review harder to isolate
- makes `plan.md` too verbose for its real job as an agent-facing execution pointer

Rejected approach 3: create mini-backbones for every option

Why rejected:

- too heavy for early-stage decision support
- duplicates too much content
- increases BA review cost without enough added value

Recommended approach:

- create a dedicated pre-backbone option pack under `01_intake/options/`

## 7. Proposed Artifact Structure

New directory:

```text
plans/{slug}-{date}/01_intake/options/
  index.md
  option-01.md
  option-02.md
  option-03.md
  comparison.md
```

Expected behavior:

- the folder exists only when optioning is recommended and accepted
- `comparison.md` may be omitted when there is only one viable option, but a short note should still explain why no strong alternative was retained
- numbering must be stable inside one decision cycle

## 8. Option Artifact Model

### 8.1 `index.md`

Purpose:

- registry and navigation page for the current optioning cycle

Minimum content:

- project slug and date
- decision audience: BA internal, stakeholder review, or both
- option list
- status per option
- difference level per option
- recommended option if one exists
- final selected option if one exists

Proposed statuses:

- `draft`
- `reviewing`
- `selected`
- `rejected`
- `skipped`

### 8.2 `option-0x.md`

Purpose:

- a self-contained solution brief for one candidate direction

Minimum sections:

1. Option Summary
2. Business Intent
3. Scope Shape
4. Interaction View
5. Key Constraints And Gaps
6. Pros And Cons
7. Indicative Assessment

Required fields inside those sections:

- option name
- one-sentence summary
- difference level
- stakeholder fit
- portal list
- module list
- actor list
- in-scope and out-of-scope notes when scope differs materially
- actor/portal/module interaction diagram
- main constraints
- critical gaps before backbone
- assumptions and dependencies
- relative effort
- relative value
- relative difficulty
- confidence level

### 8.3 `comparison.md`

Purpose:

- support fast decision-making across multiple viable directions

Minimum comparison columns:

- option
- difference level
- summary
- effort
- value
- difficulty
- time-to-clarity
- main pros
- main cons
- key risks
- recommended when

## 9. Difference-Level Taxonomy

Each option must explicitly declare how different it is from the others.

### `L1` - Organization Difference

Use when:

- core scope stays mostly the same
- options differ mainly in how portals, modules, or workflow partitioning are organized

### `L2` - Solution Shape Difference

Use when:

- options differ in portal ownership, module boundaries, actor interactions, or major operational flow
- business goal stays recognizably the same, but the solution form changes meaningfully

### `L3` - Product Direction Or Scope Difference

Use when:

- options represent materially different product directions
- scope boundaries or product framing change enough that stakeholders must understand this is not just an implementation variation

Rule:

- every option set must declare difference level per option
- stakeholder-facing comparison must say where the differences sit, not only that differences exist

## 10. Recommendation Gate After Intake

The system should not always run options automatically.

Instead, after intake, the agent should issue one of three recommendations:

- `Go direct to plan/backbone`
- `Recommend running options`
- `Options strongly recommended before backbone`

Recommendation reasoning must cite signals.

Signals that support running options:

- multiple plausible solution directions exist
- solution shape is not yet settled
- there are meaningful trade-offs between effort, value, and difficulty
- portal or module partitioning could go different ways
- constraints or gaps are large enough to reshape backbone decisions
- BA explicitly wants material to review or send to stakeholders

Signals that support skipping options:

- solution shape is already effectively chosen
- scope is narrow and ambiguity is low
- alternatives would be cosmetic or low-value
- stakeholder only needs formalization, not decision support

## 11. Option Count Rules

Rules:

- default maximum is `3`
- do not force `3` when the intake supports only `1` or `2` meaningful directions
- a single-option package is allowed when the value is formalizing the recommended direction before backbone
- never invent weak alternatives just to make the comparison look richer

## 12. Quality Bar For Each Option

Every option must:

- differ in at least one meaningful dimension
- state its difference level clearly
- avoid fake precision when the intake is incomplete
- declare confidence honestly
- list decision gaps that must be resolved before backbone if confidence is low

An option must not:

- masquerade as already-approved scope
- contain detailed downstream artifacts that belong to FRD, stories, or SRS
- silently override intake facts

## 13. `plan.md` Decision Block

`plan.md` should stay light, but it must carry enough context for the agent to continue safely.

### When Options Are Skipped

Required fields:

- options status: `skipped`
- decision note
- reason summary
- next step command

### When Options Are Completed

Required fields:

- options status: `completed`
- selected option id
- decision summary
- selected option reference
- comparison reference when comparison exists
- next step command

Rule:

- `plan.md` is not the content source of the chosen solution
- it is the decision ledger and execution pointer

## 14. Backbone Consumption Rules

When optioning occurred, `backbone.md` should be built from:

- `intake.md` as the normalized requirements base
- the selected option as a decision overlay

What the backbone may promote from the chosen option:

- portal structure
- module shape
- actor interaction assumptions
- major constraints
- major gaps that must remain visible downstream

What the backbone should not import wholesale:

- rejected options
- raw comparison content
- exploratory wording that was never chosen

If useful, the backbone may include a short decision note that alternative directions were considered and rejected, but it should not become a history dump.

## 15. Fail-Closed Rules

Critical rule:

- if `01_intake/options/` exists as an active optioning cycle, `backbone` must not proceed unless `plan.md` records either `selected option` or `skipped`

Additional fail-closed behavior:

- unresolved optioning must block backbone generation
- missing decision state must surface an exact correction path
- the system must not select an option implicitly based on wording or file order

## 16. Command And Routing Proposal

Recommended command name:

- `options`

Why this name:

- BA-friendly
- artifact-oriented
- clearer than naming the step after a thinking activity such as `brainstorm`

Proposed command surface:

```text
/ba-start options --slug <slug>
/ba-start options --slug <slug> --select option-02
/ba-start options --slug <slug> --skip
```

Natural-language router should map phrases such as:

- `hãy brainstorm solution options`
- `tạo các phương án để gửi khách chọn`
- `chốt option 2`
- `bỏ qua bước option`

`ba-next` should be able to recommend this step after intake when signals justify it.

## 17. Proposed Decision States

Suggested high-level states for the optioning step:

- `not-needed`
- `recommended`
- `in-progress`
- `completed`
- `skipped`

These states should be visible in BA-facing dashboards and usable by `ba-next`.

## 18. Risks And Mitigations

### Risk 1: Option Pack Becomes Too Heavy

Mitigation:

- keep each option at solution-brief level
- defer detailed behavior, rules, and acceptance logic to downstream artifacts

### Risk 2: Fake Choice Inflation

Mitigation:

- do not generate filler alternatives
- allow a single-option package
- require meaningful differences

### Risk 3: Stakeholders Misread Draft Options As Commitment

Mitigation:

- label all option pack artifacts as pre-decision material
- keep the final commitment in plan/backbone only

### Risk 4: Backbone Starts Without A Real Decision

Mitigation:

- enforce a fail-closed prerequisite check against `plan.md`

### Risk 5: Future Change Routing Becomes Ambiguous

Mitigation:

- after backbone exists, requirement changes still route through `impact`
- option pack becomes decision history, not the new source of truth

## 19. Edge Cases

### No Option Generated

Behavior:

- invalid as an active optioning cycle
- if no optioning is needed, the correct state is `skipped`

### Single Option Only

Behavior:

- valid
- useful when BA wants one clean recommended direction before backbone

### Multiple Low-Confidence Options

Behavior:

- allowed only if each option marks confidence and decision gaps clearly

### Stakeholder Revises The Selected Option Before Backbone

Behavior:

- update the selected option file
- refresh `comparison.md` if the comparison meaning changes
- refresh the decision note in `plan.md`

### Backbone Already Exists, Then Team Wants To Reconsider Direction

Behavior:

- do not silently reopen pre-backbone optioning
- treat this as a higher-level change analysis and route through `impact` or an explicitly designed reconsideration flow

## 20. Acceptance Criteria For This Design

The design is successful if BA-kit can:

1. let BA choose whether to run optioning after intake
2. generate 1-3 clearly differentiated solution options
3. generate stakeholder-friendly comparison material when multiple options exist
4. record skip/select decisions in `plan.md` without bloating that file
5. prevent backbone generation when optioning is unresolved
6. keep `backbone.md` as the first post-decision source of truth
7. preserve later change routing through `impact`

## 21. Recommendation

Adopt the pre-backbone `options` flow with these constraints:

- optional by BA decision, not mandatory by default
- stored under `01_intake/options/`
- decision captured lightly in `plan.md`
- consumed by `backbone` only after explicit selection or skip
- enforced with fail-closed prerequisite checks

This is the lightest design that still delivers both desired outcomes:

- better early decision quality
- cleaner stakeholder-facing option artifacts
