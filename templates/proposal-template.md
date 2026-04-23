<!--
TEMPLATE: Proposal Content (markdown source of truth) — v4.0 aligned
PURPOSE: Structural template for proposal-writer agent. Rendered to docx via /ba-presale render.
LOCATION (per project): presale/{slug}-{date}/20-proposal-content.md
LANGUAGE: Vietnamese by default.
GUIDE: See templates/proposal-guide.md for depth, styling rules, tone, and pitfalls.
VARIANTS: Template includes both Variant A (Platform/Integration) and Variant B (Custom-Build).
          proposal-writer selects the appropriate variant per delegation packet.

TRACEABILITY RULE (CRITICAL — see rules/ba-presale-standards.md §5):
- Moi commitment (deliverable, timeline, exclusion) PHAI co source ref inline.
- Format: [src:client:<file>§<sec>] | [src:wbs:<id>] | [src:domain:§<n>] | [src:qna:Q<n>] | [src:assumption:A<n>]
- WBS sections phai dong bo voi 10-wbs-content.md (sync-check o phase 4).
-->

# Proposal — {{project_name}}

> **Khach hang:** {{client_name}}
> **Phien ban:** v{{X.Y}} — {{YYYY-MM-DD}}
> **Trang thai:** {{draft|reviewed|LOCKED}}
> **Variant:** {{A_platform|B_custom}}

---

## Cover (rendered as cover page)

- **Loai tai lieu:** Project Proposal
- **Tieu de:** {{project_name}}
- **Phu de:** {{project_subtitle}}  _(optional)_
- **Khach hang:** {{client_name}}
- **Phien ban:** v{{X.Y}}
- **Nguoi soan:** {{author}}
- **Phe duyet boi:** {{approver}}
- **Ngay:** {{DD/MM/YYYY}}
- **Dia diem:** {{city}}
- **Cong ty:** SotaTek JSC — {{address}}

## Document Control

### Edit History

| Ngay | Phien ban | Mo ta | Nguoi soan |
|------|-----------|-------|------------|
| {{DD/MM/YYYY}} | v1.0 | Tao proposal ban dau | {{editor}} |

### Phe duyet

| Ngay phe duyet | Phien ban | Phe duyet boi | Chuc vu |
|----------------|-----------|---------------|---------|
| {{DD/MM/YYYY}} | v{{X.Y}} | {{approver}} | {{position}} |

---

## 1. Tong quan du an (Project Overview)

### 1.1 Boi canh kinh doanh (Business Context)

{{1-2 doan: vi tri thi truong cua khach hang, boi canh chien luoc}}
[src:client:RFP§1] [src:domain:§1]

{{Mo ta pain/gap hien tai bang ngon ngu kinh doanh, khong dung jargon ky thuat}}

#### Thach thuc chinh (Key Challenges)

- {{Thach thuc 1}} [src:client:RFP§2]
- {{Thach thuc 2}} [src:domain:§3]
- {{Thach thuc 3 + yeu cau phap ly neu co}} [src:client:RFP§3]

### 1.2 Tong quan giai phap SotaTek (Solution Overview)

{{1 doan tom tat giai phap end-to-end}}
[src:domain:§2]

<!-- Variant A (Platform): -->
- **Licensing & Subscription:** {{...}}
- **Professional Services:** {{...}}

<!-- Variant B (Custom-Build): -->
| Giai doan | Pham vi | Ket qua |
|-----------|---------|---------|
| Phase 1 — MVP | {{...}} | {{...}} [src:wbs:P1] |
| Phase 2+ — Full Platform | {{...}} | {{...}} [src:wbs:P2-P5] |

### 1.3 Tong quan nang luc cot loi (Core Capability Overview)

#### {{Pillar 1: e.g., Xac thuc thong nhat & SSO}}
{{1 doan mo ta gia tri}} [src:domain:§2.1]

#### {{Pillar 2: e.g., Quan ly quyen truy cap}}
{{1 doan mo ta gia tri}} [src:domain:§2.2]

> [Diagram: Current State vs Proposed State — to be inserted or described in detail]

### 1.4 Muc tieu du an (Project Objectives)

| # | Muc tieu | Chi so thanh cong |
|---|----------|-------------------|
| 1 | {{...}} | {{cu the, do luong duoc}} [src:client:RFP§1.1] |
| 2 | {{...}} | {{...}} [src:client:RFP§1.2] |
| 3 | {{...}} | {{...}} [src:domain:§2] |
| 4 | {{...}} | {{...}} [src:qna:Q1] |

---

## 2. Use Cases / Pham vi chuc nang (Functional Scope)

<!-- ========== VARIANT A — Platform/Integration ========== -->

### 2.1 Bang use case (Use Case Catalogue) — Variant A

| UC ID | Ten Use Case | Mo ta | Nang luc can thiet |
|-------|-------------|------|-------------------|
| UC-01 | {{...}} | {{...}} | {{co che ky thuat cu the}} [src:client:RFP§2.1] |
| UC-02 | {{...}} | {{...}} | {{...}} [src:client:RFP§2.2] |

### 2.2 Phan tich luong chinh (Flow Deep-Dive) — Variant A

> Chi deep-dive 2-3 flow phuc tap nhat hoac client yeu cau cu the.

#### {{Flow name, e.g., Dang ky WebAuthn}}

{{1 doan gioi thieu kich ban kinh doanh va ly do flow nay quan trong}}
[src:client:RFP§2.X]

> [Sequence diagram: actors, requests/responses, protocol details]

| Buoc | Actor | Hanh dong | Chi tiet ky thuat |
|------|-------|-----------|-------------------|
| 1 | {{...}} | {{...}} | {{API call, token type, protocol ref}} [src:domain:§3] |

<!-- ========== VARIANT B — Custom-Build ========== -->

### 2.1 Module Common — Variant B

{{1 cau mo ta module}}

**Phase 1 — MVP:**
- {{Feature cu the (chi tiet implementation)}} [src:client:RFP§2.1]
- {{...}} [src:wbs:1.1]

**Phase 2+ — Full Platform:**
- {{Feature deferred}} [src:wbs:2.1]

### 2.2 {{Module name, e.g., Member Portal}} — Variant B

{{Tuong tu 2.1}}

### 2.X Ngoai pham vi ca hai giai doan (Out of Scope — Both Phases)

- {{Exclusion 1 — ly do}} [src:wbs:§5]
- {{Exclusion 2 — ly do}} [src:assumption:A3]

### 2.X Phu thuoc & Gia dinh (Dependencies & Assumptions)

| # | Danh muc | Mo ta |
|---|----------|-------|
| 1 | Scope | {{...}} [src:assumption:A1] |
| 2 | Third-Party | {{...}} [src:assumption:A2] |

---

## 3. Boi canh ky thuat / Kien thuc linh vuc (Technical Context)

> **Khi nao can:** Chi khi domain co standards/protocols/regulatory anh huong giai phap.
> Bo qua section nay cho cac du an app/web don gian.

### 3.1 {{Standard/Protocol}} la gi?

{{Giai thich bang ngon ngu de hieu + regulatory mapping}}
[src:domain:§3]

### 3.2 {{Platform Category}} can cung cap nhung gi?

- {{Nang luc bat buoc 1}} [src:domain:§3.1]
- {{Nang luc bat buoc 2}} [src:client:RFP§3]

### 3.3 {{Standard}}, {{Platform}}, va {{Custom Component}} tuong tac nhu the nao

| Layer | Trach nhiem |
|-------|------------|
| {{Security Profile}} | {{...}} [src:domain:§3.2] |
| {{CIAM Platform}} | {{...}} |
| {{Native SDK}} | {{...}} |
| {{Backend & API Gateway}} | {{...}} |

### 3.4 Tieu chi danh gia (Evaluation Criteria)

| Tieu chi | Tai sao quan trong | Yeu cau toi thieu |
|----------|--------------------|--------------------|
| {{...}} | {{...}} | {{cu the de danh gia vendor}} [src:client:RFP§4] |

---

## 4. Boi canh nghien cuu & De xuat nen tang (Research & Recommendation)

> **Khi nao can:** Chi khi co vendor/platform selection hoac pre-proposal research.
> Bo qua cho pure custom-build.

### 4.1 Ket qua nghien cuu truoc de xuat (Pre-Proposal Research)

{{SotaTek da nghien cuu doc lap ve kien truc cong nghe cua {{client_name}}...}}
[src:domain:§4]

> **Luu y quan trong:**
> - Ket qua dua tren nguon cong khai tinh den {{date}}.
> - SotaTek chua tiep can tai lieu noi bo cua {{client_name}}.
> - Tinh trang thuc te can duoc xac nhan tai {{discovery milestone}}.

### 4.2 Buc tranh thi truong (Market Landscape)

{{2-3 cau boi canh xu huong nganh}}

| Danh muc | Mo ta | Nen tang dai dien | Diem manh | Han che |
|----------|-------|--------------------|-----------|---------|
| {{...}} | {{...}} | {{...}} | {{...}} | {{...}} |

### 4.3 Mo hinh trien khai & Luu tru du lieu (Deployment & Data Residency)

> Chi cho nganh co phap ly (ngan hang, y te, chinh phu).

| Mo hinh | Mo ta | Phu hop cho {{client_name}} |
|---------|-------|----------------------------|
| Multi-tenant SaaS | {{...}} | {{...}} |
| Dedicated/Single-tenant | {{...}} | {{...}} |
| Self-hosted | {{...}} | {{...}} |

### 4.4 Ly do de xuat (Recommendation Rationale)

{{1-2 doan lien ket evaluation criteria -> market landscape -> recommendation}}
{{De xuat mang tinh **co dieu kien** phu thuoc ket qua discovery}}
[src:domain:§4.2]

### 4.5 Option A — {{Name}} ({{Positioning}})

{{Tai sao option nay dan dau neu [dieu kien]}}

| Nang luc / Gap | Cach tiep can |
|----------------|---------------|
| {{...}} | {{...}} |

### 4.X Bang so sanh vendor (Vendor Comparison Summary)

| Tieu chi | Option A | Option B | Option C |
|----------|----------|----------|----------|
| {{tu §3.4}} | {{...}} | {{...}} | {{...}} |
| **De xuat tong the** | {{co dieu kien}} | {{...}} | {{...}} |

---

## 5. Cach tiep can giai phap (Solution Approach)

### 5.1 Phuong phap luan (Delivery Methodology)

{{e.g., Agile Scrum voi sprint 2 tuan}}
[src:assumption:A1]

- **Sprint Planning:** {{...}}
- **Daily Standups:** {{...}}
- **Sprint Demo:** {{...}}
- **Milestone Gate Review:** {{...}}

### 5.2 Giao tiep & Hop tac (Communication) — _(Variant B required, Variant A optional)_

| Cong cu / Hoat dong | Muc dich |
|---------------------|----------|
| Slack | {{...}} |
| Jira | {{...}} |
| GitHub | {{...}} |

### 5.3 Phan chia trach nhiem (Responsibility Breakdown) — _(Variant A only)_

| Nang luc / San pham | Platform cung cap | SotaTek Professional Services |
|---------------------|-------------------|-------------------------------|
| {{...}} | {{...}} | {{SotaTek xay custom}} [src:wbs:1.1] |
| {{...}} | KHONG co — SotaTek xay | {{...}} [src:wbs:2.1] |

### 5.4 Dam bao chat luong (Quality Assurance)

| Loai testing | Cong cu | Muc tieu / Cach tiep can |
|-------------|---------|--------------------------|
| Unit Testing | {{...}} | {{...}} |
| Integration Testing | {{...}} | {{...}} |
| Security Testing | {{...}} | {{luu y han che neu co}} |
| UAT | {{...}} | {{...}} |

---

## 6. Kien truc ky thuat (Technical Architecture)

### 6.1 Nguyen tac kien truc (Core Architectural Principles)

- **Security-First Design:** {{...}} [src:domain:§3]
- **API-First / RESTful Design:** {{...}}
- **Cloud-Native & Scalable:** {{...}}
- {{Them nguyen tac phu hop du an}}

### 6.2 Kien truc he thong (System Architecture)

> [System Architecture Diagram — layered bands]
> Channel layer | Application/Identity layer | Integration layer | Core systems layer
> Color: blue = existing, green = SotaTek-built, gray = infrastructure

### 6.3 Cau hinh ky thuat (Technical Configuration)

| Danh muc | Cong nghe | Phien ban | Ghi chu |
|----------|-----------|-----------|---------|
| Platform | {{...}} | {{...}} | {{...}} |
| Backend | {{...}} | {{...}} | {{...}} |
| Database | {{...}} | {{...}} | {{...}} |
| Cloud/Region | {{...}} | {{...}} | {{...}} |
| CI/CD | {{...}} | {{...}} | {{...}} |

---

## 7. Pham vi du an (Project Scope)

> **Luu y:** Variant B co the da cover scope day du o Section 2. Section 7 khi do tom tat lai.

### 7.1 Trong pham vi (In-Scope)

#### {{Nhom nang luc 1}}
- {{Deliverable cu the}} [src:wbs:1.1]
- {{Deliverable cu the}} [src:wbs:1.2]

#### {{Nhom nang luc 2}}
- {{Deliverable cu the}} [src:wbs:2.1]

### 7.2 Ngoai pham vi (Out-of-Scope)

- {{Exclusion — ly do / ai chiu trach nhiem}} [src:wbs:§5]
- {{Chi phi hosting, licensing, dich vu ben thu 3}} [src:assumption:A4]

### 7.3 Gia dinh & Phu thuoc (Assumptions & Dependencies)

| # | Danh muc | Mo ta |
|---|----------|-------|
| 1 | Discovery | {{...}} [src:assumption:A1] |
| 2 | Scope | {{...}} [src:assumption:A2] |
| 3 | Third-Party | {{...}} [src:assumption:A3] |
| 4 | Infrastructure | {{...}} [src:assumption:A4] |

---

## 8. Tien do tong the (Master Schedule)

{{Tong thoi gian: {{X-Y}} tuan qua {{N}} milestones}}
{{Phuong phap: Agile Scrum voi sprint 2 tuan trong moi milestone}}

| Milestone | Thoi luong | Hoat dong & San pham chinh |
|-----------|-----------|---------------------------|
| M1: Discovery & Architecture | {{X-Y}} tuan | {{...}}. Sign-off: {{...}} [src:wbs:P1] |
| M2: Core Development | {{X-Y}} tuan | {{...}}. Sign-off: {{...}} [src:wbs:P2-P3] |
| M3: Integration & Testing | {{X-Y}} tuan | {{...}}. Sign-off: {{...}} [src:wbs:P4] |
| M4: UAT & Go-Live | {{X-Y}} tuan | {{...}}. Sign-off: {{...}} [src:wbs:P5] |

### Sprint Breakdown _(Variant B — custom-build, optional cho Variant A)_

| Sprint | Timeline | Module chinh |
|--------|----------|-------------|
| 1 | Week 1-2 | {{module list}} |
| 2 | Week 3-4 | {{module list}} |

---

## 9. WBS & Bao gia (WBS & Quotation)

<!-- ========== VARIANT A — Fixed Price (Custom-Build) ========== -->

### 9.1 Tong quan bao gia (Quotation Summary) — Variant A

- Mo hinh: {{fixed price / T&M / hybrid}}
- Bao gom: development, thiet lap ha tang, ho tro sau go-live, chuyen giao ma nguon
- Khong bao gom: chi phi hosting, dich vu ben thu 3

### 9.2 Bang phan chia cong viec (Work Breakdown Structure) — Variant A

> **Dong bo voi** `10-wbs-content.md` v{{X.Y}}. Source of truth la WBS.

#### Phase 1 — MVP

| EPIC | Feature | Sub-Feature | Function | Backend (man.day) | Frontend (man.day) |
|------|---------|-------------|----------|-------------------|-------------------|
| {{...}} | {{...}} | {{...}} | {{mo ta hanh vi cu the}} | {{n}} | {{n}} |
| | | **SUBTOTAL** | | **{{sum}}** | **{{sum}}** |

#### Phase 2+ — Full Platform _(du kien)_

| EPIC | Feature | Sub-Feature | Function | Backend (man.day) | Frontend (man.day) |
|------|---------|-------------|----------|-------------------|-------------------|
| {{...}} | {{...}} | {{...}} | {{...}} | {{n}} | {{n}} |
| | | **SUBTOTAL** | | **{{sum}}** | **{{sum}}** |

### 9.3 Co cau nhan luc (Effort Structure) — Variant A

| Qua trinh | Ty le (%) | Ghi chu |
|-----------|-----------|---------|
| Coding | 50% | {{...}} |
| Testing (IT) | 30% | {{...}} |
| Specification Analysis | 10% | {{...}} |
| Overhead | 10% | {{...}} |
| **Tong** | **100%** | |
| UI/UX Design | {{X}} man.days | (khong tinh theo %) |
| Deployment | {{X}} man.days | (khong tinh theo %) |

### 9.4 Tong hop tai chinh (Financial Summary) — Variant A

| Module | Tong effort (man.day) | Tong effort (man.month) | Don gia (USD) | Tong chi phi |
|--------|----------------------|------------------------|---------------|-------------|
| Phase 1 — MVP | {{n}} | {{n/20}} | ${{rate}} | ${{total}} |
| Phase 2+ | {{n}} | {{n/20}} | ${{rate}} | ${{total}} |
| **Tong** | **{{sum}}** | **{{sum}}** | | **${{grand_total}}** |

### 9.5 Milestone thanh toan (Payment Milestones) — Variant A

| Milestone | San pham ban giao | Ty le | Timeline |
|-----------|-------------------|-------|----------|
| M1: Ky hop dong | {{...}} | 50% | Upon contract |
| M2: Demo chuc nang | {{...}} | 40% | After sprint {{X}} |
| M3: Ban giao cuoi | {{...}} | 10% | After go-live |

<!-- ========== VARIANT B — Team-Based (Platform/Discovery) ========== -->

### 9.1 Tong quan bao gia (Quotation Summary) — Variant B

- Mo hinh: Fixed Price, team-based delivery model
- Bao gom: {{list deliverables}}
- Khong bao gom: CIAM licensing, cloud infrastructure, dich vu ben thu 3 — thoa thuan thuong mai rieng

### 9.2 Co cau doi ngu & Chi phi (Team Structure & Cost) — Variant B

| Vi tri | M1 | M2 | M3 | M4 |
|--------|-----|-----|-----|-----|
| Project Manager | 0.5 | 0.5 | 0.5 | 0.5 |
| Solution Architect | 1 | 0.5 | 0.5 | — |
| BA | 1 | 0.5 | — | — |
| Backend Engineer | 1 | 2-3 | 3-4 | 1-2 |
| Mobile SDK Engineer | — | 1-2 | 2-3 | 1 |
| QA/Security Engineer | — | 1 | 1-2 | 1 |
| DevOps Engineer | 0.5 | 0.5 | 0.5 | 0.5 |
| **TOTAL** | **~4** | **~6-8** | **~8-11** | **~4-5** |

### Tom tat trien khai doi ngu (Team Deployment Summary) — Variant B

**Milestone 1 — {{Name}} ({{duration}}, ~{{N}} FTEs)**
{{1-2 cau mo ta focus}}
**Key output:** {{deliverables cu the tai sign-off}}

**Milestone 2 — {{Name}} ({{duration}}, ~{{N}} FTEs)**
{{...}}
**Key output:** {{...}}

---

## 10. Lo trinh nang cap tuong lai (Future Enhancements Roadmap)

> Cac hang muc duoc co y loai tru khoi Phase 1 de duy tri toc do delivery.
> Thoi diem: can danh gia dua tren bai hoc production, khong som hon 6-12 thang sau MVP.

### 10.1 Phase 2: {{Ten mo rong dau tien}}
- {{Nang luc 1: mo ta ngan}} [src:domain:§7]
- {{Nang luc 2}} [src:wbs:§5]

### 10.2 Phase 3: {{Nang luc nang cao}}
- {{...}}

### 10.3 Phase 4: {{Mo rong he sinh thai}} _(optional)_
- {{...}}

---

## 11. Ket luan (Conclusion)

{{1 doan mo dau the hien su tu tin}}

### {{Nguyen tac 1: e.g., Chung toi bat dau bang discovery, khong phai gia dinh}}
{{1 doan mo rong nguyen tac va lien ket voi engagement cu the}}

### {{Nguyen tac 2: e.g., Xay tren nhung gi da co}}
{{...}}

### {{Nguyen tac 3: e.g., Delivery tung buoc — phan mem chay duoc tai moi gate}}
{{...}}

{{1 doan ket: tuyen bo hop tac + buoc tiep theo cu the (e.g., "len lich kickoff Milestone 1 discovery")}}

*— Het tai lieu —*

---

<!-- RENDER HINT:
Khi render qua document-skills:docx, su dung style spec docx (cover_page, heading_1/2/3, table, ...).
Neu watermark.show=true o style spec thi giai doan draft se co watermark "DRAFT".
Styling chi tiet: xem templates/proposal-guide.md "Layout & Styling Specification".
Color palette proposal-specific: xem templates/output-style-spec.json docx.proposal_cells.
-->
