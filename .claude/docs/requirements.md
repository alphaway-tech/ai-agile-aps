# Requirements Document — Todo Manager

## Introduction

**Todo Manager** là ứng dụng web quản lý công việc cá nhân. Người dùng tạo, xem, cập nhật, xóa và lọc danh sách công việc. Tập trung vào sự đơn giản và tốc độ.

---

## Glossary

| Thuật ngữ | Định nghĩa |
|---|---|
| **Todo** | Công việc cần làm — tiêu đề (bắt buộc), mô tả (tùy chọn). Trạng thái: `pending` hoặc `completed`. |
| **Owner** | Người dùng đang dùng app. |
| **Filter** | Bộ lọc: Tất cả / Đang làm / Hoàn thành. |

---

## Requirements

### REQ-1: Quản lý danh sách công việc (Todo CRUD)
<!-- US: US-001 -->
<!-- Last updated: khởi tạo (2026-06-08) -->

**User Story:**
Là một người dùng, tôi muốn tạo, xem, cập nhật và xóa công việc để quản lý danh sách việc hàng ngày.

**Design References:** _Cập nhật sau khi DEV viết design.md_

**Acceptance Criteria:**
- WHEN the Owner submits a new todo with a title THEN the system saves it with status='pending' and displays it at the top of the list.
- WHEN the Owner submits without a title THEN the system shows "Tiêu đề không được để trống" and does not save.
- WHEN the Owner views the list THEN all todos are shown sorted by created_at descending.
- WHEN the Owner clicks complete on a pending todo THEN status changes to 'completed' and a visual indicator appears.
- WHEN the Owner clicks complete on a completed todo THEN status reverts to 'pending'.
- WHEN the Owner clicks delete THEN a confirmation appears; upon confirmation the todo is permanently removed.
- WHEN the Owner selects filter "Đang làm" THEN only pending todos are shown with a count badge.
- WHEN the Owner selects filter "Hoàn thành" THEN only completed todos are shown with a count badge.
- WHEN the Owner selects filter "Tất cả" THEN all todos are shown.
- IF no todos match the current filter THEN an empty state message is displayed.

---

## Correctness Properties

### CP-1: Count badge = số item thực tế
*For any* filter state, count badge MUST equal the number of rendered todo items.
**Validates:** REQ-1.AC7, REQ-1.AC8

### CP-2: Status chỉ có 2 giá trị
*For any* todo, status SHALL be 'pending' or 'completed'.
**Validates:** REQ-1.AC4, REQ-1.AC5
