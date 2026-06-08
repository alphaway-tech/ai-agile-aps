---
description: Sinh và cập nhật design.md — phân tích architecture hiện tại hoặc ripple effect từ task vừa xong
---

# /design Skill

## Bước 1: Xác định chế độ

```bash
ls .claude/docs/design.md 2>/dev/null && echo "EXISTS" || echo "NEW"
```

- **Chưa có** → chạy **KHỞI TẠO**
- **Đã có** → chạy **CẬP NHẬT**

---

## Chế độ KHỞI TẠO

### Đọc để hiểu hệ thống:
1. `CLAUDE.md` — stack, architecture overview, conventions
2. Entry points (main file, router, server bootstrap)
3. Request/response flow (middleware, handlers, controllers)
4. Business logic layer (services, use cases)
5. Data access layer (repositories, DB queries)
6. Data models (schema, migrations, types)
7. Auth / security layer
8. External integrations (APIs, queues, storage)
9. `.claude/docs/requirements.md` nếu đã có

### Sinh `design.md`:
- Dùng `.claude/template/design.template.md` làm format
- Thêm annotation vào mỗi section chính:
  ```markdown
  ### [ComponentName]
  <!-- Last updated: khởi tạo (YYYY-MM-DD) -->
  ```
- Ghi vào `.claude/docs/design.md`

---

## Chế độ CẬP NHẬT

### Đọc context (targeted read):

```bash
# Xem section headers
grep -n "^##\|^###" .claude/docs/design.md

# Task vừa Done
grep -n "Status.*Done" .claude/docs/tasks/_index.md | tail -3
```

Đọc `tasks/TASK-NNN.md`:
- `Changed Files`
- `System Impact Analysis`
- `Design Impact`

Đọc toàn bộ **từng file đã thay đổi** (không chỉ diff).

Trace **data flow** qua hệ thống liên quan đến thay đổi.

### Phân tích ripple effect:
- Component nào **thay đổi interface/behavior**?
- Architecture flow nào **không còn chính xác**?
- Correctness Property nào **bị vi phạm hoặc cần cập nhật**?
- Data Model nào **thay đổi**?
- Business Logic nào **thay đổi**?

### Cập nhật trực tiếp (không cần confirm):
- Sửa nội dung section
- Thêm: `<!-- Last updated: TASK-XXX (YYYY-MM-DD) -->`
- Thông báo: *"Đã cập nhật design.md: [section nào sửa/thêm]"*

---

## Targeted Read Rule

**Không đọc toàn file** khi chỉ cần 1-2 section. Dùng:
```bash
grep -n "^###" .claude/docs/design.md
# → xác định offset
# → Read(design.md, offset=X, limit=40)
```
