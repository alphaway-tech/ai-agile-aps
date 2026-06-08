---
description: Tạo và quản lý User Stories trong us/ — mỗi US 1 file, dashboard ở _index.md
---

# /pm Skill

## Subcommands

| Subcommand | Action |
|---|---|
| `/pm create US-NNN` | Tạo file US-NNN.md mới |
| `/pm update US-NNN` | Cập nhật thông tin hoặc status của US |
| `/pm list` | Hiển thị dashboard + summary tiến độ |
| `/pm sync` | Rebuild `_index.md` từ tất cả US-NNN.md files |
| `/pm done US-NNN` | Đánh dấu US hoàn thành (sau khi TEST báo 🟢) |
| `/pm handoffs` | Xem log handoff giữa các role |

Không có subcommand → chạy `/pm list`.

---

## Xác định US ID tiếp theo

```bash
ls .claude/docs/us/US-*.md 2>/dev/null | sort -V | tail -1
# → lấy số, +1. Nếu chưa có → bắt đầu từ US-001
```

---

## Tạo US mới (`/pm create`)

Tạo file `.claude/docs/us/US-NNN.md`:

```markdown
---
code: US-NNN
title: [Tiêu đề ngắn gọn]
priority: High | Medium | Low
status: draft
sprint: [YYYY-QN-SN hoặc tên sprint]
created: YYYY-MM-DD
qc_dev_rounds: 0
---

## User Story

Là một [role], tôi muốn [hành động], để [lợi ích].

## Business Context

[Tại sao feature này cần thiết — động lực từ business, pain point đang giải quyết]

## Scope Notes

[High-level notes cho BA — những gì cần có. Chưa phải ACs.]
- ...

## Out of Scope

[Những gì PM explicitly KHÔNG muốn trong US này]
- ...

## Dependencies

- [US-NNN: tên US phụ thuộc — nếu có]

## Linked REQs

<!-- BA điền sau khi viết requirements -->

## GoLive Status

<!-- QC điền sau khi chạy QA -->
```

### Sau khi tạo US-NNN.md — Auto-gen 3 stub tasks

Lấy 3 TASK ID tiếp theo liên tiếp:
```bash
ls .claude/docs/tasks/TASK-*.md 2>/dev/null | sort -V | tail -1
# → TASK-NNN, tăng lên: N, N+1, N+2
```

Tạo 3 file stub trong `.claude/docs/tasks/`:

**TASK-N.md (BA)**
```markdown
## TASK-N

**Role:** BA
**Status:** Ready
**Type:** req-write
**Title:** Viết ACs — US-NNN
**US Reference:** US-NNN
**Requirement References:** TBD
**Design References:** TBD

**Impacted Files:**
- `.claude/docs/requirements/` (REQ mới)

---

### Approach
*(BA điền khi bắt đầu — đọc US-NNN.md trước)*

### Plan
*(BA điền khi bắt đầu)*

### Acceptance Criteria
- [ ] requirements/REQ-N.md tạo với đủ ACs
- [ ] US-NNN.md: status → ac-ready, Linked REQs: REQ-N

### Predicted Impact
**Requirement Impact:** REQ-N (mới)
**Design Impact:** none
**TC Impact:** none

---
*(Implementation Summary điền sau khi xong)*

## TC Coverage
| AC | Test name | Spec file |
|----|-----------|-----------|
```

**TASK-N+1.md (DEV)**
```markdown
## TASK-N+1

**Role:** DEV
**Status:** Blocked ← TASK-N (BA req-write)
**Type:** feature
**Title:** Implement — US-NNN
**US Reference:** US-NNN
**Requirement References:** TBD (điền sau khi BA xong TASK-N)
**Design References:** TBD

**Impacted Files:**
- `src/` (TBD)

---

### Approach
*(DEV điền khi nhận handoff từ BA — đọc requirements/REQ-N.md trước)*

### Plan
*(DEV điền khi nhận handoff)*

### Acceptance Criteria
- [ ] Implement đúng ACs trong requirements/REQ-N.md
- [ ] Regression Gate pass

### Predicted Impact
**Requirement Impact:** none
**Design Impact:** design/REQ-N.md (mới)
**TC Impact:** TBD

---
*(Implementation Summary điền sau khi xong)*

## TC Coverage
| AC | Test name | Spec file |
|----|-----------|-----------|
```

**TASK-N+2.md (QC)**
```markdown
## TASK-N+2

**Role:** QC
**Status:** Blocked ← TASK-N (BA req-write) [phase: tc-draft]
**Type:** tc-write
**Phase:** tc-draft → tc-run
**Title:** Viết TCs — US-NNN
**US Reference:** US-NNN
**Requirement References:** TBD

**Impacted Files:**
- `testing/specs/` (TBD)

---

> **2-phase task (shift-left):**
> - **tc-draft** — unblock khi TASK-N (BA) Done: đọc `requirements/REQ-N.md` + `design/REQ-N.md` (draft — DEV viết song song), dùng section **Test Entry Points** trong design để viết TC skeleton, KHÔNG chạy tests
> - **tc-run** — unblock khi TASK-N+1 (DEV) Done: kiểm tra deviation notes trong design (status: done), finalize TCs, chạy `/qa run`, sync matrix

### Approach
*(QC điền khi bắt đầu tc-draft — đọc requirements/REQ-N.md trước; sau DEV done: bổ sung design/REQ-N.md + src)*

### Plan
*(tc-draft: viết skeleton / tc-run: finalize + run)*

### Acceptance Criteria
- [ ] tc-draft: skeleton cho 100% testable ACs (chưa cần pass)
- [ ] tc-run: All TCs pass (/qa run)
- [ ] REQ-Coverage-Matrix updated
- [ ] TC Coverage điền vào TASK-N+1 (DEV task)

### Predicted Impact
**Requirement Impact:** none
**Design Impact:** none
**TC Impact:** testing/specs/ (mới)

---
*(Implementation Summary điền sau khi xong)*

## TC Coverage
→ Xem TASK-N+1 (DEV task)
```

Thêm vào đầu bảng `tasks/_index.md`:
```markdown
| [TASK-N+2](TASK-N+2.md)   | QC  | Viết TCs — US-NNN    | tc-write  | Blocked ← TASK-N (phase: tc-draft) | — |
| [TASK-N+1](TASK-N+1.md)   | DEV | Implement — US-NNN   | feature   | Blocked ← TASK-N   | — |
| [TASK-N](TASK-N.md)       | BA  | Viết ACs — US-NNN    | req-write | Ready              | — |
```

### Reminder cho PM (in ra sau khi tạo xong)

```
✅ US-NNN created
📋 3 stub tasks auto-generated:
   TASK-N   (BA)  req-write → Ready
   TASK-N+1 (DEV) feature   → Blocked ← TASK-N
   TASK-N+2 (QC)  tc-write  → Blocked ← TASK-N (phase: tc-draft, shift-left)

👉 Tiếp theo:
   git add + commit: "us(US-NNN): [title] — draft"
   Handoff sang BA: "handoff(US-NNN → BA): TASK-N Ready"
```

Chạy `/pm sync` để cập nhật `us/_index.md`.

---

## US Status Lifecycle

```
draft → ac-ready → in-dev → in-test → done
  ↑PM      ↑BA        ↑DEV     ↑DEV      ↑PM xác nhận
```

| Status | Nghĩa | Ai set |
|--------|-------|--------|
| `draft` | PM vừa tạo, BA chưa viết ACs | PM |
| `ac-ready` | BA đã viết ACs xong, DEV có thể bắt đầu | BA |
| `in-dev` | DEV đang implement | DEV |
| `in-test` | DEV xong, QC đang viết/chạy TCs | DEV |
| `done` | QC báo 🟢, US hoàn thành | PM xác nhận |

---

## Dashboard (`/pm list` và `/pm sync`)

### `/pm sync` — Rebuild _index.md từ US files (source of truth)

```bash
# Extract frontmatter từ tất cả US files
grep -h "^code:\|^title:\|^priority:\|^status:\|^sprint:" \
  .claude/docs/us/US-*.md 2>/dev/null

# Lấy GoLive từ REQ-Coverage-Matrix
grep "REQ-\|GoLive" testing/artifacts/REQ-Coverage-Matrix.md
```

Từ data trên, sinh lại `us/_index.md` với format đầy đủ (xem bên dưới).  
**Không manual edit `_index.md`** — luôn chạy `/pm sync` sau bất kỳ status change nào.

### Format `_index.md`

```markdown
# US Dashboard

**Updated:** YYYY-MM-DD

## Summary

| Status | Count |
|--------|-------|
| draft | N |
| ac-ready | N |
| in-dev | N |
| in-test | N |
| done | N |

**Progress:** [done / total] — X%

## US List

| US | Title | Priority | Status | Linked REQs | GoLive | Sprint |
|----|-------|----------|--------|-------------|--------|--------|
| [US-001](US-001.md) | Tên US | High | in-test | REQ-1 | 🟡 | Q3-S1 |
| [US-002](US-002.md) | Tên US | Medium | draft | — | ⬛ | Q3-S2 |
```

---

## Xem handoff log (`/pm handoffs`)

Các role dùng commit message format `handoff(US-NNN → ROLE): ...` khi chuyển giao.  
PM xem tất cả handoffs:

```bash
git log --oneline --all --grep="^handoff"
```

Output mẫu:
```
a1b2c3d handoff(US-001 → PM): QC 🟢 — REQ-1 all pass, done
f4e5d6c handoff(US-001 → QC): DEV xong TASK-001, REQ-1 sẵn test
9g8h7i6 handoff(US-001 → DEV): BA xong REQ-1 — 10 ACs
```

---

## Cập nhật status (`/pm update`)

Edit dòng `status:` trong frontmatter của US-NNN.md, sau đó `/pm sync`.

---

## Nguyên tắc viết US tốt

- **User Story**: luôn dùng format "Là một [role], tôi muốn..., để..."
- **Business Context**: viết cho BA, không phải cho DEV — giải thích WHY, không HOW
- **Scope Notes**: đủ để BA hiểu phạm vi, không phải spec kỹ thuật
- **Out of Scope**: rõ ràng để tránh scope creep
- **1 US = 1 deliverable** — nếu US quá lớn, tách thành nhiều US con
