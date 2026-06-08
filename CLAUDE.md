# CLAUDE.md — Agile AI APS (Template)

## Tổng quan

**Agile AI APS** là bộ khung workflow tích hợp Claude Code cho team 4 roles: **PM → BA → DEV → TEST**.  
Mỗi role sử dụng workspace riêng, phối hợp qua `project-master` repo.

> Thay `[PROJECT_NAME]` bằng tên project thực tế sau khi init.

---

## Workflow Skills — Auto-load

**Khi bắt đầu session, ĐỌC NGAY các file sau:**

| Role | Files cần đọc |
|------|--------------|
| PM | `.claude/skills/pm/SKILL.md` |
| BA | `.claude/skills/requirements/SKILL.md` |
| DEV | `.claude/skills/task/SKILL.md` · `.claude/skills/design/SKILL.md` |
| TEST | `.claude/skills/testing/SKILL.md` · `.claude/skills/qa/SKILL.md` |

Sau khi đọc, xác nhận: *"Đã load workflow skills — role: [PM/BA/DEV/TEST]."*

---

## Chain Workflow

```
PM tạo US-NNN  →  BA viết ACs (REQ-N)  →  DEV implement (TASK-NNN)  →  TEST viết TCs + chạy QA
     ↓                   ↓                        ↓                            ↓
 us/_index.md      requirements.md           design.md                REQ-Coverage-Matrix
```

### Handoff Protocol

```
PM  → commit "us: US-NNN — [title] [ac-ready]"  → ping BA
BA  → commit "req: REQ-N — ACs finalized"        → ping DEV  
DEV → commit "feat: REQ-N implementation"        → ping TEST
TEST→ commit "test: REQ-N — 🟢/🟡/🔴"           → ping PM
```

---

## Document Ownership

| Document | Owner | Ai được sửa |
|----------|-------|-------------|
| `.claude/docs/us/*.md` | PM | PM + status field (BA/DEV/TEST) |
| `.claude/docs/requirements.md` | BA | BA only |
| `.claude/docs/design.md` | DEV | DEV only |
| `.claude/docs/tasks/*.md` | DEV | DEV only |
| `testing/specs/` | TEST | TEST only |
| `testing/artifacts/REQ-Coverage-Matrix.md` | TEST | TEST only |

---

## Rules

1. Không implement feature khi chưa có task được approve trong `tasks/`.

2. Mỗi task phải:
   - Có file `tasks/TASK-NNN.md` với plan bên trong
   - Tham chiếu US code + REQ code + Design section
   - **Không dùng EnterPlanMode/ExitPlanMode** — plan đi thẳng vào task file
   - Chờ user bảo "làm" mới implement

3. Sau khi implement xong:
   - Đóng task: điền Implementation Summary, Changed Files, System Impact
   - Cập nhật `requirements.md` + `design.md` ngay (không cần confirm riêng)
   - Hỏi user commit git

4. `tasks/`, `requirements.md`, `design.md`, `us/` có thể cập nhật tự do — **approval chỉ cần cho task execution**.

5. Task types:
   - `feature` — full flow + full impact analysis
   - `bugfix` — Lessons Learned bắt buộc
   - `refactor` — không cần update requirements
   - `quick` — ≤30 lines, 1 file, không cần plan mode

6. Task format: TASK-001, TASK-002... US format: US-001, US-002...

7. Mỗi task tham chiếu: US code, Requirements section, Design section, Impacted files.

---

## Sync với Master Repo

```bash
# Chạy trước khi bắt đầu mỗi session
./sync.sh
```

Xem `sync.sh` để biết chi tiết.
