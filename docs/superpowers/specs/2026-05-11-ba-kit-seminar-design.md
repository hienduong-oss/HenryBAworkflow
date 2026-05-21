# Design Spec: 1-Hour BA-kit Credibility Seminar

## 1. Design Summary

This seminar should not present BA-kit as "a cool AI tool demo."

It should present a credible BA method first, then use BA-kit outputs as proof that the method can be executed in a structured, repeatable way with AI.

The goal is to build trust with:

- future or junior BAs who need a clear working model
- practicing IT BAs or PMs who need evidence of rigor, not prompt tricks

The seminar is capped at 1 hour, so a full live walkthrough of BA-kit is not the center of the session.

## 2. Audience And Conversion Goal

Primary audience:

- future or junior BAs
- working IT BAs or PMs

Primary conversion goal:

- build credibility first
- soft-sell an IT BA course using AI as the logical next step

The audience should leave believing:

- the speaker understands real BA work
- AI can support BA work only when the process is structured
- the course teaches the method behind the outputs, not just tool usage

## 3. Recommended Positioning

Recommended seminar title:

`Ứng dụng AI trong phân tích nghiệp vụ IT: Từ yêu cầu thô đến tài liệu bàn giao có thể sử dụng`

Core message:

- BA-kit is evidence
- the method is the product
- the course is the path to learn that method properly

Position BA-kit as:

- a BA workstation
- a structured lifecycle from intake to handoff
- a way to make BA work more consistent, traceable, and stakeholder-ready

Do not position BA-kit as:

- a replacement for BA thinking
- a generic AI prompting shortcut
- a long live-demo centerpiece

## 4. Recommended Session Structure

Target duration:

- 50 to 60 minutes total

Recommended time split:

1. BA pain in real projects - 5 minutes
2. What good BA work should produce - 5 minutes
3. A practical BA workflow AI should support - 10 minutes
4. How BA-kit operationalizes that workflow - 10 minutes
5. Mini proof walkthrough using real outputs - 10 to 15 minutes
6. What BA capability still matters in the AI era - 10 minutes
7. Course close and CTA - 5 minutes

This structure teaches first, proves second, sells last.

## 5. BA-kit Evidence Strategy

Use BA-kit as proof, not as the full content of the seminar.

Recommended evidence set:

- `PROJECT-HOME.md` to show guided workflow and project state
- `backbone.md` to show scope lock and single source of truth
- one downstream artifact such as `user-stories.md` or `srs.md` to show traceable output quality

If visuals are needed, use screenshots or prepared excerpts of actual BA-kit output.

Avoid:

- a full cold live run from raw input to final package
- deep command walkthroughs
- explaining repo internals, agent roles, or installation details to this audience

Reason:

- full demos consume too much time
- live runs increase risk
- credibility comes from structured outputs and clear reasoning, not from runtime novelty

## 6. Slide Outline

Deck should use formal Vietnamese on slides.

Allowed English terms only where they are already standard or hard to replace cleanly:

- BA
- AI
- IT
- `PROJECT-HOME.md`
- `backbone.md`
- `SRS`

Recommended 12-slide deck with detailed direction:

### Slide 1 - `BA trong thời đại AI: Từ yêu cầu thô đến tài liệu bàn giao có thể sử dụng`

Main purpose:

- establish the promise of the seminar
- frame the session as a practical BA discussion, not a tool show

On-slide content:

- title
- subtitle: `Một phương pháp làm BA có cấu trúc, có thể áp dụng cùng AI`
- speaker name and role
- one-line promise: `Sau buổi này, anh/chị sẽ thấy rõ AI chỉ tạo ra giá trị khi BA có phương pháp đúng`

Suggested visual:

- clean hero visual showing a flow from `yêu cầu thô` to `tài liệu bàn giao`
- either a simple horizontal process diagram or a polished document transformation visual

Speaker notes:

- open by setting expectation that this is not a buổi giới thiệu công cụ đơn thuần
- state that the session is about how BA can keep rigor while using AI
- explain that a real tool will appear later only as evidence for the method

### Slide 2 - `Vì sao công việc BA thường bị đứt gãy trong dự án thực tế`

Main purpose:

- make the audience agree with the problem before introducing the method

On-slide content:

- 4 to 5 failure patterns:
- `Đầu vào mơ hồ, nhiều nguồn, khó xác định phạm vi`
- `Tài liệu không thống nhất giữa các giai đoạn`
- `Thiếu truy vết từ nhu cầu đến giải pháp và kiểm thử`
- `BA mất nhiều thời gian viết lại cùng một loại tài liệu`
- `Khi dùng AI tự do, đầu ra nhanh nhưng thiếu kiểm soát chất lượng`

Suggested visual:

- a broken workflow diagram with red breakpoints between requirement, analysis, documentation, and handoff
- or a cluttered desk/document collage representing fragmented BA work

Speaker notes:

- speak from project reality, not theory
- mention that many teams do have templates and tools, but still lack a stable operating method
- connect the problem directly to audience pain: rework, misunderstandings, slow handoff, and stakeholder mistrust

### Slide 3 - `Các bên liên quan thực sự cần gì từ một BA`

Main purpose:

- shift the focus from "BA writes documents" to "BA creates decision quality"

On-slide content:

- 4 stakeholder expectations:
- `Hiểu đúng vấn đề kinh doanh`
- `Khóa phạm vi đủ rõ trước khi đi sâu`
- `Tạo tài liệu có thể bàn giao cho đội triển khai`
- `Giữ được truy vết giữa yêu cầu, giải pháp và kiểm thử`

- closing line:
- `Giá trị của BA không nằm ở số lượng tài liệu, mà nằm ở độ rõ ràng và khả năng bàn giao`

Suggested visual:

- one central BA node connected to business, product, engineering, and testing
- each connection labeled with an expected outcome

Speaker notes:

- emphasize that stakeholders do not pay for document volume
- they pay for clarity, reduced risk, and smoother execution
- this creates the bridge to the workflow slide that follows

### Slide 4 - `Một quy trình BA đơn giản nhưng đủ chặt chẽ`

Main purpose:

- teach the core method the course will later sell

On-slide content:

- 4-step flow:
- `Tiếp nhận và chuẩn hóa đầu vào`
- `Khóa phạm vi và tạo nguồn sự thật thống nhất`
- `Sinh các tài liệu phù hợp với mục tiêu bàn giao`
- `Bàn giao, rà soát, và cập nhật theo phản hồi`

- under the flow, add examples:
- `Đầu vào: brief, ghi chú họp, tài liệu yêu cầu`
- `Nguồn sự thật: backbone`
- `Tài liệu: user stories, FRD, SRS, đặc tả màn hình`

Suggested visual:

- a clean left-to-right workflow with four stages
- each stage should have one icon and one short label

Speaker notes:

- spend time here because this is the intellectual core of the seminar
- explain that AI should support this sequence, not replace it
- mention that most AI disappointment comes from skipping the scope-lock step

### Slide 5 - `Vì sao AI thường thất bại khi không có cấu trúc BA`

Main purpose:

- explain why prompting alone is insufficient

On-slide content:

- two-column comparison:
- left column `Dùng AI không có phương pháp`
- right column `Dùng AI trong quy trình BA có cấu trúc`

- comparison points:
- `Đầu vào`
- `Cách ra quyết định`
- `Độ ổn định của tài liệu`
- `Khả năng truy vết`
- `Mức độ tin cậy khi bàn giao`

Suggested visual:

- side-by-side comparison table
- optional subtle color coding: left weaker, right stronger

Speaker notes:

- this slide is important for credibility with experienced attendees
- avoid saying AI is bad; say uncontrolled usage creates weak outputs
- the goal is to position method as the multiplier of AI value

### Slide 6 - `BA-kit là gì và vai trò của nó trong quy trình này`

Main purpose:

- introduce BA-kit without turning the session into a product pitch

On-slide content:

- definition:
- `BA-kit là một bộ công cụ giúp vận hành quy trình BA có cấu trúc cùng AI`

- 3 supporting points:
- `Chuẩn hóa vòng đời làm BA từ đầu vào đến bàn giao`
- `Tạo ra các tài liệu theo logic nhất quán`
- `Giữ được trạng thái dự án, phạm vi, và bước tiếp theo`

- boundary statement:
- `BA-kit không thay thế tư duy BA; BA-kit giúp tư duy BA được vận hành nhất quán`

Suggested visual:

- one centered box `BA-kit` placed over the workflow from slide 4
- arrows showing BA-kit supporting each step

Speaker notes:

- keep this short and controlled
- do not explain installation, command surface, or internal architecture
- position BA-kit as an operating layer for BA work with AI

### Slide 7 - `Ví dụ đầu ra 1: Bảng điều phối công việc BA`

Main purpose:

- show that the process is navigable and not dependent on remembering prompts

On-slide content:

- slide title in Vietnamese
- mention the artifact by name: `PROJECT-HOME.md`
- 3 things the audience should notice:
- `Dự án đang ở trạng thái nào`
- `Bước tiếp theo là gì`
- `Những câu hỏi nào còn cần chốt`

- one bottom-line sentence:
- `Điểm mạnh ở đây là khả năng điều hướng công việc, không chỉ là khả năng sinh tài liệu`

Suggested visual:

- screenshot of a real or sanitized `PROJECT-HOME.md`
- highlight 3 areas with callout boxes:
- current status
- next step
- open questions

Speaker notes:

- tell the audience this is one of the strongest signals of maturity
- many AI workflows can generate text, but few can preserve working state cleanly
- explain why this matters for solo BA and for collaboration

### Slide 8 - `Ví dụ đầu ra 2: Tài liệu khóa phạm vi và nguồn sự thật thống nhất`

Main purpose:

- demonstrate rigor and source-of-truth discipline

On-slide content:

- artifact name: `backbone.md`
- 3 concepts to explain:
- `Phạm vi đã được chốt như thế nào`
- `Giả định và khoảng trống được ghi nhận ra sao`
- `Vì sao tài liệu này trở thành nền tảng cho các tài liệu phía sau`

- closing line:
- `Nếu không có bước này, AI chỉ đang viết nhanh hơn chứ không phân tích tốt hơn`

Suggested visual:

- screenshot or formatted excerpt of a real `backbone.md`
- highlight sections such as scope, assumptions, decisions, and unresolved items

Speaker notes:

- this is where you establish serious BA credibility
- explain that a controlled source of truth reduces downstream inconsistency
- connect to stakeholder trust and reduced rework

### Slide 9 - `Ví dụ đầu ra 3: Từ phạm vi đến tài liệu có thể bàn giao`

Main purpose:

- prove that structured upstream thinking leads to usable downstream outputs

On-slide content:

- choose one artifact only for focus:
- option A `user stories`
- option B `SRS`

- recommended choice for this audience:
- `user stories` if the room is more beginner-heavy
- `SRS` if the room is more practitioner-heavy

- show 3 quality signals:
- `Có logic xuất phát từ phạm vi đã khóa`
- `Có mức độ chi tiết phù hợp cho bàn giao`
- `Có thể dùng để trao đổi với đội triển khai hoặc kiểm thử`

Suggested visual:

- screenshot of a real artifact excerpt
- use annotation boxes to point at acceptance criteria, functional detail, or traceability cues

Speaker notes:

- do not overwhelm with too much text
- explain what makes the output usable, not merely well-formatted
- if needed, briefly compare this with a generic AI-generated document to make the difference obvious

### Slide 10 - `Những gì ví dụ này thực sự chứng minh`

Main purpose:

- translate the artifact examples into business credibility

On-slide content:

- 4 proof points:
- `AI có thể hỗ trợ BA nhanh hơn`
- `Nhưng chất lượng chỉ ổn định khi quy trình được thiết kế đúng`
- `Đầu ra có thể nhất quán giữa các giai đoạn`
- `BA vẫn là người chịu trách nhiệm về tư duy và quyết định`

Suggested visual:

- a simple synthesis diagram linking `Phương pháp` + `AI` + `Công cụ` -> `Đầu ra đáng tin cậy`

Speaker notes:

- this slide prevents the audience from remembering only the screenshots
- restate that the seminar is about operating model credibility
- make the lesson explicit: tool value comes from method discipline

### Slide 11 - `Trong thời đại AI, BA cần học gì để không bị thay thế`

Main purpose:

- create demand for the course without pitching too early

On-slide content:

- 4 capability areas:
- `Tư duy phân tích và làm rõ yêu cầu`
- `Khả năng khóa phạm vi và quản lý quyết định`
- `Khả năng tạo tài liệu có thể bàn giao`
- `Khả năng sử dụng AI như một công cụ có kiểm soát`

- one closing sentence:
- `Người bị thay thế không phải là BA dùng ít AI, mà là BA dùng AI nhưng thiếu phương pháp`

Suggested visual:

- four-pillar capability model
- each pillar labeled with one competency area

Speaker notes:

- this is the transition slide into the upsell
- keep the tone educational, not threatening
- emphasize augmentation and professional maturity

### Slide 12 - `Lộ trình tiếp theo nếu anh/chị muốn học bài bản`

Main purpose:

- close with a soft but direct invitation

On-slide content:

- 3 course promise lines:
- `Hiểu cách tư duy như một IT BA thực thụ`
- `Biết cách chuyển đầu vào mơ hồ thành bộ tài liệu rõ ràng`
- `Biết cách dùng AI để tăng tốc mà vẫn giữ chất lượng`

- CTA:
- `Nếu anh/chị muốn học phương pháp phía sau các đầu ra vừa xem, đó chính là nội dung của khóa học`

- optional footer:
- registration channel, QR code, or contact point

Suggested visual:

- clean closing slide
- optional QR code
- optional course structure preview card

Speaker notes:

- keep this short, calm, and credible
- do not hard-sell
- link the invitation back to the actual pain points from slide 2
- close by offering the course as the structured path to learn the method, not just the tool

## 7. Visual Design Guidance For The Deck

Overall style:

- formal
- business-facing
- clean and structured
- closer to consulting presentation than startup product pitch

Typography direction:

- use a clear Vietnamese-friendly font
- avoid playful or overly decorative type
- keep hierarchy obvious between title, key point, and evidence

Color direction:

- use restrained corporate tones such as dark blue, slate, muted teal, or neutral gray
- use one accent color for emphasis only
- avoid overly bright demo-style gradients

Image rules:

- use screenshots of real BA-kit outputs when possible
- crop tightly and annotate intentionally
- every screenshot must support one message only

Layout rules:

- avoid text-heavy slides
- one core idea per slide
- when a screenshot appears, reduce text and let annotations carry the explanation

## 8. Speaker Guidance

Tone:

- practical
- method-first
- not overhyped

Messaging rules:

- teach a reusable BA way of thinking
- use BA-kit to validate that the method can be operationalized
- keep "AI" attached to process quality, not magic

Useful line of argument:

- bad input plus loose prompting creates weak BA output
- structured intake and backbone thinking create better output
- BA-kit is credible because it enforces that structure

## 9. Course Upsell Logic

The course offer should feel like the natural continuation of the seminar.

The seminar proves:

- what good BA work looks like
- how AI can accelerate it responsibly
- why prompting alone is insufficient

The course should then promise:

- how to think like an IT BA
- how to turn messy requirements into structured artifacts
- how to use AI tools without losing rigor

The CTA should be soft:

- "If you want to learn the method behind these outputs, that is what the course covers."

## 10. Constraints And Risks

Constraints:

- maximum 1 hour
- mixed audience from beginner to practitioner
- no direct hard-sell framing

Risks:

- too much demo reduces teaching value
- too much theory makes BA-kit feel unproven
- too much product talk weakens credibility

Mitigation:

- show only 3 concrete BA-kit outputs
- keep the workflow visual simple
- reserve the last 5 minutes for the course pitch

## 11. Success Criteria

The seminar succeeds if attendees can clearly say:

- "I understand the BA workflow better now."
- "This speaker has a serious BA method, not just AI tricks."
- "The tool outputs look practical and usable."
- "The course seems worth considering if I want to learn this properly."
