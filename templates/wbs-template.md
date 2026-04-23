<!--
TEMPLATE: WBS Content (markdown source of truth)
PURPOSE: Lightweight, edit-friendly WBS used during iteration. Rendered to xlsx via /ba-presale render.
STATUS: PLACEHOLDER — refine in Phase A.
LOCATION (per project): presale/{slug}-{date}/10-wbs-content.md
PAIRED WITH: 10-wbs-content.csv (CSV intermediate, token-cheap)
LANGUAGE: Vietnamese by default.

TRACEABILITY RULE (CRITICAL — see build-context §8.5):
- Mỗi work package PHẢI có cột "Source" trỏ về requirement gốc.
- Format: [src:client:<file>§<sec>] | [src:domain:§<n>] | [src:qna:Q<n>] | [src:assumption:A<n>]
- Không có Source -> KHÔNG được phép xuất hiện trong WBS final.
-->

# WBS — {{client_name}} / {{project_name}}

> **Trạng thái:** {{draft|reviewed|LOCKED}}
> **Phiên bản:** v{{X.Y}} — {{YYYY-MM-DD}}
> **Đơn vị effort:** Person-Day (PD)
> **Tổng effort:** {{auto-sum}} PD

---

## 1. Tổng quan phạm vi (Scope summary)
- **Mục tiêu dự án:** {{...}}  [src:domain:§1]
- **Phạm vi bao gồm (in-scope):** {{bullet list}}
- **Phạm vi loại trừ (out-of-scope):** {{bullet list — quan trọng cho commercial}}

## 2. WBS chi tiết (3 cấp mặc định)

| WBS ID | Work Package | Mô tả | Effort (PD) | Phụ thuộc | Phase | Owner | Source | Notes |
|--------|--------------|-------|-------------|-----------|-------|-------|--------|-------|
| 1 | **{{Phase 1 — Discovery}}** | | _sum_ | — | P1 | BA | [src:domain:§2] | |
| 1.1 | {{Workshop nghiệp vụ}} | {{...}} | {{X}} | — | P1 | BA | [src:client:RFP§2.1] | |
| 1.2 | {{Khảo sát hệ thống hiện hữu}} | {{...}} | {{X}} | 1.1 | P1 | BA+Tech | [src:client:tech-doc§3] | |
| 2 | **{{Phase 2 — Design}}** | | _sum_ | 1 | P2 | Tech Lead | [src:domain:§3] | |
| 2.1 | {{...}} | {{...}} | {{X}} | 1.2 | P2 | TL | [src:assumption:A2] | |
| 3 | **{{Phase 3 — Build}}** | | _sum_ | 2 | P3 | Dev | [src:client:RFP§4] | |
| 4 | **{{Phase 4 — Test & UAT}}** | | _sum_ | 3 | P4 | QA | [src:domain:§4] | |
| 5 | **{{Phase 5 — Deploy & Handover}}** | | _sum_ | 4 | P5 | DevOps | [src:assumption:A5] | |

## 3. Tổng hợp theo phase

| Phase | Effort (PD) | % | Ghi chú |
|-------|-------------|---|---------|
| P1 — Discovery | {{...}} | {{%}} | |
| P2 — Design | {{...}} | {{%}} | |
| P3 — Build | {{...}} | {{%}} | |
| P4 — Test & UAT | {{...}} | {{%}} | |
| P5 — Deploy & Handover | {{...}} | {{%}} | |
| **Total** | **{{sum}}** | 100% | |

## 4. Giả định ảnh hưởng đến estimate
- **A1:** {{...}} — nếu không đúng, effort tăng ~{{X}} PD ở WBS {{1.2, 2.1}}
- **A2:** {{...}}

## 5. Loại trừ (Exclusions)
- {{Item}} — lý do: {{...}}
- {{Item}} — lý do: {{...}}

## 6. Phụ thuộc bên ngoài
- {{Bên thứ 3 / khách hàng cần cung cấp X trước Y ngày}}

---

<!-- RENDER HINT:
Khi render qua document-skills:xlsx, sheet "WBS" dùng style spec WBS, sheet "Summary" dùng từ §3,
sheet "Assumptions" dùng từ §4. Sheet "QnA" lấy từ 30-qna-content.md (file riêng).
-->
