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

> **Regression Gate** được xử lý bởi `/regression` skill riêng — dùng trước khi chạy `/qa run`.

## Typical flow

```
# Khi nhận handoff từ DEV (TASK-NNN done):
/regression task TASK-NNN   # AI phân tích scope thay đổi → đề xuất TCs cần chạy
  → QC xác nhận bộ TCs

/qa drift REQ-N             # phân tích drift (nếu cần)
  → phát hiện vấn đề
  → tạo task → sửa TCs / req / code

/qa run REQ-N               # chạy TCs đã được đề xuất
  → đọc kết quả

/qa matrix                  # sync Coverage Matrix từ kết quả
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

### Bước 1 — Đọc nguồn (targeted reads)

```bash
# 1. Requirement ACs
cat .claude/docs/requirements/REQ-N.md

# 2. Design của REQ — đọc trước khi xem code
cat .claude/docs/design/REQ-N.md
# Chú ý: Status: draft (DEV đang implement) hoặc done (đã verify)
# Đọc kỹ section "Test Entry Points" — QC dùng để viết tc-draft

# 3. Tests hiện có
grep -rn "// REQ-N" testing/specs/

# 4. Code thực thi — chỉ khi design/REQ-N.md chưa đủ rõ
git fetch origin
git ls-tree -r origin/main --name-only | grep src/
git show origin/main:src/<path/to/file.ts>
```

> **Thứ tự ưu tiên đọc: requirements → design → code**  
> Design đã có section "Test Entry Points" — QC không cần đọc src/ để viết tc-draft.  
> Chỉ đọc src/ khi design chưa đủ hoặc có deviation được ghi trong design.

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

### Bước 4 — Drift Disposition Protocol

Nếu phát hiện drift — **không tự sửa**. Dùng decision tree sau để chọn đúng task type:

| Drift type | Nguyên nhân | Action |
|---|---|---|
| Req → Code | Code làm sai so với AC | DEV tạo `bugfix` task |
| Req → TC | TC assert sai behavior (AC đúng, test sai) | QC tạo `tc-fix` task |
| AC ambiguous | AC mơ hồ, code và TC diễn giải khác nhau | BA tạo `req-clarify` task |
| Ambiguous | Không xác định được | Flag trong US file: `⚠️ Drift unresolved — cần PM quyết định` |

Ưu tiên theo severity: High → task ngay; Med → plan trong sprint; Low → batch fix.

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

### Bước 3 — Fill TC Coverage vào DEV task (P5)

Sau khi finalize TCs (phase tc-run), QC điền `## TC Coverage` vào **TASK-N+1 (DEV task)**, không phải TASK-N+2:

```bash
# Tìm TASK DEV implement REQ-N
grep -rn "REQ-N" .claude/docs/tasks/TASK-*.md | grep "Requirement References"
# → lấy TASK-N+1 (Role: DEV)
```

Mở `tasks/TASK-N+1.md` (DEV task), điền vào section `## TC Coverage`:

```markdown
## TC Coverage
| AC | Test name | Spec file |
|----|-----------|-----------|
| AC1 | tên test case | testing/specs/xxx.spec.ts |
| AC2 | tên test case | testing/specs/xxx.spec.ts |
```

Trong TASK-N+2 (QC task), để: `## TC Coverage → Xem TASK-N+1`

Push cả 2 TASK files lên để DEV và PM biết TCs nào đang verify task DEV.

### Bước 4 — Handoff commit

#### Khi pass 🟢 → PM

```bash
# Update US status
# Edit us/US-NNN.md: status → done (nếu tất cả REQs của US đều 🟢)
```

Commit với handoff format:
```
handoff(US-NNN → PM): QC 🟢 — REQ-N all pass, ready for sign-off
```

PM nhận tín hiệu: `git log --oneline --grep="handoff.*PM"`

---

#### Khi fail ❌ → DEV (P2 — Structured Bug Report)

Bắt buộc kèm bug report chi tiết trong commit message hoặc file `TASK-N+2.md`:

```
handoff(US-NNN → DEV): TC fail — TASK-N+2

## Bug Report
| TC | Expected | Actual | Assessment |
|----|----------|--------|------------|
| "tên test" | X | Y | code bug / TC bug / ambiguous |

Severity: blocking (N/M fail) / partial (N/M fail)
```

**Assessment guide:**
- `code bug` — AC rõ ràng, code làm sai → DEV fix src
- `TC bug` — AC rõ ràng, test assert sai → QC tự fix (tc-fix task), không cần DEV
- `ambiguous` — không chắc → ghi rõ câu hỏi để DEV trả lời

> **Lưu ý:** Trước khi handoff về DEV, tự hỏi: *"TC này có thể là TC viết sai không?"* — nếu có → tạo `tc-fix` task và tự fix trước, tránh ping-pong không cần thiết.

---

#### Round-limit Escalation (P4)

Mỗi lần QC handoff ngược về DEV → tăng `qc_dev_rounds` trong frontmatter `us/US-NNN.md`:

```bash
# Đọc số hiện tại
grep "qc_dev_rounds" .claude/docs/us/US-NNN.md
# → edit: qc_dev_rounds: N+1
```

Nếu `qc_dev_rounds >= 2`:

```
⚠️ Escalate: US-NNN đã ping-pong DEV↔QC 2+ lần.
   PM/BA cần tham gia xác nhận: AC có đúng không? Code có đúng không?
```

Thêm note này vào commit message của handoff và vào section `GoLive Status` trong `us/US-NNN.md`.

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
