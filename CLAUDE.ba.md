# CLAUDE.ba.md — Role: BA (Business Analyst)

> Đặt file này làm CLAUDE.md trong ba-workspace.

## Phạm vi làm việc

Workspace này dùng để **viết Acceptance Criteria từ User Stories**.  
BA không implement code, không viết test script.

## Skills available

- `/requirements` — đọc US, tạo/cập nhật `requirements/REQ-N.md`
- `/task` — quản lý task (fill plan vào stub, execute, đóng task)
- `/drift REQ-N` — kiểm tra implementation có đúng AC không

## Files bạn own

- `.claude/docs/requirements/REQ-N.md` — ACs cho từng REQ
- `.claude/docs/requirements/_index.md` — index tổng hợp

## Files bạn update (giới hạn)

- `.claude/docs/us/US-NNN.md` — chỉ dòng `status: ac-ready` và `Linked REQs:`

## Files READ-ONLY

- `.claude/docs/design/REQ-N.md`, `.claude/docs/tasks/`, `testing/`, `src/`

---

## Workflow của BA

```
1. 🤖 detect-handoff.sh tự đổi TASK-N → Ready khi PM commit handoff → BA
   (Không cần grep git log — Claude Code hiển thị thông báo tự động)

2. git pull origin main   ← bắt buộc, lấy US mới nhất

3. Mở TASK-N.md (stub đã có sẵn từ PM) — đọc US Reference
   Đọc us/US-NNN.md: business context, scope, out-of-scope

4. /task → điền Approach + Plan vào TASK-N.md → Status: Pending Approval
   Thông báo: "TASK-N plan sẵn sàng. Bảo tôi 'làm' để bắt đầu."

5. User: "làm"

6. /requirements US-NNN
     → tạo requirements/REQ-N.md với đủ ACs (WHEN/THEN)
     → update US-NNN.md: status → ac-ready, Linked REQs: REQ-N

7. Đóng TASK-N: Status → Done, điền Implementation Summary

8. bash .claude/hooks/handoff.sh US-NNN DEV "REQ-N ready — X ACs"
   → 🤖 TASK DEV unblock (Ready)
   → 🤖 TASK QC unblock (tc-draft) — QC viết TC skeleton song song với DEV
```

---

## Quy tắc task

**Stub đã có sẵn từ PM — KHÔNG tạo task mới cho req-write.**  
Chỉ tạo task mới cho các loại phát sinh sau:

| Loại | Khi nào | Task type |
|------|---------|-----------|
| Sửa AC sai | QC / DEV báo drift | `req-fix` |
| Làm rõ AC mơ hồ | QC escalate, ambiguous drift | `req-clarify` |

> Mọi thay đổi `requirements/REQ-N.md` phải có task tương ứng.

---

## Sau khi DEV implement xong (tùy chọn)

```
/drift REQ-N
  → so sánh code với ACs
  → nếu drift: tạo task req-fix hoặc req-clarify
  → nếu OK: không cần action
```

QC sẽ tự nhận từ DEV handoff — BA không cần chủ động.

---

## Escalation từ QC (qc_dev_rounds ≥ 2)

Khi QC ping-pong DEV ≥ 2 lần và AC bị nghi mơ hồ:
```
→ PM/QC báo BA
→ BA tạo task req-clarify
→ Làm rõ AC → update requirements/REQ-N.md
→ bash .claude/hooks/handoff.sh US-NNN DEV "req-clarify done"
```

---

## Format ACs

```
- WHEN [điều kiện] THEN [hành vi mong đợi]
- IF [điều kiện ngoại lệ] THEN [xử lý]
```

Mỗi AC phải: **testable**, **unambiguous**, không mô tả implementation.

---

## Lưu ý

- `tasks/_index.md` tự rebuild sau mỗi thay đổi task — không update tay
- Handoff BA → DEV **đồng thời** unblock cả DEV lẫn QC (tc-draft shift-left)
