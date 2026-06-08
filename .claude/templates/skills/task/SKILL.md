---
description: Tạo và quản lý task — global skill cho mọi role, mỗi artifact change phải có task
---

# /task Skill

**Global skill** — mọi role đều dùng khi có công việc thay đổi artifact thuộc scope của mình.

## Nguyên tắc cốt lõi

> Bất kỳ thay đổi nào đến `src/`, `design/`, `requirements/`, `testing/specs/`, `REQ-Coverage-Matrix.md` đều **phải có task** tương ứng, do role owner của artifact đó tạo.

| Role | Tạo task khi thay đổi |
|------|----------------------|
| DEV  | `src/`, `design/REQ-N.md` |
| BA   | `requirements/REQ-N.md` |
| QC   | `testing/specs/`, `REQ-Coverage-Matrix.md` |

---

## Bước 1: Xác định hành động

- User **yêu cầu làm việc mới** → **TẠO TASK MỚI**
- User **bảo "làm"** (hoặc: "proceed", "thực hiện", "ok làm đi") → **EXECUTE TASK**
- User **báo task xong** hoặc vừa hoàn thành → **ĐÓNG TASK**
- User **hỏi về task** → đọc `.claude/docs/tasks/_index.md` và trả lời

---

## PHÂN LOẠI TASK

### DEV tasks
| Type | Khi nào |
|------|---------|
| `feature` | Implement tính năng mới từ REQ |
| `bugfix` | Fix lỗi trong src/ (QC báo hoặc tự phát hiện) |
| `refactor` | Cải thiện code không đổi behavior |
| `design-update` | Cập nhật design/REQ-N.md sau thay đổi architecture |
| `quick` | ≤30 lines, 1 file, không có logic mới |

### BA tasks
| Type | Khi nào |
|------|---------|
| `req-write` | Viết REQ mới từ US |
| `req-fix` | Sửa AC sai sau drift analysis |
| `req-clarify` | Làm rõ AC mơ hồ sau phản hồi từ DEV/QC |

### QC tasks
| Type | Khi nào |
|------|---------|
| `tc-write` | Viết TCs lần đầu cho REQ |
| `tc-fix` | Sửa TC assert sai behavior |
| `tc-add` | Thêm TC còn thiếu (gap coverage) |
| `matrix-sync` | Cập nhật REQ-Coverage-Matrix sau test run |

---

## TẠO TASK MỚI

### 1. Chuẩn bị — đọc theo role và task type

**DEV:**
```bash
cat .claude/docs/requirements/REQ-N.md   # hiểu ACs cần implement
cat .claude/docs/design/REQ-N.md         # hiểu design hiện tại
ls .claude/docs/tasks/TASK-*.md | sort -V | tail -1  # lấy ID tiếp theo
```

**BA:**
```bash
cat .claude/docs/us/US-NNN.md            # hiểu business context
cat .claude/docs/requirements/REQ-N.md   # xem ACs hiện tại (nếu req-fix)
ls .claude/docs/tasks/TASK-*.md | sort -V | tail -1
```

**QC:**
```bash
cat .claude/docs/requirements/REQ-N.md   # nguồn để viết TCs
grep -rn "// REQ-N" testing/specs/       # TCs hiện có
ls .claude/docs/tasks/TASK-*.md | sort -V | tail -1
```

### 2. Viết task file

**KHÔNG dùng EnterPlanMode/ExitPlanMode.** Plan đi thẳng vào task file.

Tạo `.claude/docs/tasks/TASK-NNN.md`:

```markdown
## TASK-NNN

**Role:** DEV | BA | QC
**Status:** Pending Approval
**Type:** [xem bảng phân loại trên]
**Title:** [Tên ngắn gọn]
**Business Goal:** [Tại sao cần làm]

**US Reference:** US-NNN
**Requirement References:** REQ-N.ACx → [requirements/REQ-N.md](../requirements/REQ-N.md)
**Design References:** [design/REQ-N.md](../design/REQ-N.md)

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
**Design Impact:** none | [design/REQ-N.md — section nào]
**TC Impact:** none | [TCs nào cần update/thêm]

---
*(Implementation Summary sẽ điền sau khi xong)*

## TC Coverage
<!-- QC điền sau khi viết TCs (chỉ áp dụng với DEV feature/bugfix tasks) -->
| AC | Test name | Spec file |
|----|-----------|-----------|
```

Thêm vào đầu bảng `_index.md`:
```markdown
| [TASK-NNN](TASK-NNN.md) | Role | Title | type | Pending Approval | — |
```

### 3. Thông báo
*"TASK-NNN đã sẵn sàng. Bảo tôi 'làm' khi muốn thực hiện."*

**Không tự động thực hiện. Chờ user bảo "làm".**

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

2. Đọc kỹ: Role, Type, Approach, Plan, AC, Impacted Files.
   **Plan là intent** — luôn đọc artifact thực tế trước khi thay đổi.

3. Thực hiện đúng theo plan. Nếu plan có vấn đề → thông báo trước, không tự sửa.

4. Cập nhật `Status: In Progress`.

5. Sau khi xong → **ĐÓNG TASK** ngay.

---

## ĐÓNG TASK

### 1. Phân tích impact
Đọc toàn bộ artifact đã sửa + dependencies. Xác định ripple effects.

### 2. Cập nhật file task

```
**Status:** Done

Implementation Summary: [1-3 câu mô tả những gì đã thay đổi]

Changed Files:
- `path/file`: [mô tả thay đổi]

System Impact Analysis:
[Data flow, dependencies, edge cases, ripple effects]

Requirement Impact: none | [REQ nào cần thêm/sửa]
Design Impact: none | [design/REQ-N.md — section nào]
TC Impact: none | [TCs nào cần update/thêm]
Lessons Learned: [Bất ngờ, cạm bẫy — bắt buộc với bugfix/tc-fix]
Completed At: YYYY-MM-DD
```

### 3. Cập nhật `_index.md`
```markdown
| [TASK-NNN](TASK-NNN.md) | Role | Title | type | Done | YYYY-MM-DD |
```

### 4. Update artifacts liên quan (không cần confirm)

| Role | Khi nào | Cập nhật gì |
|------|---------|-------------|
| DEV | Requirement Impact != none | `requirements/REQ-N.md` + `_index.md` |
| DEV | Design Impact != none | `design/REQ-N.md` + `design/_index.md` |
| BA | req-fix/req-clarify | `requirements/REQ-N.md` |
| QC | tc-write/tc-fix/tc-add | `testing/specs/` + `REQ-Coverage-Matrix.md` |

Thêm `<!-- Last updated: TASK-NNN (YYYY-MM-DD) -->` vào file đã sửa.

### 5. Regression Gate (DEV tasks only)

**Nhánh A — Simple** (Requirement + Design Impact đều none):
1. Map impacted files → spec files tương ứng
2. Chạy: `cd testing && npx [test-runner] [spec-file]`
3. Báo cáo: **X passed / Y failed**

**Nhánh B — Complex** (có Requirement hoặc Design Impact):
1. Xác định REQs bị ảnh hưởng
2. `/drift REQ-N` cho từng REQ liên quan
3. Drift nhỏ → fix inline. Drift lớn → BA tạo `req-fix` task riêng
4. Chạy: `cd testing && npx [test-runner] [spec-file]`
5. Báo cáo: **X passed / Y failed**

**Nếu test fail → đề xuất 3 phương án:**
| Phương án | Khi nào |
|---|---|
| A) Fix source code | Code mới gây regression thực sự |
| B) QC tạo tc-fix task | TC assert sai behavior sau spec change |
| C) Skip có lý do | Test fragile / ngoài scope task này |

### 6. Handoff commit (cần user confirm)

```
handoff(US-NNN → ROLE): TASK-NNN done — [mô tả ngắn]
```

| Role hiện tại | Handoff sang |
|---------------|-------------|
| BA (req-write) | `→ DEV` |
| DEV (feature/bugfix) | `→ QC` |
| QC (tc-write, all pass) | `→ PM` |
| QC (fail) | `→ DEV` |

---

## QUICK TASK

≤30 lines, 1 file — tạo và implement ngay:

```markdown
## TASK-NNN (Quick)

**Role:** DEV | BA | QC
**Status:** Done
**Type:** quick
**Title:** [Mô tả ngắn]
**Changed:** `path/file`: [mô tả]
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
