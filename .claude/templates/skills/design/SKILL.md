---
description: Sinh và cập nhật design — mỗi REQ 1 file riêng, overview ở _index.md
---

# /design Skill

## Bước 1: Xác định chế độ

```bash
ls .claude/docs/design/_index.md 2>/dev/null && echo "EXISTS" || echo "NEW"
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
9. `.claude/docs/requirements/_index.md` nếu đã có

### Tạo `design/_index.md`:
```markdown
# Design Overview — [Project Name]

## System Architecture
[Diagram tổng quan]

## Tech Stack
| Layer | Technology |

## Out of Scope (v1)
- ...

## REQ Design Files
| REQ | File | Last updated |
```

### Tạo `design/REQ-N.md` cho từng REQ đã có:
```markdown
# Design — REQ-N: [Tên]
<!-- Last updated: khởi tạo (YYYY-MM-DD) -->

## Components
### [ComponentName] (`src/path/file`)
- Mô tả behavior, invariants

## Data Types
```typescript
interface [Type] { ... }
```

## Design Decisions
| Decision | Rationale |
```

---

## Chế độ CẬP NHẬT

### Đọc context (targeted read):

```bash
# Xem index
cat .claude/docs/design/_index.md

# Task vừa Done
grep -n "Status.*Done" .claude/docs/tasks/_index.md | tail -3
```

Đọc `tasks/TASK-NNN.md`:
- `Changed Files`
- `System Impact Analysis`
- `Design Impact` — xác định REQ nào cần update

### Đọc đúng file design bị ảnh hưởng:
```bash
cat .claude/docs/design/REQ-N.md
```

Đọc toàn bộ **từng file đã thay đổi** (không chỉ diff). Trace **data flow**.

### Phân tích ripple effect:
- Component nào **thay đổi interface/behavior**?
- Architecture flow nào **không còn chính xác**?
- Correctness Property nào **bị vi phạm hoặc cần cập nhật**?
- Data Model nào **thay đổi**?

### Cập nhật trực tiếp (không cần confirm):
- Sửa `design/REQ-N.md` — chỉ file liên quan, không sửa file khác
- Cập nhật `design/_index.md` nếu có REQ mới hoặc Last updated thay đổi
- Thêm: `<!-- Last updated: TASK-NNN (YYYY-MM-DD) -->`
- Thông báo: *"Đã cập nhật design/REQ-N.md: [component nào sửa/thêm]"*

---

## Targeted Read Rule

**Không đọc toàn bộ design/REQ-N.md** khi chỉ cần 1 section. Dùng:
```bash
grep -n "^##" .claude/docs/design/REQ-N.md
# → xác định offset
# → Read(design/REQ-N.md, offset=X, limit=40)
```
