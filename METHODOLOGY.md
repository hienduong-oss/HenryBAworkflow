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
The WBS follows PMI's decomposition standard: EPIC rows = work packages, feature rows = work items. BA-kit supports two WBS break modes, selected by the user at `/ba-presale build` time:

**Mode A — feature-ui** (default for stakeholder communication)
Break axis: domain category → feature → actor action. Each feature row carries an actor-perspective acceptance condition. The 8-column schema (ID · Category · Function · Sub-Function · Actor · Notes · Web/mobile days · Backend days) is derived from PMBOK's WBS dictionary concept. BE complexity is captured in Notes — not broken into sub-rows. Best for: client review, requirements traceability, UC/AC authoring.

**Mode B — epic-component** (for delivery planning)
Break axis: phase → epic (technical layer) → deliverable task. Each row is a deliverable independently buildable, testable, and assignable. BE complexity is always broken into separate rows — no hiding in Notes. Cross-cutting EPICs (Infrastructure, Smart Contract, QA) are mandatory first-class EPICs. The 15-column schema (ID · Phase · Epic · Task Name · Layer · Notes · PM · BA · SC · BE · DevOps · Mobile · FE · QC · Total MD) supports multi-role effort allocation. Best for: sprint planning, dev task assignment, delivery tracking.

Both modes can coexist in the same project as separate files. Mode is declared at the top of every WBS file and passed explicitly to the `wbs-builder` sub-agent.
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

## Pre-Intake Elicitation (`/brainstorm`)

### Purpose
The `/brainstorm` skill runs **before** `/ba-start intake` when the user has a raw idea rather than a structured requirements document. It conducts a structured 7-section deep interview to surface scope, actors, business goals, constraints, and open questions before any formal artifact work begins.

### BABOK v3 — Elicitation & Collaboration
The brainstorm interview maps directly to BABOK v3's *Elicitation and Collaboration* knowledge area: structured questioning to draw out stakeholder needs, surface assumptions, and identify gaps before requirements are formally documented. The 7-section structure (Context, Actors, Goals, Scope, Constraints, Risks, Open Questions) mirrors BABOK's elicitation planning and preparation activities.
Source: IIBA, *BABOK Guide* v3, Chapter 4 — Elicitation and Collaboration.

### Jeff Patton — Story Mapping as Elicitation Input
The brainstorm output (actors + goals + scope boundaries) feeds directly into the backbone's preliminary story map (Step 5). Brainstorm is the upstream elicitation step that makes story mapping possible without a formal requirements document.
Source: *User Story Mapping*, Jeff Patton (O'Reilly, 2014).

### Output Contract
A brainstorm artifact (`docs/{feature}/brainstorms/{idea-slug}.md`) is the accepted upstream input for `/ba-start intake` when no formal requirements document exists. It carries the same traceability obligations as other upstream artifacts: open questions are tracked with `[ ]` markers and inherited by downstream skills.

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

## Reverse Mode / As-Built Documentation (`/ba-start reverse`)

### Purpose
Reverse mode reconstructs BA artifacts (FRD, user stories, SRS) from existing source code, deployed systems, or crawled web content — rather than deriving them from forward requirements. It is a first-class lane in BA-kit, not a workaround.

### IEEE 830 / ISO/IEC 29148 — As-Built Documentation Concept
IEEE 830 and ISO/IEC 29148 recognize that requirements documentation may be produced after implementation (as-built) to establish a verified baseline for maintenance, change management, and compliance audits. Reverse mode operationalizes this: the source code or deployed system is the ground truth; the BA artifacts describe what was built, not what was intended.
Source: IEEE Std 830-1998 §3.2; ISO/IEC/IEEE 29148:2018 §6.3 (requirements for existing systems).

### As-Built vs Future-State Separation (BA-kit proprietary)
Reverse artifacts must explicitly distinguish between:
- **As-built** — what the system currently does, derived from source/snapshot
- **Future-state** — what the system should do, derived from forward requirements

Mixing the two in a single artifact is a methodology violation. Reverse mode enforces this via the `reverse_lane` field and the Promotion Gate: an as-built artifact cannot be promoted to a forward-requirements artifact without explicit user approval and a documented delta.

### Snapshot Truth Principle (BA-kit proprietary)
Reverse mode reads from a point-in-time snapshot of the source, not from live system state. This ensures the as-built artifact is stable and auditable. The `reverse_baseline_lock` records the snapshot commit/timestamp; any drift between the snapshot and current source is surfaced by `reverse-drift-check.py` before re-running reverse commands.

### No-Broad-Read Rule (BA-kit proprietary)
Reverse mode must not read entire codebases speculatively. Discovery is index-first: read the reverse index, then targeted file sections. Broad reads require an explicit `READ_ESCALATION` with documented reason. This prevents token waste and keeps the as-built artifact scoped to verified evidence.

### Reverse-Web Pipeline (BA-kit proprietary)
When the source is a deployed web application rather than local code, the reverse-web pipeline applies:
- **Phase 1 — Crawl**: structured web crawl produces a raw content snapshot (pages, interactions, data flows)
- **Phase 2 — Synthesis**: the crawl output is processed by the reverse synthesis skill to produce structured BA artifacts

The same Snapshot Truth and As-Built vs Future-State rules apply. The crawl timestamp serves as the `reverse_baseline_lock`.

---

## Automated Quality Gate (`qc-uc-review`)

### Purpose
After any mutable command that produces or modifies Use Case specifications, the `qc-uc-review` gate fires automatically to validate artifact quality before the artifact is accepted. This prevents quality debt from accumulating across the lifecycle.

### 20-Point UC Quality Checklist (Wiegers/IIBA)
The gate's `full-10ka` profile applies the 20-point UC quality checklist derived from Wiegers/IIBA standards (see Step 6 — FRD above). Every UC is validated against: naming, scope, actor specificity, precondition verifiability, postcondition completeness, Normal Course structure, Alternative Course referencing, Exception completeness, and Special Requirements separation.
Source: *Software Requirements* 3rd ed., Karl Wiegers & Joy Beatty (Microsoft Press, 2013).

### Cross-Artifact Consistency (BA-kit proprietary)
The gate's `cross-artifact-consistency` profile checks that UC actor actions, system responses, and alternate flows are consistent with screen field behavior rules, user story acceptance criteria, and SRS screen descriptions. Inconsistency at this level is a methodology violation — the upstream artifact (user story > use case > screen > wireframe) is the source of truth.

### Gate Profiles

| Profile | When applied | Standards checked |
|---------|-------------|-------------------|
| `completeness-clarity-only` | After FRD UC draft | Wiegers 13-field completeness, Cockburn goal-level |
| `full-10ka` | After SRS UC finalization | Full 20-point checklist, INVEST, Gherkin AC |
| `cross-artifact-consistency` | After SRS assembly | UC ↔ screen ↔ story ↔ wireframe consistency |

### Automatic Firing Rule
The gate fires after every mutable command that touches UC artifacts. It cannot be skipped silently — a gate failure blocks the artifact from being marked `status: approved`. This enforces the quality standards in METHODOLOGY.md as a runtime constraint, not just a documentation guideline.

---

## Quality Standards (applied across all artifacts)

| Standard | Applied to | Source |
|----------|-----------|--------|
| BABOK v3 — Elicitation | Intake, Gap Analysis, Clarify | IIBA |
| PMI PMBOK 7th ed. — WBS (Mode A + Mode B) | Presale WBS | PMI |
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
| BABOK v3 — Elicitation (Brainstorm) | Pre-intake idea clarification | IIBA |
| IEEE 830 / ISO/IEC 29148 — As-Built | Reverse mode artifacts | IEEE / ISO |
| Snapshot Truth + As-Built Separation | Reverse mode, Reverse-Web | BA-kit proprietary |
| Automated QC Gate (20-point checklist) | UC artifacts post-mutable commands | Wiegers/IIBA + BA-kit proprietary |
