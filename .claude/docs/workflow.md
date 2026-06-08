# Agile AI APS — Workflow

> **Last updated:** 2026-06-08

---

## 1. Tổng quan

```
                        ┌─────────────────────────────────────┐
                        │              PM                     │
                        │  /pm create US-NNN                  │
                        │  /pm list | /pm done | /pm handoffs │
                        └──────────────┬──────────────────────┘
                                       │ US-NNN.md (draft)
                                       │ Auto-gen 3 stub tasks
                                       │
              ┌────────────────────────┼────────────────────────┐
              │                        │                        │
              ▼                        ▼                        ▼
        TASK-N (BA)            TASK-N+1 (DEV)          TASK-N+2 (QC)
        req-write              feature                  tc-write
        Ready                  Blocked ← TASK-N         Blocked ← TASK-N
                                                        [phase: tc-draft]

              │ handoff → BA           │                        │
              ▼                        │                        ▼
        ┌──────────┐                   │              ┌──────────────────┐
        │    BA    │                   │              │  QC (tc-draft)   │
        │ viết ACs │                   │              │  viết TC skeleton│
        │ REQ-N.md │  ─────────────────┼─────────────►  từ requirements │
        └────┬─────┘   handoff → DEV  │              │  (SONG SONG DEV) │
             │         TASK-N+1       │              └──────────────────┘
             │         unblock        ▼
             │                  ┌──────────┐
             │                  │   DEV    │
             └─────────────────►│ implement│
                                │ src/     │
                                │ /design  │
                                └────┬─────┘
                                     │ handoff → QC
                                     │ TASK-N+2 (tc-run) unblock
                                     ▼
                              ┌─────────────────┐
                              │   QC (tc-run)   │
                              │ /regression     │
                              │ finalize TCs    │
                              │ /qa run         │
                              │ /qa matrix      │
                              └────────┬────────┘
                          ┌───────────┴───────────┐
                         PASS                    FAIL
                          │                        │
                          ▼                        ▼
                   handoff → PM            handoff → DEV
                   US done                 bug report
                          │                (structured)
                          ▼                        │
                   ┌──────────┐                    │
                   │    PM    │◄───────────────────┘
                   │ /pm done │   (nếu 2+ rounds:
                   │ sign-off │    escalate to PM)
                   └──────────┘
```

---

## 2. Vai trò & Ownership

| Role | Owns | Skills | READ-ONLY |
|------|------|--------|-----------|
| **PM** | `us/*.md` | `/pm` | requirements, design, tasks |
| **BA** | `requirements/REQ-N.md` | `/requirements`, `/task`, `/drift` | us, design, testing |
| **DEV** | `src/`, `design/REQ-N.md` | `/task`, `/design`, `/drift` | us, requirements, testing |
| **QC** | `testing/specs/`, `REQ-Coverage-Matrix.md` | `/qa`, `/regression`, `/task`, `/drift` | us, requirements, design (src qua `git show`) |

---

## 3. Lifecycle

### US Status

```
  draft ──► ac-ready ──► in-dev ──► in-test ──► done
   ↑PM        ↑BA          ↑DEV       ↑DEV        ↑PM
            (REQ xong)  (bắt đầu)  (push PR)   (QC 🟢)
```

### Task Status

```
  Ready ──► Pending Approval ──► In Progress ──► Done
   ↑PM auto-gen  ↑role điền plan   ↑user "làm"   ↑role owner
```

---

## 4. Handoff Protocol

Mọi handoff dùng git commit format:

```
handoff(US-NNN → ROLE): TASK-NNN done — [mô tả ngắn]
```

Xem log handoffs:
```bash
git log --oneline --grep="^handoff"
```

### Auto-detection (tự động)

Mỗi khi commit có handoff pattern, script `.claude/hooks/detect-handoff.sh` tự động:
1. Parse US code + target ROLE
2. Tìm task file của ROLE đó cho US đó (Status: Blocked)
3. Đổi Status → **Ready** và stage file
4. Print thông báo cho role nhận

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📬 Handoff: US-001 → QC
   TASK-003: Blocked → Ready (staged)

   👉 QC: mở TASK-003.md
      Điền Approach + Plan → Pending Approval
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Setup (1 lần sau clone):**
```bash
bash .claude/setup-hooks.sh
```

Script tự động chạy qua 2 lớp:
- **Claude Code hook** (`settings.json`) — khi Claude chạy git commit
- **Git post-commit hook** (sau `setup-hooks.sh`) — khi user commit tay

| Từ | Sang | Khi nào |
|----|------|---------|
| PM | BA | US created, TASK-N Ready |
| BA | DEV | requirements/REQ-N.md xong, ac-ready |
| DEV | QC | src/ + design done, in-test |
| QC | PM | All TCs pass, 🟢 |
| QC | DEV | TCs fail — kèm bug report |

---

## 5. Chi tiết từng Role

### PM

```
/pm create US-NNN
  → tạo us/US-NNN.md (status: draft, qc_dev_rounds: 0)
  → auto-gen 3 stub tasks:
     TASK-N   (BA)  req-write → Ready
     TASK-N+1 (DEV) feature   → Blocked ← TASK-N
     TASK-N+2 (QC)  tc-write  → Blocked ← TASK-N [phase: tc-draft]
  → commit + handoff → BA

/pm list        → dashboard tất cả USs
/pm handoffs    → git log handoffs
/pm done US-NNN → confirm US hoàn thành sau QC 🟢
```

---

### BA

```
Nhận: handoff(US-NNN → BA): TASK-N Ready
  │
  ├─ Đọc us/US-NNN.md
  ├─ Mở TASK-N.md → điền Approach + Plan
  ├─ Status: Ready → Pending Approval
  ├─ Chờ user: "làm"
  │
  └─ EXECUTE:
       /requirements US-NNN
         → tạo requirements/REQ-N.md
         → viết ACs dạng WHEN/THEN
         → update US: status → ac-ready, Linked REQs: REQ-N
       TASK-N: Done
       handoff(US-NNN → DEV): "REQ-N ready — X ACs"
       → TASK-N+1 (DEV) unblock
       → TASK-N+2 (QC, tc-draft) unblock  ← đồng thời
```

---

### DEV

```
Nhận: handoff(US-NNN → DEV): TASK-N+1 unblock
  │
  ├─ git pull origin main
  ├─ Đọc: requirements/REQ-N.md + us/US-NNN.md + design/REQ-N.md
  ├─ /task → TASK-N+1.md: Approach + Plan → Pending Approval
  ├─ Chờ user: "làm"
  │
  └─ EXECUTE:
       update US: status → in-dev
       Read context: requirements + design/REQ-N.md + src/ liên quan
       │
       ├─ [Complex task: ≥3 files / data model change]
       │    draft design/REQ-N.md skeleton TRƯỚC khi code
       │
       Implement src/
       /design → tạo/cập nhật design/REQ-N.md
       update US: status → in-test
       TASK-N+1: Done (điền Implementation Summary, Changed Files, TC Impact)
       git push → PR
       handoff(US-NNN → QC): "TASK-N+1 done"
       → TASK-N+2 (QC, tc-run) unblock
```

**PR Description Template:**
```markdown
## TASK-N+1 — [Title]
**US:** US-NNN | **REQ:** REQ-N
### Changed Files
- `src/file`: mô tả
### TC Impact
none | [TCs nào QC cần update]
```

---

### QC

```
Phase 1 — tc-draft (unblock khi BA done TASK-N)
  │
  ├─ git pull origin main
  ├─ Đọc requirements/REQ-N.md
  ├─ Viết TC skeleton: file + describe + test stubs (GIVEN/WHEN/THEN)
  ├─ KHÔNG chạy tests
  └─ git push origin main  ← DEV sẽ pull được khi cần

Phase 2 — tc-run (unblock khi DEV done TASK-N+1)
  │
  ├─ git pull origin main  (lấy src/ mới nhất + design/REQ-N.md)
  │
  ├─ /regression task TASK-N+1
  │    AI phân tích: Changed Files → REQs → TCs (direct + transitive)
  │    Risk: 🔴 High / 🟡 Med / 🟢 Low / ⬜ Skip
  │    Output: bộ TCs khuyến nghị + lệnh chạy
  │    QC xác nhận
  │
  ├─ /qa drift REQ-N  (nếu nghi ngờ spec drift)
  │    Drift disposition:
  │      Req→Code  → DEV bugfix task
  │      Req→TC    → QC tc-fix task
  │      AC mơ hồ  → BA req-clarify task
  │      Không rõ  → PM quyết định
  │
  ├─ Finalize TCs: bổ sung assertions, page objects
  │
  ├─ /qa run REQ-N
  │    ├─ PASS → /qa matrix → Coverage Matrix
  │    │         điền TC Coverage vào TASK-N+1 (DEV task)
  │    │         update US → done
  │    │         handoff(US-NNN → PM): "QC 🟢 all pass"
  │    │
  │    └─ FAIL → Structured Bug Report:
  │               | TC | Expected | Actual | Assessment |
  │               assessment: code bug / TC bug / ambiguous
  │               Severity: blocking / partial
  │               update qc_dev_rounds +1 trong US file
  │               handoff(US-NNN → DEV): "TC fail"
  │               [nếu qc_dev_rounds ≥ 2: ⚠️ Escalate to PM/BA]
  │
  └─ TASK-N+2: Done
```

---

## 6. DEV ↔ QC — Chi tiết tương tác

```
BA done                    DEV                           QC
───────                    ───                           ──
TASK-N+1 unblock ─────────►                             TASK-N+2 unblock (tc-draft)
                            │                            │
                            │ implement                  │ viết TC skeleton
                            │ (parallel)                 │ từ requirements
                            │                            │
                            │                            git push tc-draft
                            │◄────────────────── (DEV có thể pull skeleton)
                            │
                            git push PR
                            handoff → QC ───────────────►
                                                         /regression task TASK-N+1
                                                         AI đề xuất TCs
                                                         │
                                                         finalize TCs
                                                         /qa run
                                              ┌──────────┴──────────┐
                                            PASS                  FAIL
                                              │                     │
                                              ▼                     ▼
                                         /qa matrix          bug report
                                         handoff → PM        qc_dev_rounds +1
                                                             handoff → DEV ──────►
                                                                              DEV fix
                                                             ◄─────────── re-push PR
                                                             [≥2 rounds: escalate PM]
```

---

## 7. Skills Reference

| Skill | Role | Mô tả |
|-------|------|-------|
| `/pm` | PM | Tạo/quản lý User Stories, dashboard, handoffs |
| `/requirements` | BA | Viết ACs từ US, cập nhật REQ |
| `/task` | ALL | Tạo task, execute, đóng task, dashboard |
| `/design` | DEV | Tạo/cập nhật design/REQ-N.md |
| `/qa` | QC | Drift analysis, chạy tests, sync Coverage Matrix |
| `/regression` | QC | Phân tích risk, đề xuất bộ TCs cần chạy |
| `/drift` | ALL | Phát hiện spec drift: AC vs Code vs TC |

---

## 8. File Structure

```
.claude/docs/
├── us/
│   ├── _index.md          ← PM dashboard
│   └── US-NNN.md          ← PM owns (status, qc_dev_rounds)
├── requirements/
│   ├── _index.md
│   └── REQ-N.md           ← BA owns (WHEN/THEN ACs)
├── design/
│   ├── _index.md
│   └── REQ-N.md           ← DEV owns (components, data types, decisions)
└── tasks/
    ├── _index.md          ← all roles update
    └── TASK-NNN.md        ← role owner owns

src/                       ← DEV owns
testing/
├── specs/
│   └── *.spec.ts          ← QC owns (// REQ-N.ACx tags)
└── artifacts/
    ├── report.json        ← generated, không commit
    └── REQ-Coverage-Matrix.md  ← QC owns (source of truth go-live)
```

---

## 9. Go-Live Status (QC → Coverage Matrix)

| Symbol | Nghĩa | Điều kiện |
|--------|-------|-----------|
| 🟢 | Ready | 100% testable ACs covered, tất cả pass, không drift |
| 🟡 | Partial | Không có ❌, còn gap hoặc 🔵 chưa chạy |
| 🔴 | Blocked | Có ❌ fail hoặc spec drift nghiêm trọng |
| ⬛ | Skip | Ngoài scope automation |

> Trước khi đánh 🟢: chạy `/regression task` của task gần nhất để confirm không có regression.
