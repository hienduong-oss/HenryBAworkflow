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

## Step 2 — Web research (conditional)

Use WebSearch when:
- Industry / domain is unfamiliar
- Specific regulation, standard, or vendor mentioned but undefined
- Competitor / market context required

**Do NOT** WebSearch generic BA topics. **No cross-project recall.**

Cite each web source inline `[src:web:<url> YYYY-MM-DD]` in the Domain Primer.

## Step 3 — Author Domain Primer

Read `templates/domain-primer-template.md` for structure. Write to `plans/{slug}-{date}/00_presale/00-domain-primer.md`.

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
