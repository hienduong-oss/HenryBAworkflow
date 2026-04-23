<!--
TEMPLATE: Clarifications (markdown source of truth)
PURPOSE: Gap-analysis-driven list of 8–15 clarifying questions with agent-suggested
         best-guess answers. Single markdown artifact, English content, no xlsx at
         this phase.
LOCATION (per project): plans/{slug}-{date}/00_presale/05-clarifications.md
LANGUAGE: English (artifact is client-facing).

HANDOFF RULE (CRITICAL):
- Rows with Status=Answered → become clarified facts in intake.md (/ba-start input).
- Rows with Status=Draft at handoff → blocked; handoff will refuse to proceed
  until user runs "accept all suggestions" or answers the remaining questions.
- Any answer that changes scope → must reflect into WBS / Proposal during
  /ba-presale build (or via surgical edit feedback loop after build).
-->

# Clarifications — {{client_name}} / {{project_name}}

> **Version:** v{{X.Y}} — {{YYYY-MM-DD}}
> **Status:** {{draft | reviewing | finalized}}
> **Source primer:** [00-domain-primer.md](./00-domain-primer.md)

---

## Clarifying Questions

| ID | Category | Question | Suggested Answer | Status | Impact | Notes |
|----|----------|----------|------------------|--------|--------|-------|
| Q1 | Stakeholders | {{Who is the primary decision maker for scope/sign-off on the client side?}} | {{Agent guess based on discussions or default assumption}} [src:domain:§1] | Draft | Governance + §11 proposal CTA | — |
| Q2 | Scope | {{Is feature X in MVP or future phase?}} | {{Agent guess — typically MVP based on RFP emphasis}} [src:client:RFP§2] | Draft | [src:wbs:2.x], proposal §7.1 | — |
| Q3 | Success Criteria | {{What is the measurable KPI for feature Y?}} | {{Agent guess — e.g., 20% conversion uplift}} [src:assumption:A1] | Draft | proposal §1.4 Objectives | Drives §11 pillars |
| Q4 | Compliance | {{Any data residency / regulatory constraint?}} | {{Agent guess — domestic default unless RFP says otherwise}} [src:domain:§4] | Draft | proposal §3 Technical Context | — |
| Q5 | UI/UX | {{Web-only or also mobile-native?}} | {{Agent guess — web responsive}} [src:assumption:A2] | Draft | [src:wbs:3.x] UI build effort | — |
| Q6 | Process | {{Approval flow: single or multi-level?}} | {{Agent guess — single approver default}} [src:domain:§2] | Draft | [src:wbs:4.x] workflow engine | — |
| Q7 | Technical | {{Integration with system Z: API-available or manual export?}} | {{Agent guess — REST API based on technical input sample}} [src:client:sample-api§1] | Draft | [src:wbs:5.x] integration effort | Depends on Q4 |
| Q8 | Commercial | {{Budget range and payment model (T&M vs. fixed)?}} | {{Agent guess — fixed-price phase-based}} [src:assumption:A3] | Draft | proposal §9 Quotation | Drives variant A vs B |
| Q{{n}} | … | … | … | Draft | … | … |

---

## Category Legend
- **Stakeholders** — decision makers, sponsors, end-users, support roles
- **Scope** — MVP boundary, in/out-of-scope, phasing
- **Success Criteria** — measurable outcomes, KPIs, adoption targets
- **Compliance** — regulations, data residency, privacy, audit, certifications
- **UI/UX** — platforms, devices, branding, accessibility, i18n
- **Process** — current/desired state flow, exceptions, volume
- **Technical** — external systems, auth, APIs, data migration, infra
- **Commercial** — budget, timeline anchor, payment model, engagement type

## Status Legend
- **Draft** — agent has proposed a suggested answer; awaiting user confirmation
- **Answered** — user has confirmed or overridden the suggested answer
- **Skipped** — user explicitly chose not to answer (treated as assumption at handoff)

---

## Impact Map

| Question | Affects | Action if answered differently |
|----------|---------|--------------------------------|
| Q{{n}} | [src:wbs:x.y], proposal §{{n}} | Update effort + recalc §9 quotation |
| Q{{n}} | proposal §8 Master Schedule | Recalculate milestone dates |

---

## Assumptions Made by Agent (for suggested answers)

When no direct source exists in Domain Primer / `00-inputs/`, the agent has inferred a default. These should be reviewed alongside the suggested answers:

| Assumption ID | Description | Used in Q# |
|---------------|-------------|-----------|
| A1 | {{e.g., 20% conversion uplift target is standard for this domain}} | Q3 |
| A2 | {{e.g., web-responsive sufficient — no native mobile in MVP}} | Q5 |
| A3 | {{e.g., fixed-price phase-based is the default commercial model}} | Q8 |

---

<!-- HANDOFF NOTE:
When /ba-presale handoff runs, it will:
1. Treat every Answered row as a clarified requirement → merge into intake.md §1–§4.
2. Treat every Skipped row as an assumption → add to intake.md §4.
3. Refuse handoff if any row is still Draft (unless user explicitly skipped via "accept all suggestions").
-->
