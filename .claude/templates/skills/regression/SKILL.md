---
description: Phân tích regression risk và đề xuất bộ TCs cần chạy — QC quyết định có chạy hay không
---

# /regression Skill

Skill này dành cho **QC**. Nhận một input (task, drift, commit, hoặc file), AI phân tích scope thay đổi, map sang TCs liên quan, đánh giá risk, và đưa ra khuyến nghị bộ TCs cần regression. **QC quyết định có chạy hay không.**

## Subcommands

| Subcommand | Input | Khi nào dùng |
|---|---|---|
| `/regression task TASK-NNN` | Task file | Sau khi DEV handoff — phân tích những gì DEV đã thay đổi |
| `/regression drift REQ-N` | Drift report | Khi phát hiện spec drift — TCs nào bị ảnh hưởng |
| `/regression commit <hash>` | Git commit | Review một commit cụ thể — không qua task |
| `/regression file src/path/file.ts` | Source file | Khi cần biết file này liên quan đến TCs nào |

Không có subcommand → hỏi QC muốn phân tích gì.

---

## Quy trình chung (áp dụng cho mọi subcommand)

```
Bước 1 — Thu thập scope thay đổi
Bước 2 — Map scope → REQs bị ảnh hưởng
Bước 3 — Map REQs → TCs (direct + transitive)
Bước 4 — Đánh giá risk từng TC
Bước 5 — Output khuyến nghị
Bước 6 — QC xác nhận → (tùy chọn) chạy tests
```

---

## Bước 1 — Thu thập scope theo input type

### `/regression task TASK-NNN`

```bash
cat .claude/docs/tasks/TASK-NNN.md
# Đọc: Changed Files, Requirement References, TC Impact, System Impact Analysis
```

Scope = tập hợp:
- Files đã thay đổi (từ `Changed Files`)
- REQs tham chiếu (từ `Requirement References`)
- TC Impact đã khai báo (từ `TC Impact`)

### `/regression drift REQ-N`

```bash
cat .claude/docs/requirements/REQ-N.md
grep -rn "// REQ-N" testing/specs/
```

Chạy `/drift REQ-N` nếu chưa có drift report. Scope = các ACs có drift.

### `/regression commit <hash>`

```bash
git show <hash> --stat          # danh sách files thay đổi
git show <hash> --unified=0     # nội dung thay đổi (không cần full diff)
```

Scope = files thay đổi trong commit.

### `/regression file src/path/file.ts`

```bash
git log --oneline -5 -- src/path/file.ts   # commits gần nhất
grep -rn "// REQ-" testing/specs/           # xem TCs nào tag REQ liên quan
```

Scope = file đó + các file import nó (nếu cần).

---

## Bước 2 — Map scope → REQs bị ảnh hưởng

Với mỗi file trong scope:

```bash
# Tìm REQ nào design file đó
grep -rn "src/path/file" .claude/docs/design/REQ-*.md

# Tìm REQ nào requirement mention behavior của file đó
grep -rn "file\|ComponentName" .claude/docs/requirements/REQ-*.md

# Tìm TCs đang tag file đó (gián tiếp qua REQ tag)
grep -rn "// REQ-" testing/specs/ | grep -i "keyword_from_file"
```

Kết quả: danh sách REQ-N bị ảnh hưởng **trực tiếp**.

**Transitive impact** — REQ có thể bị ảnh hưởng gián tiếp nếu:
- Dùng chung component/module với REQ bị ảnh hưởng trực tiếp
- Dùng chung data model (đọc/ghi cùng entity)
- Import từ file đã thay đổi

```bash
# Tìm files khác import file bị thay đổi
grep -rn "import.*from.*changed-file" src/
# → có thêm file B, C bị ảnh hưởng
# → map B, C sang REQ khác
```

---

## Bước 3 — Map REQs → TCs

```bash
# TCs cover REQ-N (direct)
grep -rn "// REQ-N" testing/specs/

# Đọc spec file để lấy tên từng test
grep -n "test(" testing/specs/req-n.spec.ts
```

Phân loại:
- **Direct TCs**: tag `// REQ-N.ACx` trực tiếp vào REQ bị ảnh hưởng
- **Transitive TCs**: tag vào REQ khác nhưng dùng chung component/data

---

## Bước 4 — Đánh giá risk từng TC

| Risk | Tiêu chí | Hành động đề xuất |
|------|----------|-------------------|
| 🔴 High | TC test trực tiếp behavior của code đã thay đổi | **Phải chạy** |
| 🟡 Med | TC dùng chung component/module bị thay đổi | Nên chạy |
| 🟢 Low | TC thuộc REQ khác, chỉ share data model | Chạy nếu có thời gian |
| ⬜ Skip | TC không liên quan đến scope thay đổi | Bỏ qua |

**Rule xác định risk:**
- Cùng file bị sửa → 🔴
- Import file bị sửa → 🟡
- Cùng entity/store nhưng không import trực tiếp → 🟡
- Khác module hoàn toàn → 🟢 hoặc ⬜

---

## Bước 5 — Output khuyến nghị

```
## Regression Analysis — [source: TASK-NNN / drift REQ-N / commit abc1234]

### Scope thay đổi
[Tóm tắt: file nào thay đổi, behavior gì bị ảnh hưởng]

### REQs bị ảnh hưởng
- REQ-N (direct): [lý do]
- REQ-M (transitive): [lý do — dùng chung X]

### Khuyến nghị TCs

| Risk | REQ | AC | Test | Spec file | Lý do |
|------|-----|----|------|-----------|-------|
| 🔴 | REQ-1 | AC3 | "delete confirm xóa vĩnh viễn" | todo.spec.ts | trực tiếp test TodoStore.delete() đã sửa |
| 🟡 | REQ-2 | AC1 | "filter pending chỉ hiện pending" | filter.spec.ts | dùng chung TodoStore |
| 🟢 | REQ-3 | AC2 | "auth redirect khi chưa login" | auth.spec.ts | khác module |

### TCs không cần chạy
- REQ-4 (tất cả) — module hoàn toàn tách biệt

### Lệnh chạy đề xuất

```bash
# Chạy High + Med (khuyến nghị)
cd testing && npx playwright test todo.spec.ts filter.spec.ts

# Chạy full nếu muốn chắc chắn
cd testing && npx playwright test
```

### Verdict
🔴 **Phải chạy:** REQ-1 (AC3), REQ-2 (AC1)
🟡 **Nên chạy:** REQ-2 (AC3, AC5)
🟢 **Tuỳ QC:** REQ-3
```

---

## Bước 6 — QC xác nhận và chạy (optional)

Sau khi QC đọc khuyến nghị:

```
QC: "chạy" / "chạy hết" / "chạy high only" / "skip"
```

Nếu chạy → `/qa run REQ-N` cho từng REQ trong danh sách.

Sau khi có kết quả:
- Pass → `/qa matrix` để sync Coverage Matrix
- Fail → xác định root cause → tạo task phù hợp (bugfix/tc-fix)

---

## Khi nào QC nên chạy `/regression`

| Trigger | Subcommand |
|---------|-----------|
| Nhận handoff từ DEV (TASK-NNN done) | `/regression task TASK-NNN` |
| Phát hiện drift sau `/qa drift` | `/regression drift REQ-N` |
| Review một commit bất kỳ | `/regression commit <hash>` |
| Nghi ngờ một file gây vấn đề | `/regression file src/...` |
| Trước khi đánh 🟢 cho bất kỳ REQ | `/regression task` của task gần nhất |
