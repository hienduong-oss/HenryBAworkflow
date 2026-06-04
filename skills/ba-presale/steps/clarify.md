# BA Presale Step — Clarify

Phase 2 of the presale lifecycle. Owner: `presale-lead` (**Opus** for gap analysis + question synthesis).

## Checkpoint

Write `paths.presale_checkpoint` as the **first action**:
```
step: clarify
status: running
command: /ba-presale clarify
started: <ISO timestamp>
updated: <ISO timestamp>
```
On complete, update `status: completed` and `updated`.
Triggered by user command `/ba-presale clarify` (never auto-advances from domain-study).

This step requires:
- `paths.presale_domain_primer` (completed + user-reviewed)
- `00_inputs/` (all classes)
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
  1. Re-read Domain Primer + 00_inputs
  2. Run gap analysis across 8 BA categories (stakeholders, scope,
     success criteria, compliance, UI, process, tech, commercial)
  3. Synthesize 8–15 English clarifying questions
  4. Auto-suggest a best-guess answer for each (agent's inference)
  5. Enter interactive answer loop — inline edit / batch import / skip all

Output:   paths.presale_clarifications
Next gate: USER GATE — review questions + answers before /ba-presale build

Proceed? (reply 'ok' to start, or type a different command)
────────────────────────────────────────
```

Wait for `ok` before continuing.

## Step 1 — Re-read inputs

- Read `00-domain-primer.md` in full (all 8 sections, especially §5 Assumptions, §6 Risks, §7 Preliminary Open Questions).
- Domain Primer already synthesizes `00_inputs/`. Do NOT re-skim raw inputs unless a specific gap in Step 2 cannot be resolved from the Primer alone — in that case, open only the relevant file(s), not the full class.
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
- Every gap must trace to a fact (or absence) in Domain Primer / `00_inputs/`.
- If a category is already well-covered, fewer or no questions for it — do NOT pad.
- Target: **8–15 total questions** (not per-category; spread according to actual gaps).

## Step 3 — Synthesize question list

Write `paths.presale_clarifications` using `templates/clarifications-template.md`.

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
- **Suggested Answer** — agent's best-guess based on Domain Primer + inputs (never "N/A" — always offer something with a source ref)
- **Status** — see Assumed vs Answered rule below
- **Impact** — short note on what scope/WBS/proposal section this affects if answered differently
- **Notes** — free-form (dependency between questions, follow-up needed, etc.)

### Assumed vs Answered (CRITICAL distinction)

When populating `Suggested Answer` and `Status`:

- If answer comes from a **client document, email, meeting, or Q&A sheet** → `Status = Answered`, prefix = `**ANSWERED [src:...]:**`
- If answer comes from **ANY agent research** (SSH access, code reading, domain study, spec analysis, logical inference, domain primer synthesis) → `Status = Assumed`, prefix = `**ASSUMED [basis: <source>]:**`

**Never mark an item `Answered` unless a human stakeholder explicitly confirmed it.**
All `Assumed` items must state their basis so proposal/WBS authors know the confidence level.

Examples:
- `**ASSUMED [basis: SSH server access 2026-05-14]:** Zeus uses token-based API...`
- `**ASSUMED [basis: domain research, Metaps spec §3]:** Payment For uses link-based redirect...`
- `**ANSWERED [src:client:Q&A-sheet-2026-05-15]:** TCOS profile sync is OUT OF SCOPE.`

**Do NOT mark any question as "blocking" or "priority" — flat list.**

## Step 4 — State card

Write `paths.presale_state_cards/02-clarify.md` (≤300 tokens, Vietnamese):
- output: `05-clarifications.md`
- total question count + by-category breakdown
- count of questions whose suggested answer is agent-inferred (vs. grounded in inputs)
- next gate: USER GATE (answer loop)

## Step 5 — User Gate (MANDATORY) + Interactive answer loop

Print to user (Vietnamese summary + English next-step cues):

```
✅ Clarifying questions ready: paths.presale_clarifications

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
  • "/ba-presale build"    — sang phase build (không yêu cầu trả lời hết — proceed bất kỳ lúc nào)
```

### Loop behavior

- **Bare prompts** during this gate = surgical edits on `05-clarifications.md` only. Parse intent (answer / edit suggested / add / remove) and apply via Edit tool. After each edit, return 1-line confirm: `Q{n} updated. {X}/{N} answered.` Do NOT re-print the whole table unless user asks.
- **`/ba-presale build`** = advance gate. **No minimum answer threshold.** User can proceed at any time — the QnA list serves two purposes:
  1. Quick-answer/remove for the user's own clarity before build.
  2. Generate a table to send to the client (if project is not urgent).
  In many cases the user wants to build the proposal immediately without waiting for client answers. Unanswered questions are carried forward as assumptions in WBS/Proposal with `[src:assumption:A{n}]` refs.
- **"accept all suggestions"** = mass-update for `Status=Draft` rows only: copy `Suggested Answer` into the answer field and flip `Status → Assumed` (NOT `Answered` — agent-inferred answers remain Assumed until a human stakeholder explicitly confirms). `Status=Answered` rows are untouched. Warn user: "Đã accept {N} suggestions (Status=Assumed). Các câu này sẽ được carry forward là assumptions trong WBS/Proposal. Nếu bạn có xác nhận từ client, edit từng câu và đổi Status → Answered."

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

## Memory Capture

Clarify produces a question list — decisions are not locked until Build. Skip project memory promotion at this step.

Exception: if the user explicitly answers a question with a confirmed client fact (Status=Answered), and that fact is a material constraint (e.g., "client confirmed: no mobile app, web only"), capture it as a `project` memory entry with `Confidence: high` in the global memory system for use during Build.
