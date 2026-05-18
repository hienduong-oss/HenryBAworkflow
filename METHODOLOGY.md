# BA-kit — Methodology Reference

BA-kit is a lifecycle engine for solo IT Business Analysts. It is not a blank-slate prompt collection — every step is grounded in established BA and software engineering methodologies. This document maps each flow and artifact to the standards it applies.

---

## Presale Flow (`/ba-presale`)

### Phase 1 — Domain Study
**Domain Research & Synthesis**
The `ba-researcher` agent conducts structured domain research before any requirements work begins. Findings are synthesized into a Domain Primer covering business context, domain knowledge, technical landscape, assumptions, and early risks. This mirrors the *elicitation and collaboration* knowledge area in BABOK v3.

### Phase 2 — Clarify
**BABOK v3 — 8-Category Elicitation Framework**
Gap analysis is structured across 8 categories aligned with the IIBA *Business Analysis Body of Knowledge* (v3):
Stakeholders · Scope · Success Criteria · Compliance & Legal · UI/UX · Business Process · Technical/Integration · Commercial.
Source: IIBA, *BABOK Guide* v3.

### Phase 3 — Build: WBS
**PMI PMBOK 7th Edition — Work Breakdown Structure**
The WBS follows PMI's decomposition standard: EPIC rows = work packages, feature rows = work items. Each feature row carries an actor-perspective acceptance condition and effort estimates split by frontend and backend. The 8-column schema (ID · Category · Function · Sub-Function · Actor · Notes · Web/mobile days · Backend days) is derived from PMBOK's WBS dictionary concept.
Source: PMI, *PMBOK Guide* 7th ed.

### Phase 3 — Build: Proposal
**Structured Proposal Format v4.0**
BA-kit's Proposal follows a structured §1–§11 format covering Executive Summary, Business Context, Objectives, Scope (In/Out/Assumptions), Approach, Team, Timeline, Effort, Commercial Terms, and Appendix. Two variants: Variant A (Platform/Integration — vendor-led, discovery-heavy) and Variant B (Custom-Build — fixed-price, phase-based).

### Phase 3 — Sync-Check
**Cross-Artifact Consistency + Source Priority Anchoring**
After WBS and Proposal are built in parallel, a sync-check verifies consistency across: phases ↔ §7.1 In-Scope, effort totals ↔ §9, exclusions ↔ §7.2, assumptions ↔ §7.3. Conflicts are resolved by source priority: client raw > answered clarification > assumed clarification > domain primer > documented assumption. This is a BA-kit proprietary conflict resolution protocol.

### All Phases — Traceability
**Inline Source Reference Protocol**
Every fact in WBS rows, Proposal sections, and clarifications carries an inline `[src:...]` reference. Format: `[src:client:<file>§<sec>]` · `[src:domain:§<n>]` · `[src:clarify:Q<n>]` · `[src:assumption:A<n>]` · `[src:wbs:<id>]`. Artifacts without source refs are blocked from rendering. This is a BA-kit proprietary traceability standard.

---

## Requirements Flow (`/ba-start`)

### Step 1–4 — Intake & Gap Analysis
**BABOK v3 — Elicitation & Collaboration**
The intake normalization and gap analysis follow BABOK v3's elicitation knowledge area. The 8-category gap analysis (Stakeholders, Scope, Success Criteria, Compliance, UI/UX, Business Process, Technical/Integration, Commercial) maps directly to BABOK v3 knowledge areas.
Source: IIBA, *BABOK Guide* v3.

### Step 5 — Requirements Backbone
**Jeff Patton — User Story Mapping**
The backbone's preliminary story map is structured using Jeff Patton's User Story Mapping technique: user activities on the horizontal axis, story depth and priority on the vertical axis. This reveals scope, sequencing, and release slicing before any detailed artifact work begins.
Source: *User Story Mapping*, Jeff Patton (O'Reilly, 2014).

**MoSCoW Prioritization**
FR/NFR inventory and feature map use Must / Should / Could / Won't priority classification.
Source: DSDM Consortium.

**FR/NFR Separation (IEEE 830 / ISO/IEC 29148)**
Functional Requirements (what the system does) are separated from Non-Functional Requirements (quality attributes: performance, security, usability, reliability, compliance) following IEEE 830 and ISO/IEC 29148:2018 conventions.
Source: IEEE Std 830-1998; ISO/IEC/IEEE 29148:2018.

**Portal Matrix (BA-kit proprietary)**
For UI-backed scope, the backbone locks portal ownership, route-group ownership, and navigation schema at system level before any module-level screen work begins. This prevents navigation inconsistency across modules.

### Step 6 — FRD: Use Case Specifications
**Karl Wiegers / IIBA — 13-Field Use Case Template**
Use Case Specifications follow the Wiegers/IIBA standard 13-field structure: UC-ID · UC Name · Primary Actor · Description · Preconditions · Postconditions · Normal Course · Alternative Courses · Exceptions · Special Requirements · Assumptions · Frequency of Use · Open Issues.
Source: *Software Requirements* 3rd ed., Karl Wiegers & Joy Beatty (Microsoft Press, 2013).

**Alistair Cockburn — Goal Levels & Coffee-Break Test**
UC scope is validated using Cockburn's goal-level classification: sea-level (user goal, primary UC), kite-level (business process summary), fish-level (sub-function). The coffee-break test ensures sea-level UCs represent work completable in one user session.
Actor classification follows Cockburn: Primary (initiates, has the goal) · Secondary (supports) · Offstage (has a stake, does not interact directly).
Source: *Writing Effective Use Cases*, Alistair Cockburn (Addison-Wesley, 2000).

**UC Identification — Three Techniques**
Coverage is ensured via: goal-driven (actor + goal pairs), event-driven (system events triggering a response), CRUD-driven (Create/Read/Update/Delete per entity).

**20-Point UC Quality Checklist**
Every UC is validated against 20 criteria before being marked complete, covering: naming, scope, actor specificity, precondition verifiability, postcondition completeness, Normal Course structure, Alternative Course referencing, Exception completeness, and Special Requirements separation.

**MoSCoW Prioritization** — feature list priority.

### Step 7 — User Stories
**Bill Wake — INVEST Criteria (2003)**
Every user story is validated against all 6 INVEST criteria before being written to the artifact: Independent · Negotiable · Valuable · Estimable · Small · Testable.
Source: *INVEST in Good Stories, and SMART Tasks*, Bill Wake, XP123.com (2003).

**Mike Cohn — User Story Format**
Stories follow the `As a [specific persona] / I want to [concrete action] / So that [distinct business value]` template.
Source: *User Stories Applied*, Mike Cohn (Addison-Wesley, 2004).

**Dan North — Gherkin / BDD Acceptance Criteria (2006)**
Acceptance Criteria use Given-When-Then format. Minimum 3 AC per story: happy path · edge case/boundary · negative path/error. AC must be measurable, free of implementation detail, and directly usable by QA to write test cases.
Source: *Introducing BDD*, Dan North, dannorth.net (2006). Tooling: Cucumber, SpecFlow, Behave.

**Richard Lawrence — Story Splitting Patterns**
Stories are split when they exceed INVEST compliance: >1 persona, >7–8 AC scenarios, multiple CRUD operations, multiple system boundaries, or dual business values in the "So that" clause.
Source: *Patterns for Splitting User Stories*, Richard Lawrence, Agile Alliance.

**MoSCoW Prioritization** — story priority.

### Step 8 — SRS
**IEEE 830 / ISO/IEC 29148:2018 — SRS Structure**
The SRS Group A (Purpose, Overall Description, Functional Requirements table) follows the IEEE 830 standard for Software Requirements Specifications, updated by ISO/IEC/IEEE 29148:2018.
Source: IEEE Std 830-1998; ISO/IEC/IEEE 29148:2018.

**Karl Wiegers / IIBA — 13-Field UC Template (Group B)**
Use Case Specifications in the SRS follow the same Wiegers/IIBA standard as the FRD. See Step 6 above.

**Screen Contract Plus (BA-kit proprietary)**
SRS Group C extends standard screen inventory with a navigation contract per screen: Portal ID · Nav Schema ID · Expected Active Menu Item · Navigation Region Visible · Breadcrumb/Back Behavior · Global vs Local Navigation · entry/exit conditions · required states · overlay classification. This ensures UI-to-requirement traceability at the field level.

### Step 9 — Wireframe Constraints
**Screen Contract Plus (BA-kit proprietary)**
Wireframe constraint packs are derived from Screen Contract Plus entries. Every screen has a traceable navigation contract before design begins.

**Supporting State Enumeration (from Cockburn UC Alternatives/Exceptions)**
Each Alternative Course and Exception documented in the UC spec maps to a required supporting state in the wireframe: empty state · error state · loading state · confirmation state · permission-denied state.

**Navigation Schema Locking**
Portal ownership and route-group ownership locked at backbone level (Portal Matrix). Wireframe constraints inherit from the locked schema — no module-level redefinition of global navigation is permitted.

---

## Quality Standards (applied across all artifacts)

| Standard | Applied to | Source |
|----------|-----------|--------|
| BABOK v3 — Elicitation | Intake, Gap Analysis, Clarify | IIBA |
| PMI PMBOK 7th ed. — WBS | Presale WBS | PMI |
| IEEE 830 / ISO/IEC 29148 | SRS structure, FR/NFR separation | IEEE / ISO |
| Wiegers/IIBA 13-field UC | FRD Use Cases, SRS Group B | Wiegers & Beatty |
| Cockburn goal levels + coffee-break test | UC scoping | Cockburn |
| INVEST (Bill Wake 2003) | User Stories | XP123.com |
| Gherkin / BDD (Dan North 2006) | Acceptance Criteria | dannorth.net |
| Story Splitting (Richard Lawrence) | User Stories | Agile Alliance |
| MoSCoW | Feature map, FR/NFR, Stories | DSDM Consortium |
| Jeff Patton Story Mapping | Backbone story map | O'Reilly 2014 |
| Screen Contract Plus | SRS Group C, Wireframes | BA-kit proprietary |
| Source Traceability `[src:...]` | All presale artifacts | BA-kit proprietary |
| Portal Matrix | Backbone, SRS, Wireframes | BA-kit proprietary |
