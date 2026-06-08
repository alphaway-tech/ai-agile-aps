# /drift Skill

Phân tích **spec drift** cho một REQ: so sánh Requirement ACs với source code và test specs, báo cáo chỗ lệch nhau.

Đây là skill **global** — mọi role đều có thể chạy bất cứ lúc nào.

## Usage

```
/drift REQ-N
```

---

## Quy trình

### Bước 1 — Fetch upstream

```bash
git fetch upstream
```

### Bước 2 — Đọc Requirement ACs

```bash
grep -n "### REQ-N" .claude/docs/requirements.md
# → Read requirements.md tại đúng section, limit nhỏ
```

### Bước 3 — Đọc source code on-demand

Không dùng file local. Fetch từ upstream để đảm bảo luôn đọc code mới nhất:

```bash
# Xem danh sách file liên quan
git ls-tree -r upstream/main --name-only | grep src/

# Đọc file cụ thể
git show upstream/main:src/<path/to/file>
```

Dùng grep để xác định function trước, rồi chỉ đọc đúng phần cần thiết:

```bash
git show upstream/main:src/<file> | grep -n "functionName"
```

### Bước 4 — Đọc test specs hiện có

```bash
grep -rn "// REQ-N" testing/specs/
```

> Nếu workspace không có `testing/specs/` (PM, BA, DEV) → bỏ qua bước này, ghi "No TCs yet".

### Bước 5 — So sánh và báo cáo

So sánh từng AC với code và TC:

| Nguồn so sánh | Câu hỏi |
|---|---|
| AC vs Code | Code có implement đúng behavior AC mô tả không? |
| AC vs TC | TC có verify đúng behavior của AC không? |
| Code vs TC | TC assert đúng output của code không? |

### Bước 6 — Output

```
## Drift Report — REQ-N

### AC Coverage
- AC1: ✅ code OK · ✅ TC exists
- AC2: ✅ code OK · ⬜ No TC
- AC3: ⚠️ drift — req nói X, code làm Y

### Drift Details
| AC | Type | Mô tả | Severity |
|----|------|-------|----------|
| AC3 | Req→Code | ... | High/Med/Low |

### Verdict
- Drift found: Y/N
- Suggested action: [tạo task / cập nhật req / viết TC]
```

---

## Severity

| Level | Khi nào | Action |
|-------|---------|--------|
| **High** | Core behavior sai, data integrity risk | Task ngay |
| **Med** | Edge case, có workaround | Plan trong sprint |
| **Low** | Text/wording khác, không ảnh hưởng behavior | Batch fix |
