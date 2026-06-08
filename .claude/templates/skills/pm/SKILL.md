---
description: Tạo và quản lý User Stories trong us/ — mỗi US 1 file, dashboard ở _index.md
---

# /pm Skill

## Subcommands

| Subcommand | Action |
|---|---|
| `/pm create US-NNN` | Tạo file US-NNN.md mới |
| `/pm update US-NNN` | Cập nhật thông tin hoặc status của US |
| `/pm list` | Hiển thị dashboard từ `us/_index.md` |
| `/pm done US-NNN` | Đánh dấu US hoàn thành (sau khi TEST báo 🟢) |

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
---

## User Story

Là một [role], tôi muốn [hành động], để [lợi ích].

## Business Context

[Tại sao feature này cần thiết — động lực từ business, pain point đang giải quyết]

## Scope Notes

[High-level notes cho BA — những gì cần có. Chưa phải ACs.]
- ...
- ...

## Out of Scope

[Những gì PM explicitly KHÔNG muốn trong US này]
- ...

## Dependencies

- [US-NNN: tên US phụ thuộc — nếu có]

## Linked REQs

[BA điền sau khi viết requirements]

## GoLive Status

[TEST điền sau khi chạy QA]
```

Sau đó thêm dòng vào `us/_index.md`:
```markdown
| [US-NNN](US-NNN.md) | Title | High/Med/Low | draft | — | — | ⬛ |
```

---

## US Status Lifecycle

```
draft → ac-ready → in-dev → in-test → done
              ↑BA        ↑DEV      ↑TEST    ↑PM+TEST
```

| Status | Nghĩa | Ai set |
|--------|-------|--------|
| `draft` | PM vừa tạo, BA chưa viết ACs | PM |
| `ac-ready` | BA đã viết ACs xong, DEV có thể bắt đầu | BA |
| `in-dev` | DEV đang implement | DEV |
| `in-test` | DEV xong, TEST đang viết/chạy TCs | DEV |
| `done` | TEST báo 🟢, US hoàn thành | PM xác nhận |

---

## Dashboard `us/_index.md`

Format bảng:

```markdown
# US Dashboard

**Updated:** YYYY-MM-DD

| US | Title | Priority | Status | Linked REQs | GoLive | Sprint |
|----|-------|----------|--------|-------------|--------|--------|
| [US-001](US-001.md) | Tên US | High | ac-ready | REQ-1 | 🟡 | Q3-S1 |
| [US-002](US-002.md) | Tên US | Medium | draft | — | ⬛ | Q3-S2 |
```

GoLive lấy từ `REQ-Coverage-Matrix.md` — PM đọc matrix để biết status thực tế.

---

## Cập nhật status (`/pm update`)

Edit dòng `status:` trong frontmatter của US-NNN.md và cập nhật bảng trong `_index.md`.

---

## Nguyên tắc viết US tốt

- **User Story**: luôn dùng format "Là một [role], tôi muốn..., để..."
- **Business Context**: viết cho BA, không phải cho DEV — giải thích WHY, không HOW
- **Scope Notes**: đủ để BA hiểu phạm vi, không phải spec kỹ thuật
- **Out of Scope**: rõ ràng để tránh scope creep
- **1 US = 1 deliverable** — nếu US quá lớn, tách thành nhiều US con
