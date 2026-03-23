---
name: ba-requirements
description: Handles requirements elicitation, analysis, documentation, prioritization, and validation across BRD, FRD, SRS, and user story formats.
---

# BA Requirements

Use this skill to turn business intent into precise, testable requirements.

## Workflow
1. Confirm scope, goal, and audience.
2. Elicit requirements using interviews, workshops, or document review.
3. Normalize statements into clear business, functional, and non-functional requirements.
4. Add supporting structure for the chosen artifact: use cases, business rules, screen descriptions, Pencil wireframe references, and traceability where needed.
5. Prioritize with MoSCoW or WSJF.
6. Validate each requirement for SMART quality and ambiguity.
7. Package the result in the right document format.

## Deliverables
- Requirements list with IDs
- Use case specifications for critical interactions
- Screen descriptions for UI-backed scope
- Pencil `.pen` artifact references under `designs/` for screens that need wireframes
- Prioritized backlog or requirement set
- Traceability matrix
- Change log and open questions

## Templates
- Use [brd-template.md](../../templates/brd-template.md)
- Use [frd-template.md](../../templates/frd-template.md)
- Use [srs-template.md](../../templates/srs-template.md)
- Use [user-story-template.md](../../templates/user-story-template.md)
- Use [change-impact-template.md](../../templates/change-impact-template.md)

## Pencil Wireframes
- Use Pencil for low-fidelity screen wireframes referenced by the SRS
- Store `.pen` artifacts under `designs/[initiative-slug]/`
- Keep screen IDs aligned between the SRS and artifact filenames
- Reference the `.pen` path directly in each screen description

## Related Skills
- `ba-acceptance-criteria`
- `ba-user-stories`
- `ba-gap-analysis`
- `ba-compliance`

## Quality Check
- Every requirement has acceptance criteria
- Use cases cover primary and alternate flows for critical scope
- Screen descriptions capture fields, validations, and navigation where applicable
- UI-backed screens reference the correct Pencil `.pen` artifact when wireframes exist
- Each requirement has one interpretation
- Priorities are explicit and defensible
