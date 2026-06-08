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

## Files bạn own

- `testing/specs/*.spec.ts`
- `testing/pages/*.ts`
- `testing/fixtures/test.ts`
- `testing/artifacts/REQ-Coverage-Matrix.md`

## Files READ-ONLY

- `.claude/docs/requirements/REQ-N.md` (nguồn để viết TCs)
- `.claude/docs/design/REQ-N.md` (hiểu architecture khi debug)
- `src/` — đọc qua `git show upstream/main:src/...`, không có local

## Workflow của TEST

```
1. Nhận ping từ DEV với REQ-N
2. ./sync.sh — pull requirements + design mới nhất
3. /testing REQ-N — gen TCs + scripts
4. Review và fix scripts nếu cần
5. /qa run REQ-N — chạy, đọc kết quả
6. Fix failures (drift hoặc test bug)
7. /qa matrix — update REQ-Coverage-Matrix
8. Update US-NNN.md: status → done (nếu 🟢)
9. git push → PR → ping PM với GoLive status
```

## Chuẩn pass

- Tất cả TCs cho REQ-N: ✅
- Coverage: 100% testable ACs (ACs được ⏭ skip không tính)
- Chạy /qa run all để confirm không có cross-REQ regression trước khi đánh 🟢
