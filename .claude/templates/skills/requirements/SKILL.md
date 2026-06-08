---
description: Sinh và cập nhật requirements.md từ User Stories — phân tích hệ thống hoặc impact từ task vừa xong
---

# /requirements Skill

## Subcommands

| Subcommand | Action |
|---|---|
| `/requirements US-NNN` | Viết ACs cho một US cụ thể, append vào requirements.md |
| `/requirements init` | Khởi tạo requirements.md từ codebase hiện có |
| `/requirements update` | Cập nhật requirements.md sau khi task DEV vừa xong |

Không có subcommand → kiểm tra requirements.md có chưa, chọn mode phù hợp.

---

## Bước 1: Xác định chế độ

```bash
ls .claude/docs/requirements.md 2>/dev/null && echo "EXISTS" || echo "NEW"
```

- **Chưa có** → chạy **KHỞI TẠO**
- **Đã có + có US-NNN** → chạy **VIẾT ACs CHO US**
- **Đã có + sau task DEV** → chạy **CẬP NHẬT**

---

## Chế độ KHỞI TẠO (`/requirements init`)

### Đọc để hiểu hệ thống:
1. `CLAUDE.md` — tổng quan project, stack, conventions
2. Entry points của app (routes, main files, API endpoints)
3. Business logic / service layer
4. Data models / DB schema (nếu có)
5. `.claude/docs/design.md` nếu đã có

### Sinh `requirements.md`:
- Dùng `.claude/template/requirements.template.md` làm format mẫu
- **Introduction**: mô tả project, phạm vi
- **Glossary**: thuật ngữ domain
- **Requirements**: mỗi REQ bao gồm:
  - User Story (As a [role], I want..., so that...)
  - **Design References** trỏ tới section trong design.md
  - Acceptance Criteria dạng `WHEN/IF/THEN`
  - `<!-- Last updated: khởi tạo (YYYY-MM-DD) -->`
- **Correctness Properties**: invariants quan trọng

---

## Chế độ VIẾT ACs CHO US (`/requirements US-NNN`)

### Bước 1 — Đọc US:
```bash
cat .claude/docs/us/US-NNN.md
```

### Bước 2 — Xác định REQ ID tiếp theo:
```bash
grep -n "^### REQ-" .claude/docs/requirements.md | tail -3
# → lấy số REQ cuối + 1
```

### Bước 3 — Viết section REQ-N mới:

```markdown
### REQ-N: [Tên từ US title]
<!-- US: US-NNN -->
<!-- Last updated: khởi tạo (YYYY-MM-DD) -->

**User Story:**
Là một [role], tôi muốn [hành động], để [lợi ích].

**Design References:** _Cập nhật sau khi DEV viết design.md_

**Acceptance Criteria:**
- WHEN [điều kiện] THEN [hành vi mong đợi]
- WHEN [điều kiện 2] THEN [hành vi 2]
- IF [ngoại lệ] THEN [xử lý]
```

**Nguyên tắc viết ACs:**
- Mỗi AC: testable, unambiguous, không có implementation detail
- WHEN/THEN cho happy path; IF/THEN cho error/edge case
- Tham chiếu data fields chính xác (tên bảng, tên field)
- Không viết "hệ thống nên" — phải là "THEN system SHALL"

### Bước 4 — Update US file:
```bash
# Edit US-NNN.md:
# status: ac-ready
# Linked REQs: REQ-N
```

### Bước 5 — Thông báo:
*"Đã viết REQ-N cho US-NNN: [X ACs]. Ping DEV với REQ-N."*

---

## Chế độ CẬP NHẬT (`/requirements update`)

### Đọc context:
```bash
# Xem section headers
grep -n "^### REQ-" .claude/docs/requirements.md

# Tìm task Done gần nhất
grep -n "Status.*Done" .claude/docs/tasks/_index.md | tail -3
```

Đọc `tasks/TASK-NNN.md` (task vừa Done):
- `Changed Files`
- `System Impact Analysis`
- `Requirement Impact`

### Phân tích:
- Requirement nào **phản ánh sai** behavior sau thay đổi?
- Feature mới nào **chưa có requirement**?
- AC nào cần **sửa lại**?

### Cập nhật trực tiếp (không cần confirm):
- Sửa nội dung AC
- Thêm: `<!-- Last updated: TASK-XXX (YYYY-MM-DD) -->`
- Thông báo: *"Đã cập nhật requirements.md: [REQ nào sửa/thêm]"*
