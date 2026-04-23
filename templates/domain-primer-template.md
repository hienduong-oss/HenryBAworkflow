<!--
TEMPLATE: Domain Primer (Phase 1 output of /ba-presale)
PURPOSE: Capture domain context BEFORE WBS+Proposal so estimates are anchored in real understanding.
STATUS: PLACEHOLDER — refine in Phase A.
LOCATION (per project): presale/{slug}-{date}/00-domain-primer.md
LANGUAGE: Vietnamese by default (per BA-kit CLAUDE.md).
-->

# Domain Primer — {{client_name}} / {{project_name}}

> **Mục đích:** Tóm lược domain, business model, và bối cảnh khách hàng để WBS + Proposal được ước lượng & viết đúng ngữ cảnh.
> **Nguồn:** `00-inputs/` + WebSearch (nếu có) + tri thức nền của agent.
> **Trạng thái:** {{draft|reviewed|locked}}
> **Ngày:** {{YYYY-MM-DD}}

---

## 1. Khách hàng & Bối cảnh
- **Tên khách hàng:** {{...}}
- **Ngành / lĩnh vực:** {{...}}
- **Quy mô / giai đoạn:** {{startup | SME | enterprise | ...}}
- **Vị thế thị trường:** {{...}}
- **Người ra quyết định chính:** {{vai trò, không cần tên cá nhân nếu chưa rõ}}

## 2. Bài toán & Nhu cầu lõi
- **Vấn đề khách đang gặp:** {{...}}
- **Mục tiêu kinh doanh kỳ vọng:** {{...}}
- **Tiêu chí thành công khả dĩ:** {{KPI nếu có}}

## 3. Domain Knowledge tóm lược
- **Khái niệm / thuật ngữ chính:** {{glossary tối thiểu}}
- **Quy trình nghiệp vụ then chốt:** {{flow ngắn gọn}}
- **Stakeholder & vai trò:** {{...}}
- **Quy định / chuẩn ngành (nếu có):** {{...}}

## 4. Bối cảnh kỹ thuật (sơ bộ)
- **Hệ thống đang có / sẽ tích hợp:** {{...}}
- **Stack ưu tiên / ràng buộc công nghệ:** {{...}}
- **Phụ thuộc bên thứ ba:** {{...}}

## 5. Giả định & Ràng buộc
- **Giả định:** {{A1, A2, ...}}
- **Ràng buộc:** {{thời gian, ngân sách, nhân sự, pháp lý}}

## 6. Rủi ro sớm (early risks)
| ID | Rủi ro | Mức độ | Tác động | Cần làm rõ ở QnA? |
|----|--------|--------|----------|-------------------|
| R1 | {{...}} | H/M/L | {{scope/cost/timeline}} | Y/N |

## 7. Câu hỏi mở cho QnA
> Dán vào `30-qna-content.md` ở phase QnA.
- Q: {{...}}
- Q: {{...}}

## 8. Nguồn tham chiếu
- `00-inputs/requirements/...`
- `00-inputs/discussions/...`
- WebSearch: {{url + ngày truy cập}}

---

<!-- HANDOFF NOTE:
Mỗi mục trong WBS/Proposal kế tiếp NÊN có thể trace ngược về một section của file này
hoặc về `00-inputs/` gốc, để khi handoff sang /ba-start backbone không mất context.
-->
