---
description: Sinh và cập nhật requirements — mỗi REQ 1 file riêng, index ở _index.md
---

# /requirements Skill

## Subcommands

| Subcommand | Action |
|---|---|
| `/requirements US-NNN` | Viết ACs cho một US cụ thể → tạo `requirements/REQ-N.md` |
| `/requirements init` | Khởi tạo `requirements/` từ codebase hiện có |
| `/requirements update` | Cập nhật REQ-N.md sau khi task DEV vừa xong |

Không có subcommand → kiểm tra `requirements/` có chưa, chọn mode phù hợp.

---

## Bước 1: Xác định chế độ

```bash
ls .claude/docs/requirements/_index.md 2>/dev/null && echo "EXISTS" || echo "NEW"
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
5. `.claude/docs/design/_index.md` nếu đã có

### Tạo `requirements/_index.md`:
```markdown
# Requirements Index — [Project Name]

## Glossary
| Thuật ngữ | Định nghĩa |

## Correctness Properties
| CP | Invariant | Validates |

## REQ List
| REQ | US | Title | ACs | GoLive |
```

### Tạo `requirements/REQ-N.md` cho mỗi REQ:
```markdown
# REQ-N: [Tên]
<!-- US: US-NNN -->
<!-- Last updated: khởi tạo (YYYY-MM-DD) -->

**User Story:** ...
**Design References:** [design/REQ-N.md](../design/REQ-N.md)

## Acceptance Criteria
- AC1: WHEN ... THEN ...
```

---

## Chế độ VIẾT ACs CHO US (`/requirements US-NNN`)

### Bước 1 — Đọc US:
```bash
cat .claude/docs/us/US-NNN.md
```

### Bước 2 — Xác định REQ ID tiếp theo:
```bash
grep "REQ-" .claude/docs/requirements/_index.md | tail -3
# → lấy số REQ cuối + 1
```

### Bước 3 — Tạo file `requirements/REQ-N.md`:

```markdown
# REQ-N: [Tên từ US title]
<!-- US: US-NNN -->
<!-- Last updated: khởi tạo (YYYY-MM-DD) -->

**User Story:**
Là một [role], tôi muốn [hành động], để [lợi ích].

**Design References:** _Cập nhật sau khi DEV viết design_

## Acceptance Criteria

- AC1: WHEN [điều kiện] THEN [hành vi mong đợi]
- AC2: WHEN [điều kiện 2] THEN [hành vi 2]
- AC3: IF [ngoại lệ] THEN [xử lý]
```

**Nguyên tắc viết ACs:**
- Mỗi AC: testable, unambiguous, không có implementation detail
- WHEN/THEN cho happy path; IF/THEN cho error/edge case
- Không viết "hệ thống nên" — phải là "THEN system SHALL"

### Bước 4 — Thêm vào `requirements/_index.md`:
```markdown
| [REQ-N](REQ-N.md) | US-NNN | [Tên] | X | ⬛ |
```

### Bước 5 — Update US file:
```bash
# Edit us/US-NNN.md:
# status: ac-ready
# Linked REQs: REQ-N
```

### Bước 6 — Thông báo:
*"Đã tạo requirements/REQ-N.md cho US-NNN: [X ACs]. Ping DEV với REQ-N."*

---

## Chế độ CẬP NHẬT (`/requirements update`)

### Đọc context:
```bash
# Xem index
cat .claude/docs/requirements/_index.md

# Tìm task Done gần nhất
grep -n "Status.*Done" .claude/docs/tasks/_index.md | tail -3
```

Đọc `tasks/TASK-NNN.md`:
- `Requirement Impact` — REQ nào bị ảnh hưởng
- `Changed Files`

### Đọc đúng file REQ bị ảnh hưởng:
```bash
cat .claude/docs/requirements/REQ-N.md
```

### Phân tích + cập nhật trực tiếp:
- Sửa AC trong `requirements/REQ-N.md`
- Thêm: `<!-- Last updated: TASK-XXX (YYYY-MM-DD) -->`
- Thông báo: *"Đã cập nhật requirements/REQ-N.md: [AC nào sửa/thêm]"*
