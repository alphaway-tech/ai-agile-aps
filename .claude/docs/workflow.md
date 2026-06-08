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

## 2. Manual vs Automated — Per Role

> **🤖 Tự động** = script/hook chạy không cần user trigger  
> **🧠 AI-assisted** = Claude Code thực hiện khi user gọi skill/command  
> **✍️ Thủ công** = user phải tự làm, không có automation

---

### PM

| Bước | Loại | Chi tiết |
|------|------|---------|
| Tạo US-NNN.md | 🧠 AI-assisted | `/pm create US-NNN` — Claude Code viết file |
| Auto-gen 3 stub tasks | 🧠 AI-assisted | Trong `/pm create` — Claude tạo TASK-N, N+1, N+2 |
| Cập nhật `us/_index.md` | 🤖 Tự động | `sync-index.sh` chạy ngay sau Write/Edit US-NNN.md |
| Cập nhật `tasks/_index.md` | 🤖 Tự động | `sync-index.sh` chạy ngay sau Write/Edit TASK-*.md |
| Nhận báo cáo QC 🟢 | ✍️ Thủ công | Đọc git log / handoff message |
| `/pm done US-NNN` | 🧠 AI-assisted | Claude update status → done |
| Xem handoff log | 🧠 AI-assisted | `/pm handoffs` → `git log --grep="handoff"` |

**Còn thủ công:** quyết định priority, sprint assignment, escalation khi qc_dev_rounds ≥ 2.

---

### BA

| Bước | Loại | Chi tiết |
|------|------|---------|
| Nhận handoff từ PM | 🤖 Tự động | `detect-handoff.sh` đổi TASK-N → **Ready** khi PM commit |
| Đọc US-NNN.md | ✍️ Thủ công | BA tự đọc business context |
| Viết requirements/REQ-N.md | 🧠 AI-assisted | `/requirements US-NNN` — Claude Code viết ACs |
| Update US status → ac-ready | 🧠 AI-assisted | Trong `/requirements` workflow |
| Cập nhật `tasks/_index.md` | 🤖 Tự động | `sync-index.sh` sau khi TASK-N.md được Edit |
| Commit + handoff → DEV | ✍️ Thủ công | BA tự commit đúng format `handoff(US-NNN → DEV)` |
| TASK-N+1 unblock | 🤖 Tự động | `detect-handoff.sh` đổi DEV task → Ready |
| TASK-N+2 unblock (tc-draft) | 🤖 Tự động | `detect-handoff.sh` đổi QC task → Ready |

**Còn thủ công:** phán đoán AC (WHEN/THEN), xác định edge cases, quyết định scope.

---

### DEV

| Bước | Loại | Chi tiết |
|------|------|---------|
| Nhận handoff từ BA | 🤖 Tự động | `detect-handoff.sh` đổi TASK-N+1 → **Ready** |
| git pull | ✍️ Thủ công | DEV tự pull trước khi bắt đầu |
| Đọc requirements + design | ✍️ Thủ công | DEV tự đọc context |
| Tạo task plan | 🧠 AI-assisted | `/task` — Claude đọc REQ + viết Approach/Plan |
| `/design draft REQ-N` | 🧠 AI-assisted | Claude tạo design/REQ-N.md **(bắt buộc trước khi code)** |
| Design gate check | 🧠 AI-assisted | `/task execute` tự kiểm tra design/REQ-N.md tồn tại |
| Update US → in-dev | 🧠 AI-assisted | Claude edit frontmatter trong task execute |
| Implement src/ | ✍️ Thủ công | DEV viết code (Claude Code hỗ trợ qua chat) |
| `/design verify REQ-N` | 🧠 AI-assisted | Claude so sánh code vs draft, ghi deviation |
| Update US → in-test | 🧠 AI-assisted | Claude edit frontmatter khi đóng task |
| Cập nhật `tasks/_index.md` | 🤖 Tự động | `sync-index.sh` sau Edit TASK-N+1.md |
| git push + PR | ✍️ Thủ công | DEV tự push và tạo PR |
| Commit + handoff → QC | ✍️ Thủ công | DEV tự commit đúng format `handoff(US-NNN → QC)` |
| TASK-N+2 unblock (tc-run) | 🤖 Tự động | `detect-handoff.sh` đổi QC task → Ready |

**Còn thủ công:** logic code, code review, debug, quyết định kiến trúc.

---

### QC

| Bước | Loại | Chi tiết |
|------|------|---------|
| Nhận handoff từ BA (tc-draft) | 🤖 Tự động | `detect-handoff.sh` đổi TASK-N+2 → **Ready** |
| Nhận handoff từ DEV (tc-run) | 🤖 Tự động | `detect-handoff.sh` đổi TASK-N+2 → Ready (lần 2) |
| git pull | ✍️ Thủ công | QC tự pull để lấy src/ mới nhất |
| Đọc requirements + design | ✍️ Thủ công | QC tự đọc |
| Viết TC skeleton (tc-draft) | 🧠 AI-assisted | Claude Code viết từ requirements + design "Test Entry Points" |
| `/regression task TASK-N+1` | 🧠 AI-assisted | Claude phân tích scope → đề xuất bộ TCs cần chạy |
| QC xác nhận bộ TCs | ✍️ Thủ công | QC review và quyết định có chạy hay không |
| Finalize TCs | ✍️ Thủ công | QC bổ sung assertions, page objects |
| `/qa run REQ-N` | 🧠 AI-assisted | Claude chạy Playwright, đọc kết quả |
| `/qa matrix` | 🧠 AI-assisted | Claude sync REQ-Coverage-Matrix từ report.json |
| Điền TC Coverage vào DEV task | 🧠 AI-assisted | Claude edit TASK-N+1.md section TC Coverage |
| Cập nhật `tasks/_index.md` | 🤖 Tự động | `sync-index.sh` sau Edit TASK-N+2.md |
| Structured bug report | 🧠 AI-assisted | Claude format bug table khi FAIL |
| Tăng `qc_dev_rounds` | ✍️ Thủ công | QC edit frontmatter US-NNN.md |
| Escalate ≥ 2 rounds | ✍️ Thủ công | QC add warning vào commit + US file |
| Commit + handoff → PM/DEV | ✍️ Thủ công | QC tự commit đúng format |

**Còn thủ công:** viết assertions chất lượng, phán đoán "code bug vs TC bug", quyết định test coverage đủ chưa.

---

## 3. Tóm tắt Automation Coverage

```
Loại                        | Tự động | AI-assisted | Thủ công
─────────────────────────────────────────────────────────────
Index sync (_index.md)      |   ✅    |             |
Handoff detection           |   ✅    |             |
Task unblock                |   ✅    |             |
Tạo US / Stub tasks         |         |     ✅      |
Viết ACs (BA)               |         |     ✅      |
Viết design (DEV)           |         |     ✅      |
Design gate enforce         |         |     ✅      |
Regression analysis         |         |     ✅      |
Chạy tests + matrix         |         |     ✅      |
TC Coverage fill            |         |     ✅      |
Bug report format           |         |     ✅      |
Viết code (DEV)             |         |             |    ✅
Viết assertions (QC)        |         |             |    ✅
git pull / push / PR        |         |             |    ✅
Quyết định scope/priority   |         |             |    ✅
Escalation judgment         |         |             |    ✅
```

---

## 4. Vai trò & Ownership

| Role | Owns | Skills | READ-ONLY |
|------|------|--------|-----------|
| **PM** | `us/*.md` | `/pm` | requirements, design, tasks |
| **BA** | `requirements/REQ-N.md` | `/requirements`, `/task`, `/drift` | us, design, testing |
| **DEV** | `src/`, `design/REQ-N.md` | `/task`, `/design`, `/drift` | us, requirements, testing |
| **QC** | `testing/specs/`, `REQ-Coverage-Matrix.md` | `/qa`, `/regression`, `/task`, `/drift` | us, requirements, design (src qua `git show`) |

---

## 5. Lifecycle

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

## 6. Handoff Protocol

Mọi handoff dùng git commit format:

```
handoff(US-NNN → ROLE): TASK-NNN done — [mô tả ngắn]
```

Xem log handoffs:
```bash
git log --oneline --grep="^handoff"
```

### Auto-detection

Khi commit có pattern trên, `detect-handoff.sh` tự động:
1. Parse US code + target ROLE
2. Tìm TASK của ROLE đó đang Blocked cho US đó
3. Đổi Status → **Ready** + stage file
4. Print thông báo

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📬 Handoff: US-001 → QC
   TASK-003: Blocked → Ready (staged)

   👉 QC: mở TASK-003.md
      Điền Approach + Plan → Pending Approval
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Chạy qua 2 lớp:
- **Claude Code hook** (`settings.json`) — khi Claude chạy git commit
- **Git post-commit hook** (`bash .claude/setup-hooks.sh`) — khi user commit tay

| Từ | Sang | Khi nào |
|----|------|---------|
| PM | BA | US created, TASK-N Ready |
| BA | DEV + QC | REQ-N.md xong (DEV unblock + QC tc-draft unblock đồng thời) |
| DEV | QC | src/ + design done, in-test |
| QC | PM | All TCs pass 🟢 |
| QC | DEV | TCs fail — kèm bug report |

---

## 7. Chi tiết từng Role

### PM

```
/pm create US-NNN
  → tạo us/US-NNN.md (status: draft, qc_dev_rounds: 0)
  → auto-gen 3 stub tasks:
     TASK-N   (BA)  req-write → Ready
     TASK-N+1 (DEV) feature   → Blocked ← TASK-N
     TASK-N+2 (QC)  tc-write  → Blocked ← TASK-N [phase: tc-draft]
  → us/_index.md + tasks/_index.md tự động rebuild  [🤖]
  → commit + handoff → BA

/pm list        → dashboard tất cả USs
/pm handoffs    → git log handoffs
/pm done US-NNN → confirm US hoàn thành sau QC 🟢
```

---

### BA

```
Nhận: handoff(US-NNN → BA)  [🤖 detect-handoff.sh → TASK-N: Ready]
  │
  ├─ Đọc us/US-NNN.md
  ├─ /task → TASK-N.md: Approach + Plan → Pending Approval
  ├─ Chờ user: "làm"
  │
  └─ EXECUTE:
       /requirements US-NNN
         → tạo requirements/REQ-N.md
         → viết ACs dạng WHEN/THEN
         → update US: status → ac-ready, Linked REQs: REQ-N
       TASK-N: Done  [🤖 tasks/_index.md rebuild]
       handoff(US-NNN → DEV): "REQ-N ready — X ACs"  [✍️ manual commit]
       → TASK-N+1 (DEV) unblock   [🤖]
       → TASK-N+2 (QC, tc-draft) unblock  [🤖] đồng thời
```

---

### DEV

```
Nhận: handoff(US-NNN → DEV)  [🤖 detect-handoff.sh → TASK-N+1: Ready]
  │
  ├─ git pull  [✍️]
  ├─ Đọc requirements + design + US  [✍️]
  ├─ /task → TASK-N+1.md: Approach + Plan → Pending Approval
  ├─ Chờ user: "làm"
  │
  └─ EXECUTE:
       update US: in-dev  [🧠]
       /design draft REQ-N  [🧠 bắt buộc trước khi code]
         → design/REQ-N.md (Status: draft)
         → QC đọc để viết tc-draft song song
       Design gate check  [🧠 tự kiểm tra trong /task execute]
       Implement src/  [✍️]
       /design verify REQ-N  [🧠 so sánh code vs draft → Status: done]
       update US: in-test  [🧠]
       TASK-N+1: Done  [🤖 tasks/_index.md rebuild]
       git push → PR  [✍️]
       handoff(US-NNN → QC): "TASK-N+1 done"  [✍️ manual commit]
       → TASK-N+2 (QC, tc-run) unblock  [🤖]
```

---

### QC

```
Phase 1 — tc-draft
  Nhận: handoff(US-NNN → BA done)  [🤖 → TASK-N+2: Ready, phase tc-draft]
  ├─ Đọc requirements/REQ-N.md + design/REQ-N.md (draft)  [✍️]
  ├─ Viết TC skeleton: stubs từ Test Entry Points trong design  [🧠]
  └─ git push tc-draft  [✍️]

Phase 2 — tc-run
  Nhận: handoff(US-NNN → DEV done)  [🤖 → TASK-N+2: Ready, phase tc-run]
  │
  ├─ git pull  [✍️]
  ├─ /regression task TASK-N+1  [🧠]
  │    AI: Changed Files → REQs → TCs → Risk (🔴🟡🟢⬛)
  │    Output: bộ TCs khuyến nghị
  │    QC xác nhận  [✍️]
  │
  ├─ /qa drift REQ-N (nếu cần)  [🧠]
  │    → DEV bugfix / QC tc-fix / BA req-clarify
  │
  ├─ Finalize TCs: assertions, page objects  [✍️]
  │
  ├─ /qa run REQ-N  [🧠]
  │
  │   PASS ──► /qa matrix  [🧠]
  │             Điền TC Coverage vào TASK-N+1  [🧠]
  │             update US → done  [🧠]
  │             handoff(US-NNN → PM): "QC 🟢"  [✍️]
  │
  └─  FAIL ──► Structured Bug Report  [🧠]
               qc_dev_rounds +1  [✍️]
               handoff(US-NNN → DEV): "TC fail"  [✍️]
               [≥ 2 rounds: ⚠️ Escalate PM/BA]  [✍️]
```

---

## 8. DEV ↔ QC — Chi tiết tương tác

```
BA done                    DEV                           QC
───────                    ───                           ──
                [🤖]──────► TASK-N+1: Ready              TASK-N+2: Ready (tc-draft) ◄──[🤖]
                            │                            │
                            │ implement [✍️]             │ viết TC skeleton [🧠]
                            │ /design draft [🧠]         │ từ requirements + design
                            │                            │
                            │                            git push tc-draft [✍️]
                            │◄────────────── (DEV có thể pull skeleton nếu cần)
                            │
                            /design verify [🧠]
                            git push PR [✍️]
                            handoff → QC [✍️] ──────────►
                                                [🤖]──── TASK-N+2: Ready (tc-run)
                                                         /regression task [🧠]
                                                         QC xác nhận TCs [✍️]
                                                         finalize TCs [✍️]
                                                         /qa run [🧠]
                                              ┌──────────┴──────────┐
                                            PASS                  FAIL
                                              │                     │
                                    /qa matrix [🧠]      bug report [🧠]
                                    handoff → PM [✍️]   qc_dev_rounds +1 [✍️]
                                                        handoff → DEV [✍️] ──────►
                                                                         DEV fix [✍️]
                                                        ◄─────── re-handoff → QC [✍️]
                                                        [≥ 2 rounds: escalate [✍️]]
```

---

## 9. Skills Reference

| Skill | Role | Mô tả |
|-------|------|-------|
| `/pm` | PM | Tạo/quản lý User Stories, dashboard, handoffs |
| `/requirements` | BA | Viết ACs từ US, cập nhật REQ |
| `/task` | ALL | Tạo task, execute, đóng task, dashboard |
| `/design` | DEV | Tạo/cập nhật design/REQ-N.md (draft → done) |
| `/qa` | QC | Drift analysis, chạy tests, sync Coverage Matrix |
| `/regression` | QC | Phân tích risk, đề xuất bộ TCs cần chạy |
| `/drift` | ALL | Phát hiện spec drift: AC vs Code vs TC |

---

## 10. File Structure

```
.claude/docs/
├── us/
│   ├── _index.md          ← PM dashboard  [🤖 auto-rebuild]
│   └── US-NNN.md          ← PM owns (status, qc_dev_rounds)
├── requirements/
│   ├── _index.md
│   └── REQ-N.md           ← BA owns (WHEN/THEN ACs)
├── design/
│   ├── _index.md
│   └── REQ-N.md           ← DEV owns (draft → done lifecycle)
└── tasks/
    ├── _index.md          ← [🤖 auto-rebuild khi TASK-*.md thay đổi]
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

## 11. Go-Live Status

| Symbol | Nghĩa | Điều kiện |
|--------|-------|-----------|
| 🟢 | Ready | 100% testable ACs covered, tất cả pass, không drift |
| 🟡 | Partial | Không có ❌, còn gap hoặc 🔵 chưa chạy |
| 🔴 | Blocked | Có ❌ fail hoặc spec drift nghiêm trọng |
| ⬛ | Skip | Ngoài scope automation |

> Trước khi đánh 🟢: chạy `/regression task` của task gần nhất để confirm không có regression.
