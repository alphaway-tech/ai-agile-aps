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

Commit với format:
```
us(US-NNN): [title] — draft
```

Sau đó chạy `/pm sync` để cập nhật `_index.md`.

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
