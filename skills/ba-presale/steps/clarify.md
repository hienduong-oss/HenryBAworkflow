# BA Presale Step — Clarify

Phase 2 of the presale lifecycle. Owner: `presale-lead` (**Opus** for gap analysis + question synthesis).

Triggered by user command `/ba-presale clarify` (never auto-advances from domain-study).

This step requires:
- `plans/{slug}-{date}/00_presale/00-domain-primer.md` (completed + user-reviewed)
- `00-inputs/` (all classes)
- `templates/clarifications-template.md`
- `rules/ba-presale-standards.md` §1, §5

## Scope

Run gap analysis across 8 BA categories, synthesize 8–15 English clarifying questions with agent-suggested best-guess answers, then enter interactive answer loop. Stop at USER GATE. Output is a single `.md` artifact (table format, English content) — no xlsx render at this phase.

## Pre-run description block (MANDATORY)

Before touching the filesystem, print this block in English (short, concise):

```
────────────────────────────────────────
🔵 /ba-presale clarify — Gap Analysis + Clarifying Questions
────────────────────────────────────────
Phase 2 — Identify gaps and produce answerable question list.

Will:
  1. Re-read Domain Primer + 00-inputs
  2. Run gap analysis across 8 BA categories (stakeholders, scope,
     success criteria, compliance, UI, process, tech, commercial)
  3. Synthesize 8–15 English clarifying questions
  4. Auto-suggest a best-guess answer for each (agent's inference)
  5. Enter interactive answer loop — inline edit / batch import / skip all

Output:   plans/{slug}-{date}/00_presale/05-clarifications.md
Next gate: USER GATE — review questions + answers before /ba-presale build

Proceed? (reply 'ok' to start, or type a different command)
────────────────────────────────────────
```

Wait for `ok` before continuing.

## Step 1 — Re-read inputs

- Read `00-domain-primer.md` in full (all 8 sections, especially §5 Assumptions, §6 Risks, §7 Preliminary Open Questions).
- Re-skim `00-inputs/requirements/*`, `00-inputs/discussions/*`, `00-inputs/technical/*`.
- Do NOT re-run WebSearch unless a new external fact is genuinely required.

## Step 2 — Gap analysis across 8 BA categories

For each category, list what is **known**, **inferred**, **missing**. Keep this internal (do not write to artifact yet — synthesize into questions in Step 3).

| # | Category | What to probe |
|---|----------|---------------|
| 1 | Stakeholders | Decision makers, signers, sponsors, end-users, support roles |
| 2 | Scope | In-scope boundaries, out-of-scope items, MVP vs. future phases |
| 3 | Success Criteria | Measurable business outcomes, KPIs, adoption targets |
| 4 | Compliance & Legal | Regulations, data residency, privacy, audit, certifications |
| 5 | UI / UX | Platforms, device targets, branding, accessibility, i18n |
| 6 | Business Process | Current state flow, desired state flow, exceptions, volume |
| 7 | Technical / Integration | External systems, auth, APIs, data migration, infra constraints |
| 8 | Commercial | Budget range, timeline anchor, payment model, engagement type |

Rules:
- Every gap must trace to a fact (or absence) in Domain Primer / `00-inputs/`.
- If a category is already well-covered, fewer or no questions for it — do NOT pad.
- Target: **8–15 total questions** (not per-category; spread according to actual gaps).

## Step 3 — Synthesize question list

Write `plans/{slug}-{date}/00_presale/05-clarifications.md` using `templates/clarifications-template.md`.

Language: **English** (artifact is intended for client review).

Required structure:
1. Header: client, project, version, status (draft)
2. Main table with columns: `ID | Category | Question | Suggested Answer | Status | Impact | Notes`
3. Category legend
4. Status legend (`Draft | Answered | Skipped`)
5. Impact map (which questions affect scope / effort / timeline)

Rules per row:
- **ID** — Q1, Q2, …
- **Category** — one of the 8 categories above
- **Question** — single-intent, English, no bundled asks
- **Suggested Answer** — agent's best-guess based on Domain Primer + inputs (never "N/A" — always offer something with a source ref like `[src:domain:§3]` or `[src:assumption:A1]`)
- **Status** — `Draft` (default)
- **Impact** — short note on what scope/WBS/proposal section this affects if answered differently
- **Notes** — free-form (dependency between questions, follow-up needed, etc.)

**Do NOT mark any question as "blocking" or "priority" — flat list.**

## Step 4 — State card

Write `plans/{slug}-{date}/00_presale/_state-cards/02-clarify.md` (≤300 tokens, Vietnamese):
- output: `05-clarifications.md`
- total question count + by-category breakdown
- count of questions whose suggested answer is agent-inferred (vs. grounded in inputs)
- next gate: USER GATE (answer loop)

## Step 5 — User Gate (MANDATORY) + Interactive answer loop

Print to user (Vietnamese summary + English next-step cues):

```
✅ Clarifying questions ready: plans/{slug}-{date}/00_presale/05-clarifications.md

Tóm tắt (tiếng Việt):
  - Tổng số câu hỏi: {N}
  - Phân loại:   Stakeholders={a}, Scope={b}, Success={c}, Compliance={d},
                 UI={e}, Process={f}, Tech={g}, Commercial={h}
  - Agent đã tự suggest answer cho mọi câu hỏi (dựa trên Domain Primer + inputs).

Bạn có 3 cách trả lời:
  • Inline  — trả lời từng câu:  "Q3: <your answer>"  hoặc  "edit Q5 suggested: <rewrite>"
  • Batch   — dán file trả lời:  "import answers: <paste multiline Q1: ... Q2: ...>"
  • Skip    — chấp nhận toàn bộ suggested answers: "accept all suggestions"
  • Hỗn hợp — kết hợp các cách trên tuỳ ý

Các lệnh khác:
  • "review Q{n}"          — xem chi tiết câu hỏi, nguồn suy luận
  • "add question: ..."    — bổ sung câu mới (agent gán ID + suggest)
  • "remove Q{n}"          — xoá câu không còn phù hợp
  • "/ba-presale build"    — sang phase build WBS + Proposal (cần ít nhất 80% câu trả lời)
```

### Loop behavior

- **Bare prompts** during this gate = surgical edits on `05-clarifications.md` only. Parse intent (answer / edit suggested / add / remove) and apply via Edit tool. After each edit, return 1-line confirm: `Q{n} updated. {X}/{N} answered.` Do NOT re-print the whole table unless user asks.
- **`/ba-presale build`** = advance gate. Pre-check: ≥80% of questions must have `Status=Answered`. If not, print blocker:
  ```
  ⚠️ Cannot advance: {answered}/{N} questions answered ({pct}%). Need ≥80%.
     Unanswered: Q{a}, Q{b}, Q{c}
     Trả lời tiếp hoặc dùng "accept all suggestions" để chấp nhận suggested answer.
  ```
- **"accept all suggestions"** = mass-update: copy every row's `Suggested Answer` into `Answered Answer` cell (add column if template uses separate cell; otherwise just flip Status→Answered with suggestion intact). Warn user: "Đã accept {N} suggestions. Bạn có thể review lại và edit từng câu bất cứ lúc nào trước khi build."

## Step 6 — Version bump on answer cycles

Each time user enters "accept all" or completes a batch round:
- Bump version in artifact header (v0.1 → v0.2 → …)
- Append one line to `_changelog/clarify-{YYYYMMDD-HHmm}.md`:
  ```
  {timestamp} - answered {N} questions (mode: inline|batch|accept-all)
  ```

## Forbidden

- Skipping the gap analysis (jumping straight to questions without category coverage).
- Padding to hit question count — if only 5 genuine gaps, return 5 (but state why count is low).
- Marking any question as "blocking" / "priority" / using severity flags.
- Writing the artifact in Vietnamese (client-facing → English).
- Rendering xlsx at this phase (render happens only during `/ba-presale build`).
- Auto-advancing to build without user command.
- Cross-project recall.
