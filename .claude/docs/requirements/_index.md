# Requirements Index — Todo Manager

## Glossary

| Thuật ngữ | Định nghĩa |
|---|---|
| **Todo** | Công việc cần làm — tiêu đề (bắt buộc), mô tả (tùy chọn). Trạng thái: `pending` hoặc `completed`. |
| **Owner** | Người dùng đang dùng app. |
| **Filter** | Bộ lọc: Tất cả / Đang làm / Hoàn thành. |

---

## Correctness Properties

| CP | Invariant | Validates |
|----|-----------|-----------|
| CP-1 | Count badge = số item render thực tế (mọi filter state) | REQ-1.AC7, REQ-1.AC8 |
| CP-2 | Todo status chỉ có 2 giá trị: `pending` hoặc `completed` | REQ-1.AC4, REQ-1.AC5 |

---

## REQ List

| REQ | US | Title | ACs | GoLive |
|-----|----|-------|-----|--------|
| [REQ-1](REQ-1.md) | US-001 | Quản lý danh sách công việc (Todo CRUD) | 10 | 🟢 |
