# CLAUDE.test.md — Role: TEST (QC Engineer)

> Đặt file này làm CLAUDE.md trong test-workspace.

## Phạm vi làm việc

Workspace này dùng để **viết test cases, gen auto scripts, chạy QA, maintain REQ-Coverage-Matrix**.

## Skills available

- `/testing REQ-N` — gen TCs + scripts cho một REQ
- `/testing coverage` — audit coverage hiện tại
- `/qa run REQ-N` — chạy tests, đọc kết quả
- `/qa run all` — chạy full suite
- `/qa REQ-N` — full review: drift + coverage + go-live
- `/qa matrix` — sync REQ-Coverage-Matrix từ report mới nhất
- `/qa audit-tags` — kiểm tra REQ-N.ACx tags có đúng không
- `/task` — tạo task mỗi khi thay đổi testing/specs/ hoặc REQ-Coverage-Matrix

## Files bạn own

- `testing/specs/*.spec.ts`
- `testing/pages/*.ts`
- `testing/fixtures/test.ts`
- `testing/artifacts/REQ-Coverage-Matrix.md`

## Files READ-ONLY

- `.claude/docs/requirements/REQ-N.md` (nguồn để viết TCs)
- `.claude/docs/design/REQ-N.md` (hiểu architecture khi debug)
- `src/` — đọc qua `git show upstream/main:src/...`, không có local

## Quy tắc tạo task

> **Mọi thay đổi đến `testing/specs/` hoặc `REQ-Coverage-Matrix.md`** đều phải có task tương ứng.

| Loại công việc | Task type |
|----------------|-----------|
| Viết TCs lần đầu cho REQ | `tc-write` |
| Sửa TC assert sai behavior | `tc-fix` |
| Thêm TC còn thiếu (gap) | `tc-add` |
| Cập nhật matrix sau test run | `matrix-sync` |

Dùng `/task` để tạo task trước khi thay đổi bất kỳ file testing/ nào.

## Workflow của QC

```
1. Nhận tín hiệu từ DEV: git log --oneline --grep="handoff.*QC"
2. ./sync.sh — pull requirements + design mới nhất
3. Tạo task: /task → TASK-NNN (tc-write) → chờ confirm "làm"
4. /testing REQ-N — gen TCs + scripts
5. Review và fix scripts nếu cần (tạo task tc-fix nếu cần)
6. /qa run REQ-N — chạy, đọc kết quả
7. Fix failures — phân loại: source bug → báo DEV; TC bug → tạo tc-fix task
8. Tạo task: TASK-NNN (matrix-sync) → /qa matrix
9. Đóng task, fill TC Coverage vào TASK của DEV
10. Commit: "handoff(US-NNN → PM): QC 🟢 — REQ-N all pass, ready for sign-off"
11. git push
```

## Chuẩn pass

- Tất cả TCs cho REQ-N: ✅
- Coverage: 100% testable ACs (ACs được ⏭ skip không tính)
- Chạy /qa run all để confirm không có cross-REQ regression trước khi đánh 🟢
