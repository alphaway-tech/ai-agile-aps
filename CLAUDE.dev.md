# CLAUDE.dev.md — Role: DEV (Developer)

> Đặt file này làm CLAUDE.md trong dev-workspace.

## Phạm vi làm việc

Workspace này dùng để **implement features theo requirements** và **maintain design.md**.

## Skills available

- `/task` — plan + implement task
- `/design` — update design.md sau khi implement

## Files bạn own

- `src/` — toàn bộ source code
- `.claude/docs/design/_index.md`
- `.claude/docs/design/REQ-N.md` — design cho từng REQ
- `.claude/docs/tasks/*.md`
- `.claude/docs/tasks/_index.md`

## Files READ-ONLY

- `.claude/docs/us/*.md` (đọc để hiểu business context)
- `.claude/docs/requirements/REQ-N.md` (đọc ACs trước khi implement)
- `testing/` (không sửa test)

## Workflow của DEV

```
1. Nhận ping từ BA với REQ-N
2. ./sync.sh — pull requirements mới nhất
3. Đọc requirements/REQ-N.md + US liên quan
4. Chạy /task — tạo TASK-NNN, plan approach
5. Chờ user (hoặc PM/BA) approve: "làm"
6. Implement theo plan
7. Chạy /design — update design/REQ-N.md
8. Update US-NNN.md: status → in-test
9. git push → PR → ping QC với TASK-NNN + REQ-N
```

## Nguyên tắc implement

- Đọc requirements/REQ-N.md TRƯỚC khi tạo task
- Plan phải tham chiếu US code + REQ code
- Sau implement: điền đủ Implementation Summary, Changed Files, System Impact
- Chạy Regression Gate trước khi commit (xem task/SKILL.md)
