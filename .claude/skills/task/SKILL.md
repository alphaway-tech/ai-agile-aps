---
description: Tạo và quản lý task trong tasks/ — mỗi task 1 file, index ở _index.md, execute khi user bảo "làm"
---

# /task Skill

## Bước 1: Xác định hành động

- User **yêu cầu làm việc mới** → **TẠO TASK MỚI**
- User **bảo "làm"** (hoặc: "proceed", "thực hiện", "ok làm đi") → **EXECUTE TASK**
- User **báo task xong** hoặc vừa hoàn thành implement → **ĐÓNG TASK**
- User **hỏi về task** → đọc `.claude/docs/tasks/_index.md` và trả lời

---

## PHÂN LOẠI TASK

| Type | Khi nào | Full plan | Impact analysis |
|---|---|---|---|
| `feature` | Tính năng mới, thay đổi behavior | Bắt buộc | Đầy đủ |
| `bugfix` | Fix lỗi, sai behavior | Đầy đủ | Bắt buộc Lessons Learned |
| `refactor` | Cải thiện code không đổi behavior | Đầy đủ | Không cần update requirements |
| `quick` | ≤30 lines, 1 file, không có logic mới | Tóm tắt ngắn | Chỉ khi impact != none |

---

## TẠO TASK MỚI

### 1. Chuẩn bị — đọc theo task type (lazy load)

| Task type | Đọc gì |
|---|---|
| `feature` | `_index.md` + targeted sections của `requirements.md` + `design.md` + US liên quan |
| `bugfix` | `_index.md` + targeted sections của `design.md` + code liên quan |
| `refactor` | `_index.md` + code liên quan |
| `quick` | `_index.md` (chỉ cần TASK-ID tiếp theo) |

**Targeted read:**
```bash
# Xem section headers
grep -n "^##" .claude/docs/requirements.md
grep -n "^##\|^###" .claude/docs/design.md
# → Read(file, offset=X, limit=60)
```

Tìm ID tiếp theo:
```bash
ls .claude/docs/tasks/TASK-*.md 2>/dev/null | sort -V | tail -1
```

### 2. Viết task file

**KHÔNG dùng EnterPlanMode/ExitPlanMode.** Plan đi thẳng vào task file.

Tạo `.claude/docs/tasks/TASK-NNN.md`:

```markdown
## TASK-NNN

**Status:** Pending Approval
**Type:** feature | bugfix | refactor | quick
**Title:** [Tên ngắn gọn]
**Business Goal:** [Tại sao cần làm]

**US Reference:** US-NNN
**Requirement References:** REQ-N.ACx
**Design References:** [Section trong design.md]

**Impacted Files:**
- `path/to/file`

---

### Approach
[Tại sao chọn cách này, trade-offs, alternatives đã loại]

### Plan
1. [Bước cụ thể — file nào, thay đổi gì, tại sao]
2.
3.

### Acceptance Criteria
- [ ] [Điều kiện kiểm chứng được]
- [ ]

### Predicted Impact
**Requirement Impact:** none | [REQ nào cần thêm/sửa]
**Design Impact:** none | [Section nào cần update]

---
*(Implementation Summary sẽ điền sau khi xong)*
```

Thêm vào đầu bảng `_index.md`:
```markdown
| [TASK-NNN](TASK-NNN.md) | Title | type | Pending Approval | — |
```

### 3. Thông báo
*"TASK-NNN đã sẵn sàng. Bảo tôi 'làm' khi muốn thực hiện."*

**Không tự động implement. Chờ user bảo "làm".**

---

## EXECUTE TASK

Khi user bảo "làm":

0. **In Progress leak check:**
   ```bash
   grep -rn "Status.*In Progress" .claude/docs/tasks/
   ```
   Nếu có task khác In Progress → thông báo, hỏi user trước.

1. **Bắt buộc: đọc file task:**
   ```
   Read(.claude/docs/tasks/TASK-NNN.md)
   ```

2. Đọc kỹ: Approach, Plan, AC, Impacted Files.
   **Plan là intent** — luôn đọc code thực tế trước khi implement.

3. Implement đúng theo plan. Nếu plan có vấn đề → thông báo trước, không tự sửa.

4. Cập nhật `Status: In Progress`.

5. Sau khi xong → **ĐÓNG TASK** ngay.

---

## ĐÓNG TASK

### 1. Phân tích impact
Đọc toàn bộ file đã sửa + dependencies. Xác định data flow, edge cases.

### 2. Cập nhật file task

```
**Status:** Done

Implementation Summary: [1-3 câu]

Changed Files:
- `path/file` lines X–Y: [mô tả]

System Impact Analysis:
[Data flow, dependencies, edge cases, ripple effects]

Requirement Impact: none | [REQ cần thêm/sửa]
Design Impact: none | [Section cần update]
Lessons Learned: [Bất ngờ, cạm bẫy]
Completed At: YYYY-MM-DD
```

### 3. Cập nhật `_index.md`
```markdown
| [TASK-NNN](TASK-NNN.md) | Title | type | Done | YYYY-MM-DD |
```

### 4. Update docs (không cần confirm)
- `Requirement Impact != none` → cập nhật `requirements.md`
- `Design Impact != none` → cập nhật `design.md`
- Thêm `<!-- Last updated: TASK-NNN (YYYY-MM-DD) -->` vào section đã sửa

### 4b. Regression Gate

**Nhánh A — Simple** (Requirement + Design Impact đều none):
1. Map impacted files → spec files tương ứng
2. Chạy: `cd testing && npx [test-runner] [spec-file]`
3. Báo cáo: **X passed / Y failed**

**Nhánh B — Complex** (có Requirement hoặc Design Impact):
1. Xác định REQs bị ảnh hưởng
2. `/qa drift REQ-N` cho từng REQ liên quan
3. Drift nhỏ → fix inline. Drift lớn → tạo task riêng
4. Chạy: `cd testing && npx [test-runner] [spec-file]`
5. Báo cáo: **X passed / Y failed**

**Nếu test fail → đề xuất 3 phương án, chờ user quyết định:**
| Phương án | Khi nào |
|---|---|
| A) Fix source code | Code mới gây regression thực sự |
| B) Fix test case | Test assert sai behavior sau spec change |
| C) Skip có lý do | Test fragile / ngoài scope task này |

### 5. Commit git (cần user confirm)

**Feature:**
```
feat(scope): mô tả ngắn (TASK-NNN)

[Business goal — 1-2 câu]

Changes:
- [file chính: thay đổi gì]

US: US-NNN | REQ: REQ-N
```

**Bugfix:**
```
fix(scope): mô tả ngắn (TASK-NNN)

Root cause: [ngắn gọn]
Fix: [thay đổi chính]
```

**Quick/Refactor:**
```
fix/refactor(scope): mô tả ngắn (TASK-NNN)
```

---

## QUICK FIX

≤30 lines, 1 file — tạo task gọn và implement luôn:

```markdown
## TASK-NNN (Quick Fix)

**Status:** Done
**Type:** quick
**Title:** [Mô tả ngắn]
**Changed:** `path/file` lines X–Y: [mô tả]
**Impact:** none | minor
**Git Commit:** <hash7> — "<subject>" | skipped
**Completed At:** YYYY-MM-DD
```

---

## ARCHIVE

Khi `_index.md` có > 20 task Done:
1. Tạo `.claude/docs/tasks/archive/`
2. Move TASK-NNN.md Done cũ hơn 60 ngày vào `archive/`
3. Cập nhật links trong `_index.md`
