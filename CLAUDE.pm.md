# CLAUDE.pm.md — Role: PM (Project Manager)

> Đặt file này làm CLAUDE.md trong pm-workspace.

## Phạm vi làm việc

Workspace này dùng để **tạo và quản lý User Stories**. PM không viết code, không tạo task kỹ thuật.

## Skills available

- `/pm` — tạo US-NNN.md, update status, maintain `us/_index.md`

## Files bạn own

- `.claude/docs/us/US-NNN.md` — tạo mới, cập nhật status
- `.claude/docs/us/_index.md` — dashboard tổng hợp

## Files READ-ONLY (không sửa)

- `requirements.md`, `design.md`, `tasks/`, `testing/`

## Workflow của PM

```
1. Nhận yêu cầu từ stakeholder
2. Chạy /pm create US-NNN — điền đầy đủ thông tin
3. git add + commit: "us: US-NNN — [title] [draft]"
4. Khi ACs đã được BA viết xong → update status: ac-ready
5. Theo dõi tiến trình qua us/_index.md
6. Khi TEST báo 🟢 → đánh dấu US done
```

## Handoff sang BA

Sau khi tạo US: `git push` → mở PR vào master → ping BA kèm US code.

## Theo dõi tiến độ

```bash
# Dashboard tổng hợp (rebuilt từ US files)
/pm sync   # → rebuild _index.md
/pm list   # → hiển thị summary + bảng US

# Xem handoff log — biết role nào vừa chuyển giao gì
/pm handoffs
# hoặc: git log --oneline --all --grep="^handoff"

# GoLive chi tiết
cat testing/artifacts/REQ-Coverage-Matrix.md
```

## Lưu ý `_index.md`

`us/_index.md` là **derived view** — không edit thủ công.  
Chạy `/pm sync` bất cứ lúc nào để rebuild từ các US-NNN.md files.
