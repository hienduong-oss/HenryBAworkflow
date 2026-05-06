# Research Brief Template

> Dùng cho presale Phase 1 (Domain Study) và on-demand research trigger.
> presale-lead (Opus) fill vào project-specific context trước khi dispatch sang ba-researcher.

---

## Project Context

- **Industry:** {industry}
- **Problem statement:** {1-line summary of the core business problem}
- **Geography/Market:** {target market, jurisdiction}
- **Regulatory environment:** {relevant regulations, compliance requirements}
- **Stakeholders:** {key actors mentioned in inputs}

---

## Research Objectives (Prioritized)

### [MUST] — Critical for Domain Primer synthesis
- {specific question 1}
- {specific question 2}

### [SHOULD] — Important but not blocking
- {specific question 3}
- {specific question 4}

### [NICE-TO-HAVE] — Enrichment only
- {specific question 5}

---

## Specific Search Areas

### Primary (MUST + SHOULD)
- {specific topic A}
- {specific topic B}

### Secondary (NICE-TO-HAVE)
- {specific topic C}

---

## Exclusions

**Do NOT research these areas:**
- {topic to exclude} — Why: {reason}
- {topic to exclude} — Why: {reason}

---

## Quality Criteria

ba-researcher must return:

1. **Findings** — Factual statements with inline citations `[src:web:<url> YYYY-MM-DD]`
2. **Source list** — Each source with credibility assessment (authoritative / trade publication / general / unverified)
3. **Open questions** — Items that need client validation or further research
4. **Risk flags** — Early risks identified from research
5. **Terminology** — Domain-specific terms with definitions for BA-kit glossary

---

## Output Format

Return as structured markdown:

```markdown
## Research Findings — {project_name}

### 1. Industry Overview
{facts with inline citations}

### 2. Key Players & Market Context
{facts with inline citations}

### 3. Regulatory & Compliance
{facts with inline citations}

### 4. Competitor/Vendor Analysis
{facts with inline citations}

### 5. Domain Terminology
{term: definition pairs}

## Source List
| Source | Credibility | Date |
|--------|-------------|------|
| [url] | {level} | YYYY-MM-DD |

## Open Questions
1. {question}

## Risk Flags
- {early risk}

## Terminology Glossary
| Term | Definition |
|------|------------|
| {term} | {definition} |
```

---

## Language

- **Research output:** English (technical)
- **Inline citations:** `[src:web:<url> YYYY-MM-DD]`
- **ba-researcher summary to lead:** ≤ 50 tokens
- **Full output:** written to disk at agreed path

---

## Notes for ba-researcher

- Prioritize authoritative sources (official standards body, regulatory agency, established analyst firm)
- Do NOT mix assumptions with facts — flag assumptions clearly
- If search yields no authoritative sources for a MUST item, report this as a risk flag
- Terminology section should capture terms that appear differently in client docs vs industry standard
