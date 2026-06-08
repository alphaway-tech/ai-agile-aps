# /qa Skill

Skill này thực hiện QA review theo từng REQ: phát hiện spec drift, cập nhật REQ-Coverage-Matrix, đánh giá go-live readiness.

## Subcommands

| Subcommand | Action |
|---|---|
| `/qa REQ-N` | Full review 1 REQ: drift analysis + coverage + go-live assessment |
| `/qa drift REQ-N` | Chỉ phân tích spec drift, không đánh giá go-live |
| `/qa run REQ-N` | Chạy tests cho REQ-N, đọc kết quả, báo cáo pass/fail |
| `/qa run all` | Chạy full test suite, báo cáo pass/fail per REQ |
| `/qa matrix` | Sync matrix từ `artifacts/report.json` hiện có (không chạy lại tests) |
| `/qa audit-tags` | Kiểm tra tất cả `// REQ-N.ACx` tags trong spec files, báo tag sai/orphan |

Không có subcommand → hiển thị tóm tắt matrix + list REQ cần attention.

## Typical flow

```
/qa drift REQ-N          # phân tích drift
  → phát hiện vấn đề
  → tạo task → sửa TCs / req / code
/qa run REQ-N            # chạy tests sau khi sửa
  → đọc kết quả
/qa matrix               # sync matrix từ kết quả mới
```

---

## Go-Live Readiness

Mỗi REQ trong matrix có cột **GoLive** với 4 trạng thái:

| Symbol | Nghĩa | Tiêu chí |
|--------|-------|----------|
| 🟢 | Ready | 100% **testable** ACs covered (⏭ skip không tính), tất cả TCs pass, không có drift đã biết |
| 🟡 | Partial | Không có ❌, nhưng còn gap hoặc 🔵 (chưa chạy) |
| 🔴 | Blocked | Có ❌ fail, hoặc có spec drift nghiêm trọng chưa resolve |
| ⬛ | Skip | Ngoài scope automation (REQ-12/13/14) |

> **Lưu ý tiêu chí 🟢:** AC được đánh ⏭ (intentional skip) không ảnh hưởng đến go-live. Ví dụ REQ-1 có AC5 skip → vẫn có thể đạt 🟢 khi AC1/2/3/4/6 đều pass.

> **Trước khi đánh 🟢 cho bất kỳ REQ nào:** chạy `/qa run all` để xác nhận không có cross-REQ regression.

---

## Quy trình `/qa REQ-N`

> Yêu cầu đã có kết quả test trong `artifacts/report.json`. Nếu chưa → chạy `/qa run REQ-N` trước.

### Bước 1 — Đọc 4 nguồn (targeted reads)

```bash
# 1. Requirement ACs
cat .claude/docs/requirements/REQ-N.md

# 2. Tests hiện có
grep -rn "// REQ-N" testing/specs/

# 3. Code thực thi — fetch on-demand từ upstream (QC không có src/ local)
git fetch upstream
git ls-tree -r upstream/main --name-only | grep src/
git show upstream/main:src/<path/to/file.ts>

# 4. Design của REQ
cat .claude/docs/design/REQ-N.md
```

> **Lưu ý:** QC workspace không có `src/` local. Mọi thao tác đọc source code đều qua
> `git show upstream/main:src/...` — chỉ đọc, không thể commit hay sửa src.

**Rule:** không `Read` cả file khi chỉ cần 1-2 function. Dùng grep để xác định offset trước, rồi Read với limit nhỏ.

### Bước 2 — Phân tích Spec Drift

So sánh từng AC trong requirement với:

| Nguồn | Câu hỏi |
|-------|---------|
| Code | Logic có làm đúng như AC mô tả không? |
| TCs | Test có verify đúng behavior của AC không? |
| Design | Design có consistent với AC không? |

**Drift categories:**
- **Req → Code drift**: Code làm khác requirement (như TASK-012: floor→ceil, sum=→sum≥)
- **Req → TC drift**: Test assert sai behavior (test floor nhưng code ceil)
- **Coverage gap**: AC có trong req nhưng không có TC
- **Orphan TC**: TC tồn tại nhưng AC tương ứng đã bị xóa/thay đổi

### Bước 3 — Output phân tích

```
## REQ-N: [Tên]

### Coverage
- AC1: ✅ covered — TC: "tên test" — Latest: ✅/❌/🔵
- AC2: ⬜ gap
...

### Spec Drift
| AC | Drift type | Mô tả | Severity |
|---|---|---|---|
| AC2 | Req→Code | Req nói X, code làm Y | High/Med/Low |

### Go-Live Assessment
**Status: 🟢/🟡/🔴**
- Blocker: [nếu có]
- Risk: [nếu có]
```

### Bước 4 — Đề xuất action

Nếu phát hiện drift hoặc gap:
- **Không tự sửa** — đề xuất tạo task
- Phân loại rõ: sửa `requirement`, sửa `test code`, sửa `source code`, hoặc combo
- Ưu tiên theo severity: High → cần task ngay; Med → plan trong sprint; Low → nice-to-have

---

## Quy trình `/qa run REQ-N` và `/qa run all`

Chạy tests và báo cáo kết quả. Không phân tích drift, không cập nhật matrix.

```bash
# Chạy 1 REQ
cd testing && npx playwright test <spec>.spec.ts --grep "REQ-N"

# Chạy full suite (dùng trước khi đánh 🟢)
cd testing && npx playwright test
```

Sau khi chạy xong:
- Báo pass/fail count per REQ
- Nếu có fail: đọc `testing/artifacts/error-contexts/*.md` → tóm tắt root cause từng test fail
- Hỏi user có muốn `/qa matrix` để sync không

---

## Quy trình `/qa matrix`

> Không tự chạy lại tests — dùng `artifacts/report.json` từ lần chạy gần nhất.

### Bước 1 — Parse kết quả test (dùng script, không Read raw JSON)

```bash
python3 -c "
import json

def walk(suite):
    for spec in suite.get('specs', []):
        ok = spec['tests'][0]['status'] == 'expected'
        print('PASS' if ok else 'FAIL', spec['title'])
    for s in suite.get('suites', []):
        walk(s)

r = json.load(open('testing/artifacts/report.json'))
for suite in r.get('suites', []):
    walk(suite)
"
```

Dùng script này thay vì `Read(artifacts/report.json)` để tiết kiệm token.

### Bước 2 — Map TC → AC

```bash
grep -rn "// REQ-[0-9]*" testing/specs/
```

Tag format `// REQ-N.ACx` trên dòng ngay trên `test(` → biết TC đó cover AC nào.

### Bước 3 — Fill TC Coverage vào TASK (sau khi viết TCs)

Sau khi viết xong TCs cho REQ-N, tìm TASK tương ứng và update:

```bash
# Tìm TASK implement REQ-N
grep -rn "REQ-N" .claude/docs/tasks/TASK-*.md | grep "Requirement References"
```

Mở `tasks/TASK-NNN.md`, điền vào section `## TC Coverage`:

```markdown
## TC Coverage
| AC | Test name | Spec file |
|----|-----------|-----------|
| AC1 | tên test case | testing/specs/xxx.spec.ts |
| AC2 | tên test case | testing/specs/xxx.spec.ts |
```

Push TASK file đã update lên master để DEV và PM biết TCs nào đang verify task của họ.

### Bước 3–5 — Cập nhật matrix

3. Cập nhật cột ✅ Pass / ❌ Fail / 🔵 Not run cho từng REQ
4. Cập nhật Total row + Overall metrics (RC, AC, PC)
5. Đánh giá lại cột GoLive theo tiêu chí đã định nghĩa

---

## Quy trình `/qa audit-tags`

Kiểm tra tính chính xác của `// REQ-N.ACx` tags — phát hiện tag sai hoặc orphan.

### Bước 1 — Extract tất cả tags

```bash
grep -rn "// REQ-[0-9]*\." testing/specs/ | grep -o "REQ-[0-9]*\.AC[0-9]*" | sort -u
```

### Bước 2 — Lấy AC list từ requirements

```bash
grep -n "^- WHEN" .claude/docs/requirements.md
```

Đếm số ACs theo từng REQ để biết range hợp lệ (VD: REQ-1 có AC1–AC6).

### Bước 3 — So sánh & báo cáo

Báo cáo:
- **Orphan tags**: tag `REQ-N.ACx` nhưng AC đó không tồn tại trong requirements
- **Out-of-range tags**: `REQ-1.AC9` khi REQ-1 chỉ có AC1–AC6
- **Untagged tests**: test không có `// REQ-N` tag → không được track trong matrix

---

## Severity của Spec Drift

| Severity | Định nghĩa | Action |
|----------|-----------|--------|
| **High** | Core behavior sai — user bị ảnh hưởng, data integrity risk | Task ngay |
| **Med** | Behavior khác nhưng workaround tồn tại, hoặc edge case | Plan trong sprint |
| **Low** | Text/wording không khớp, không ảnh hưởng behavior | Batch fix |

---

## Nguồn tham chiếu

| File | Vai trò |
|------|---------|
| `testing/artifacts/REQ-Coverage-Matrix.md` | Source of truth cho go-live status |
| `.claude/docs/requirements.md` | Requirement ACs |
| `.claude/docs/design.md` | Design decisions |
| `testing/specs/*.spec.ts` | Test cases |
| `src/lib/*.ts`, `src/components/*.tsx` | Source code |
| `testing/artifacts/report.json` | Latest test results (parse bằng script, không Read raw) |
