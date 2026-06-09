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

## Subcommands

| Subcommand | Action |
|---|---|
| `/task` | Xác định hành động theo context (xem bên dưới) |
| `/task status` | Hiện dashboard task của role hiện tại |

---

## Bước 1: Xác định hành động

- User **yêu cầu làm việc mới** → **TẠO TASK MỚI**
- User **bảo "làm"** (hoặc: "proceed", "thực hiện", "ok làm đi") → **EXECUTE TASK**
- User **báo task xong** hoặc vừa hoàn thành → **ĐÓNG TASK**
- User **hỏi về task** / **`/task status`** → **MY TASK DASHBOARD**

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
| `tc-draft` | Viết TC skeleton từ requirements trong khi DEV đang implement (shift-left, phase 1) |
| `tc-write` | Finalize + chạy TCs sau khi DEV done (phase 2) |
| `tc-fix` | Sửa TC assert sai behavior |
| `tc-add` | Thêm TC còn thiếu (gap coverage) |
| `matrix-sync` | Cập nhật REQ-Coverage-Matrix sau test run |

---

## MY TASK DASHBOARD (`/task status`)

Hiện tất cả task được assign cho role hiện tại, nhóm theo action cần làm.

### Logic đọc tasks

```bash
# Xác định role từ CLAUDE.md (dòng Role: trong header)
grep "^# CLAUDE\|^Role:\|^## Role" CLAUDE.md | head -3

# Lọc task files theo role
grep -rl "^\*\*Role:\*\* BA" .claude/docs/tasks/TASK-*.md      # ví dụ BA
grep -rl "^\*\*Role:\*\* DEV" .claude/docs/tasks/TASK-*.md     # DEV
grep -rl "^\*\*Role:\*\* QC" .claude/docs/tasks/TASK-*.md      # QC

# Với mỗi task file → đọc Status, Type, Title, US Reference
grep "^\*\*Status:\|^\*\*Type:\|^\*\*Title:\|^\*\*US Reference:" TASK-NNN.md
```

### Output format

```
## My Tasks — [ROLE]
Last sync: YYYY-MM-DD

### 🔴 Action Required
| Task | Title | Type | US | Status |
|------|-------|------|----|--------|
| TASK-007 | Viết ACs — US-001 | req-write | US-001 | Ready |
| TASK-011 | Fix AC sai — US-002 | req-fix | US-002 | Pending Approval |

### 🟡 In Progress
| Task | Title | Type | US |
|------|-------|------|----|
| TASK-005 | Viết ACs — US-003 | req-write | US-003 |

### ⏳ Waiting (Blocked)
| Task | Title | Blocked by | US |
|------|-------|------------|----|
| TASK-010 | Viết ACs — US-004 | TASK-009 (DEV) | US-004 |

### ✅ Done (5 gần nhất)
| Task | Title | Type | Completed |
|------|-------|------|-----------|
| TASK-004 | Viết ACs — US-001-B | req-fix | 2026-06-06 |
```

### Next action hint (in kèm sau section Action Required)

```
👉 Việc cần làm:
   TASK-007 (Ready): Đọc us/US-001.md → điền Approach + Plan → đổi status "Pending Approval"
   TASK-011 (Pending Approval): Chờ confirm "làm" để bắt đầu
```

---

## STATUS LEGEND

| Status | Nghĩa | Ai set |
|--------|-------|--------|
| **Ready** | Stub task do PM tạo, role owner điền Plan rồi chuyển Pending Approval | PM auto-gen |
| **Pending Approval** | Plan đã viết, chờ confirm "làm" | Role owner |
| **In Progress** | Đang thực hiện | Role owner |
| **Blocked ← TASK-N** | Chờ TASK-N hoàn thành trước, chưa thể bắt đầu | PM auto-gen |
| **Blocked ← TASK-A, TASK-B** | Chờ TẤT CẢ tasks trong danh sách Done (parallel deps) | PM auto-gen |
| **Done** | Hoàn thành, đã đóng | Role owner |
| **Cancelled** | Hủy | PM |

### Khi role owner nhận stub task (Ready)

Không tạo task mới — stub đã có sẵn:

1. Mở `TASK-N.md`
2. Đọc US-NNN.md / requirements liên quan
3. Điền **Approach** + **Plan** vào stub
4. Đổi `Status: Ready` → `Status: Pending Approval`
5. Thông báo: *"TASK-N plan đã sẵn sàng. Bảo tôi 'làm' khi muốn thực hiện."*

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

3. **DEV only — Design gate (bắt buộc trước khi code):**
   ```bash
   ls .claude/docs/design/REQ-N.md 2>/dev/null && \
     grep "Status: draft\|Status: done" .claude/docs/design/REQ-N.md \
     || echo "MISSING"
   ```
   - Nếu file **không tồn tại** hoặc **không có Status** → **DỪNG. Chạy `/design draft REQ-N` trước.**
   - Nếu `Status: draft` hoặc `Status: done` → tiếp tục.

   Sau đó đọc context:
   ```bash
   cat .claude/docs/requirements/REQ-N.md   # ACs
   cat .claude/docs/design/REQ-N.md         # design constraint
   # Đọc từng file trong Impacted Files trước khi sửa
   ```

4. **DEV only — Update US status → in-dev ngay khi bắt đầu:**
   ```bash
   # Edit us/US-NNN.md: status: in-dev
   ```

5. Thực hiện đúng theo plan. Nếu plan có vấn đề → thông báo trước, không tự sửa.

4. Cập nhật `Status: In Progress`.

5. Sau khi implement xong → chạy `/design verify REQ-N` trước khi đóng task.

6. Sau khi xong → **ĐÓNG TASK** ngay.

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

### 3. `_index.md` tự động sync

> `tasks/_index.md` được rebuild tự động sau mỗi lần Write/Edit TASK-*.md — **không cần update tay**.  
> Nếu cần rebuild thủ công: `bash .claude/hooks/sync-index.sh`

### 4. Update artifacts liên quan (không cần confirm)

| Role | Khi nào | Cập nhật gì |
|------|---------|-------------|
| DEV | Requirement Impact != none | `requirements/REQ-N.md` + `_index.md` |
| DEV | Design Impact != none | `design/REQ-N.md` + `design/_index.md` |
| DEV | TC Impact != none | Thêm vào handoff commit: `⚠️ TC Impact: [TCs cần update]` để QC biết |
| BA | req-fix/req-clarify | `requirements/REQ-N.md` |
| QC | tc-write/tc-fix/tc-add | `testing/specs/` + `REQ-Coverage-Matrix.md` |

Thêm `<!-- Last updated: TASK-NNN (YYYY-MM-DD) -->` vào file đã sửa.

### 5. Handoff commit (cần user confirm)

```
handoff(US-NNN → ROLE): TASK-NNN done — [mô tả ngắn]
```

| Role hiện tại | Handoff sang |
|---------------|-------------|
| BA (req-write) | `→ DEV` |
| DEV (feature/bugfix) | `→ QC` |
| QC (tc-write, all pass) | `→ PM` |
| QC (fail) | `→ DEV` |

### 6. DEV only — Update US status → in-test + PR

```bash
# Edit us/US-NNN.md: status: in-test
```

**PR Description Template:**
```markdown
## TASK-NNN — [Title]

**US:** US-NNN | **REQ:** REQ-N

### Changed Files
- `src/file`: mô tả thay đổi

### TC Impact
none | [TCs nào cần update — QC cần biết]
```

> Regression Gate do QC chạy sau handoff bằng `/regression task TASK-NNN`.

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
