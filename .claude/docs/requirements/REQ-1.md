# REQ-1: Quản lý danh sách công việc (Todo CRUD)
<!-- US: US-001 -->
<!-- Last updated: TASK-001 (2026-06-08) -->

**User Story:**
Là một người dùng, tôi muốn tạo, xem, cập nhật và xóa công việc để quản lý danh sách việc hàng ngày.

**Design References:** [design/REQ-1.md](../design/REQ-1.md)

---

## Acceptance Criteria

- AC1: WHEN the Owner submits a new todo with a title THEN the system saves it with status='pending' and displays it at the top of the list.
- AC2: WHEN the Owner submits without a title THEN the system shows "Tiêu đề không được để trống" and does not save.
- AC3: WHEN the Owner views the list THEN all todos are shown sorted by created_at descending.
- AC4: WHEN the Owner clicks complete on a pending todo THEN status changes to 'completed' and a visual indicator appears.
- AC5: WHEN the Owner clicks complete on a completed todo THEN status reverts to 'pending'.
- AC6: WHEN the Owner clicks delete THEN a confirmation appears; upon confirmation the todo is permanently removed.
- AC7: WHEN the Owner selects filter "Đang làm" THEN only pending todos are shown with a count badge.
- AC8: WHEN the Owner selects filter "Hoàn thành" THEN only completed todos are shown with a count badge.
- AC9: WHEN the Owner selects filter "Tất cả" THEN all todos are shown.
- AC10: IF no todos match the current filter THEN an empty state message is displayed.
