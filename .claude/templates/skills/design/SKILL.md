---
description: Design-first workflow — viết design/REQ-N.md trước khi code, verify sau khi implement
---

# /design Skill

Design là **constraint**, không phải documentation.  
**Phải tồn tại trước khi DEV viết một dòng code nào.**  
QC dùng design để viết tc-draft song song với DEV.

## Subcommands

| Subcommand | Khi nào | Action |
|---|---|---|
| `/design draft REQ-N` | Trước khi implement | Đọc requirements → viết design/REQ-N.md (status: draft) |
| `/design verify REQ-N` | Sau khi implement | So sánh design draft với code thực tế → cập nhật, đổi status: done |
| `/design update REQ-N` | Sau task bugfix/refactor | Cập nhật design đã done cho phù hợp với thay đổi |
| `/design init` | Lần đầu setup project | Tạo design/_index.md + design/REQ-N.md từ codebase hiện có |

Không có subcommand → kiểm tra trạng thái design hiện tại của REQ được hỏi.

---

## Status Lifecycle

```
[chưa có file]
      │ /design draft
      ▼
  Status: draft        ← DEV viết trước khi code
      │                   QC đọc để viết tc-draft
      │ implement xong
      │ /design verify
      ▼
  Status: done         ← verified against implementation
      │
      │ bugfix/refactor (TASK mới)
      │ /design update
      ▼
  Status: done         ← updated
```

---

## `/design draft REQ-N` — Viết trước khi code

> **Gate:** DEV không được implement trước khi bước này xong.

### Bước 1 — Đọc requirements

```bash
cat .claude/docs/requirements/REQ-N.md
```

Đọc kỹ từng AC. Xác định:
- Có bao nhiêu component cần tạo mới / sửa?
- Data flow chính là gì?
- Invariants nào phải giữ (Correctness Properties)?

### Bước 2 — Đọc context hiện có

```bash
# Design của REQ khác để hiểu conventions
cat .claude/docs/design/_index.md

# Src files liên quan (nếu cần sửa file hiện có)
ls src/
```

### Bước 3 — Tạo `design/REQ-N.md`

```markdown
# Design — REQ-N: [Tên từ requirements]
<!-- Status: draft -->
<!-- Last updated: TASK-NNN (YYYY-MM-DD) -->

**Requirements:** [requirements/REQ-N.md](../requirements/REQ-N.md)

## Components

### [ComponentName] (`src/path/file.ts` — new | modified)
- Trách nhiệm: [làm gì]
- AC coverage: AC1, AC2, AC4
- Public interface:
  - `methodName(params): ReturnType` — [mô tả]

### [ComponentName2] (`src/path/file2.ts` — modified)
- Trách nhiệm: [làm gì]
- AC coverage: AC3, AC5

## Data Types

```typescript
interface [TypeName] {
  field: type  // [mô tả constraint]
}
```

## Data Flow

```
[Trigger / User action]
  → ComponentA.method()
  → ComponentB.update()
  → [Result / Side effect]
```

## Design Decisions

| Decision | Rationale | Alternatives rejected |
|---|---|---|
| [Chọn X] | [Tại sao] | [Y vì sao không dùng] |

## Correctness Properties

| CP | Invariant | Liên quan AC |
|----|-----------|-------------|
| CP-N | [Điều kiện phải luôn đúng] | AC3, AC7 |

## Test Entry Points (cho QC)

> QC đọc section này để viết tc-draft — không cần đọc code.

| AC | Entry point | Setup cần thiết |
|----|-------------|----------------|
| AC1 | `ComponentA.create(data)` | empty store |
| AC2 | submit form với title rỗng | — |
| AC3 | `store.getAll()` sau nhiều create | 3+ items |
```

### Bước 4 — Cập nhật `design/_index.md`

```markdown
| [REQ-N](REQ-N.md) | [Tên] | draft | TASK-NNN |
```

### Bước 5 — Thông báo

```
✅ design/REQ-N.md (draft) đã sẵn sàng.
   DEV: có thể bắt đầu implement.
   QC: đọc design + requirements để viết tc-draft.
```

---

## `/design verify REQ-N` — Verify sau khi implement

> Chạy ngay sau khi implement xong, trước khi đóng task.

### Bước 1 — So sánh design draft với code thực tế

Đọc từng section của `design/REQ-N.md` và kiểm tra:

| Section | Kiểm tra |
|---------|---------|
| Components | File path đúng không? Interface có thay đổi không? |
| Data Types | TypeScript types có khớp không? |
| Data Flow | Flow có thay đổi không? |
| Design Decisions | Quyết định cuối cùng có giống draft không? |
| Test Entry Points | Entry points còn valid không? |

### Bước 2 — Cập nhật những gì đã thay đổi

Sửa trực tiếp vào `design/REQ-N.md`. Với mỗi thay đổi so với draft, thêm ghi chú:

```markdown
> ⚠️ Deviation from draft: [mô tả — vd: dùng Map thay vì Array vì performance]
```

Ghi chú deviation giúp QC biết tc-draft có cần điều chỉnh không.

### Bước 3 — Đổi status và update index

```markdown
<!-- Status: done -->
<!-- Last updated: TASK-NNN (YYYY-MM-DD) -->
```

```bash
# Update _index.md: draft → done
```

---

## `/design update REQ-N` — Cập nhật sau bugfix/refactor

Dùng khi có TASK mới (không phải TASK tạo ra REQ-N) sửa code liên quan.

### Đọc context:

```bash
cat .claude/docs/tasks/TASK-NNN.md   # Changed Files, System Impact
cat .claude/docs/design/REQ-N.md     # design hiện tại
```

Phân tích:
- Component nào thay đổi interface/behavior?
- Data flow nào không còn chính xác?
- Test Entry Points còn valid không?

Cập nhật trực tiếp. Thêm:
```markdown
<!-- Last updated: TASK-NNN (YYYY-MM-DD) -->
```

---

## `/design init` — Khởi tạo từ codebase hiện có

Dùng khi project đã có code nhưng chưa có design docs.

### Đọc để hiểu hệ thống:
1. Entry points (main file, router, server bootstrap)
2. Business logic layer
3. Data models / schema
4. `.claude/docs/requirements/_index.md` nếu đã có

### Tạo `design/_index.md`:

```markdown
# Design Overview — [Project Name]

**Updated:** YYYY-MM-DD

## System Architecture
[Mô tả tổng quan]

## Tech Stack
| Layer | Technology |

## REQ Design Files
| REQ | File | Status | Last updated |
|-----|------|--------|-------------|
```

Tạo `design/REQ-N.md` cho mỗi REQ đã có với status `done` (vì đã implement).

---

## Targeted Read Rule

Không đọc toàn bộ `design/REQ-N.md` khi chỉ cần 1 section:

```bash
grep -n "^##" .claude/docs/design/REQ-N.md
# → xác định offset → Read với limit nhỏ
```
