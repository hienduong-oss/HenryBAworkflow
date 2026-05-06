# BA Presale Step — Domain Study

Phase 1 of the presale lifecycle. Owner: `presale-lead` (**Opus** for synthesis). Auto-runs after `steps/bootstrap.md`.

This step requires:
- Bootstrap completed (`00-inputs/` populated or `_initial-prompt.md` captured)
- `templates/domain-primer-template.md`
- `rules/ba-presale-standards.md` §1

## Scope

Synthesize a Domain Primer framing the project domain, business context, and research findings. Stop at USER GATE for review. User may prompt freely to probe findings before advancing.

## Step 1 — Read inputs

All inputs under `plans/{slug}-{date}/00_presale/00-inputs/`:
- Read all `requirements/*` in full.
- Skim `discussions/*` — extract decisions and stakeholder signals.
- Skim `technical/*` — capture integration & constraint signals only.
- Read `references/*` only when explicitly relevant.

## Step 2 — Research Brief Creation

### 2a. [JUDGMENT — Opus] Create project-specific research brief

presale-lead creates a tailored research brief by:
1. Reading all inputs under `00-inputs/` to understand project context
2. Identifying industry, problem statement, geography, stakeholders
3. Extracting research objectives from Domain Primer template
4. Filling `templates/research-brief-template.md` with project-specific context
5. Setting MUST/SHOULD/NICE-TO-HAVE priorities based on domain scope

Output: filled `research-brief.md` in `plans/{slug}-{date}/00_presale/_research/`

### 2b. [MECHANICAL — Bash] Prepare delegation packet

```bash
mkdir -p "plans/{slug}-{date}/00_presale/_research"
cp "templates/research-brief-template.md" "plans/{slug}-{date}/00_presale/_research/research-brief.md"
```

### 2c. [JUDGMENT — Sonnet] Execute research

**Dispatch ba-researcher** with:
- Filled research brief from `plans/{slug}-{date}/00_presale/_research/research-brief.md`
- Research objectives: produce findings + source list + open questions + risk flags + terminology glossary

ba-researcher must return:
1. Structured findings per output format in template
2. Inline citations `[src:web:<url> YYYY-MM-DD]` for every factual claim
3. Credibility-assessed source list
4. Open questions for follow-up
5. Early risk flags if applicable

**Do NOT** skip research because the domain "seems familiar." **No cross-project recall.**

If ba-researcher is unavailable, fall back to inline WebSearch with the same coverage requirements.

## Step 3 — Author Domain Primer

Read `templates/domain-primer-template.md` for structure. Write to `plans/{slug}-{date}/00_presale/00-domain-primer.md` using:
- Step 2 research brief as primary input
- All inputs under `00-inputs/` as secondary context

Language: **Vietnamese** (this artifact is for internal BA use).

Language: **Vietnamese** (this artifact is for internal BA use).

Required sections (per template):
1. Khách hàng & Bối cảnh
2. Bài toán & Nhu cầu lõi
3. Domain Knowledge tóm lược
4. Bối cảnh kỹ thuật
5. Giả định & Ràng buộc
6. Rủi ro sớm
7. Câu hỏi mở (preliminary — full list generated in `/ba-presale clarify`)
8. Nguồn tham chiếu

Concise. No marketing fluff. Every non-trivial claim carries an inline source ref.

## Step 4 — State card

Write `plans/{slug}-{date}/00_presale/_state-cards/01-domain-study.md` (≤300 tokens, Vietnamese):
- output: `00-domain-primer.md`
- key assumptions count
- early risks count
- preliminary open questions count
- next gate: USER GATE

## Step 5 — User Gate (MANDATORY)

Print to user (Vietnamese summary + English next-step cues):

```
✅ Domain Primer sẵn sàng: plans/{slug}-{date}/00_presale/00-domain-primer.md

Tóm tắt nhanh (tiếng Việt):
  - Khách hàng: {client_name}
  - Bài toán lõi: {1-line problem}
  - Domain: {industry}
  - Giả định chính: {N}
  - Rủi ro sớm: {N}
  - Nguồn web tham khảo: {N}

Hãy review. Bạn có thể:
  • Hỏi về research/findings → tôi giải thích + update primer nếu cần
  • "edit §{n}: <change>" → sửa cụ thể một section
  • "/ba-presale clarify" → tiếp sang gap analysis + clarifying questions
```

**Do NOT** auto-advance under any circumstance. User must explicitly type `/ba-presale clarify`.

Interactive loop during this gate:
- Bare prompts = user asking/probing findings → answer in Vietnamese, update primer when user requests change, never advance.
- `/ba-presale clarify` = advance to next phase.

## Forbidden

- Skipping the user gate.
- Cross-project recall ("in past project X we did Y").
- Inventing facts not present in `00-inputs/` or cited via WebSearch.
- Writing Domain Primer in English (unless user explicitly overrides language).
