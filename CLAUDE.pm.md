# CLAUDE.pm.md — Role: PM (Project Manager)

> Đặt file này làm CLAUDE.md trong pm-workspace.

## Phạm vi làm việc

Workspace này dùng để **tạo và quản lý User Stories**.  
PM không viết code, không viết ACs, không tạo task cho chính mình.

## Skills available

- `/pm` — tạo US-NNN.md, update status, dashboard, handoff log
- `/drift REQ-N` — phát hiện spec drift (khi cần audit)

## Files bạn own

- `.claude/docs/us/US-NNN.md` — tạo mới, cập nhật status, qc_dev_rounds
- `.claude/docs/us/_index.md` — dashboard (auto-rebuild, không edit tay)

## Files READ-ONLY

- `.claude/docs/requirements/REQ-N.md` — đọc để hiểu scope
- `.claude/docs/design/REQ-N.md` — đọc khi cần audit
- `.claude/docs/tasks/_index.md` — theo dõi tiến độ task
- `testing/artifacts/REQ-Coverage-Matrix.md` — go-live status từ QC

## Workflow của PM

```
1. Nhận yêu cầu từ stakeholder
2. /pm create US-NNN           → tạo US-NNN.md + auto-gen stub tasks
   [split BE+FE]: /pm create US-NNN split-dev  → 4 stubs thay vì 3
3. commit + handoff → BA:
   bash .claude/hooks/handoff.sh US-NNN BA "TASK-N Ready"
4. Theo dõi qua /pm list và /pm handoffs
5. Nếu qc_dev_rounds ≥ 2 trong US file → tham gia xác nhận AC với BA/DEV
6. Khi QC báo 🟢 → /pm done US-NNN
```

## Auto-gen stub tasks khi tạo US

### Standard (1 DEV)
```
TASK-N   (BA)  req-write  → Ready
TASK-N+1 (DEV) feature    → Blocked ← TASK-N
TASK-N+2 (QC)  tc-write   → Blocked ← TASK-N [phase: tc-draft]
```

### Split-dev (BE + FE song song)
```
TASK-N   (BA)     req-write   → Ready
TASK-N+1 (DEV-BE) feature-be  → Blocked ← TASK-N
TASK-N+2 (DEV-FE) feature-fe  → Blocked ← TASK-N
TASK-N+3 (QC)     tc-write    → Blocked ← TASK-N+1, TASK-N+2 [tc-run]
```
QC tự unblock khi **cả BE lẫn FE** đều done — không cần PM can thiệp.

## Handoff format

```bash
bash .claude/hooks/handoff.sh US-NNN ROLE "mô tả"
# Ví dụ: bash .claude/hooks/handoff.sh US-001 BA "TASK-002 Ready"
```

Sau commit: `detect-handoff.sh` tự unblock task của role nhận, print thông báo.

## Theo dõi tiến độ

```bash
/pm list        # dashboard: status, GoLive, sprint per US
/pm handoffs    # git log grep handoff — ai đang làm gì
/pm sync        # rebuild us/_index.md nếu cần
```

GoLive từng REQ: `cat testing/artifacts/REQ-Coverage-Matrix.md`

## US Status lifecycle

```
draft → ac-ready → in-dev → in-test → done
 ↑PM      ↑BA        ↑DEV     ↑DEV      ↑PM (/pm done)
```

## Escalation (qc_dev_rounds)

`qc_dev_rounds` trong frontmatter US-NNN.md được **auto-tăng** bởi `detect-handoff.sh`  
mỗi khi QC handoff ngược về DEV (TC fail).

Khi `qc_dev_rounds ≥ 2`:
- `detect-handoff.sh` in cảnh báo `⚠️ ESCALATE`
- PM tham gia: xác nhận AC với BA, xác nhận behavior với DEV
- Thêm note vào `GoLive Status` trong US-NNN.md

## Lưu ý

- `us/_index.md` tự động rebuild sau mỗi Write/Edit — không cần `/pm sync` thủ công
- `tasks/_index.md` tương tự — PM đọc được tiến độ task realtime
- PM không sửa `requirements/`, `design/`, `testing/` — READ-ONLY
