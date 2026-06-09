# Agile AI APS — Template

> **Workflow đầy đủ:** [.claude/docs/workflow.md](.claude/docs/workflow.md) — mô tả toàn bộ quy trình PM → BA → DEV → TEST, handoff giữa các role, và cách tích hợp Claude Code.

Bộ khung workflow tích hợp Claude Code cho team **PM → BA → DEV → TEST**.

## Cấu trúc

```
agile-ai-aps/
├── CLAUDE.md              # Shared base rules + workflow overview
├── CLAUDE.pm.md           # PM role — đặt làm CLAUDE.md trong pm-workspace
├── CLAUDE.ba.md           # BA role — đặt làm CLAUDE.md trong ba-workspace
├── CLAUDE.dev.md          # DEV role — đặt làm CLAUDE.md trong dev-workspace
├── CLAUDE.test.md         # TEST role — đặt làm CLAUDE.md trong test-workspace
├── sync.sh                # Pull từ master repo
│
├── .claude/
│   ├── settings.json      # Permissions
│   ├── docs/
│   │   ├── us/            # PM: User Stories
│   │   │   └── _index.md  # PM dashboard
│   │   ├── requirements.md # BA: Acceptance Criteria
│   │   ├── design.md       # DEV: Architecture design
│   │   └── tasks/          # DEV: Implementation tasks
│   ├── skills/
│   │   ├── pm/            # /pm skill
│   │   ├── requirements/  # /requirements skill
│   │   ├── design/        # /design skill
│   │   ├── task/          # /task skill
│   │   ├── testing/       # /testing skill
│   │   └── qa/            # /qa skill
│   └── template/          # Document templates
│
└── testing/
    ├── fixtures/test.ts   # Test fixtures (adapt cho project)
    ├── pages/             # Page objects
    ├── specs/             # Test specs
    ├── playwright.config.ts
    └── artifacts/
        └── REQ-Coverage-Matrix.md
```

## Quick Start

### 1. Init project mới

```bash
# Copy template
cp -r agile-ai-aps my-project && cd my-project
git init && git add . && git commit -m "init: agile-ai-aps template"

# Push lên GitHub
gh repo create company/my-project --private
git remote add origin git@github.com:company/my-project.git
git push -u origin main
```

### 2. Mỗi role dùng một Claude Code workspace riêng

Mỗi role mở thư mục riêng trong Claude Code và đặt `CLAUDE.md` đúng role:

```bash
cp CLAUDE.pm.md   pm-workspace/CLAUDE.md    # PM
cp CLAUDE.ba.md   ba-workspace/CLAUDE.md    # BA
cp CLAUDE.dev.md  dev-workspace/CLAUDE.md   # DEV
cp CLAUDE.test.md test-workspace/CLAUDE.md  # QC
```

### 3. Cài hooks (một lần duy nhất)

```bash
bash .claude/setup-hooks.sh
```

Hooks tự động:
- Detect handoff commit → unblock task của role tiếp theo
- Rebuild `_index.md` mỗi khi TASK-*.md hoặc US-*.md thay đổi

### 4. Adapt cho tech stack

- `testing/fixtures/test.ts` — thay `apiClient` bằng client thực tế
- `testing/global-setup.ts` — implement auth flow
- `testing/playwright.config.ts` — cập nhật `BASE_URL`
- `.claude/skills/testing/SKILL.md` — chọn adapter (Playwright/Detox/pytest)

### 5. Rename project

Thay `[PROJECT_NAME]` trong các file:
- `CLAUDE.md`, `.claude/docs/us/_index.md`, `.claude/docs/tasks/_index.md`
- `testing/artifacts/REQ-Coverage-Matrix.md`

## Workflow Chain

```
PM: /pm create US-NNN
  → auto-gen 3 stub tasks (BA req-write, DEV feature, QC tc-write)
  → commit handoff(US-NNN → BA)
     [🤖 hook] → BA task: Blocked → Ready

BA: /requirements US-NNN → viết REQ-N.md
  → commit handoff(US-NNN → DEV)
     [🤖 hook] → DEV task: Ready + QC task: Ready (tc-draft, song song)

DEV: /design draft REQ-N → implement src/ → /design verify REQ-N
  → commit handoff(US-NNN → QC)
     [🤖 hook] → QC task: Ready (tc-run)

QC: /regression task TASK-N → /qa run REQ-N → /qa matrix
  PASS → handoff(US-NNN → PM) → PM: /pm done US-NNN
  FAIL → bug report → handoff(US-NNN → DEV)
```

> Xem sơ đồ đầy đủ và bảng manual/automated: [.claude/docs/workflow.md](.claude/docs/workflow.md)

## Automation Coverage

| Loại | 🤖 Auto | 🧠 AI-assisted | ✍️ Thủ công |
|------|---------|----------------|------------|
| Index sync (`_index.md`) | ✅ | | |
| Handoff detect + task unblock | ✅ | | |
| Tạo US / stub tasks | | ✅ | |
| Viết ACs, design, task plan | | ✅ | |
| Regression analysis + test run | | ✅ | |
| Viết code, assertions | | | ✅ |
| git pull / push / PR | | | ✅ |
| Quyết định scope, priority | | | ✅ |

## Sync với Master

```bash
./sync.sh
```

## Hiện trạng — Todo Manager (2026-06-09)

**Project đang chạy thực tế:** `Todo Manager`

### User Stories

| US | Title | Priority | Status | Sprint |
|----|-------|----------|--------|--------|
| [US-001](.claude/docs/us/US-001.md) | Quản lý danh sách công việc (Todo CRUD) | High | **in-test** | 2026-Q3-S1 |
| [US-002](.claude/docs/us/US-002.md) | Chia sẻ danh sách todo với người khác | Medium | draft | 2026-Q3-S2 |
| [US-003](.claude/docs/us/US-003.md) | Đặt due date và nhắc nhở cho todo | Medium | draft | 2026-Q3-S2 |
| [US-004](.claude/docs/us/US-004.md) | Phân loại todo bằng tag | Low | draft | 2026-Q3-S3 |

**Tiến độ:** 0/4 done · 1 in-test · 3 draft

### Tasks

| Task | Role | Title | Status |
|------|------|-------|--------|
| [TASK-001](.claude/docs/tasks/TASK-001.md) | DEV | Implement Todo CRUD | ✅ Done |
| [TASK-002](.claude/docs/tasks/TASK-002.md) | BA | Viết ACs — US-002 | Ready |
| [TASK-003](.claude/docs/tasks/TASK-003.md) | DEV | Implement — US-002 | Blocked ← TASK-002 |
| [TASK-004](.claude/docs/tasks/TASK-004.md) | QC | Viết TCs — US-002 | Blocked ← TASK-003 |
| [TASK-005](.claude/docs/tasks/TASK-005.md) | BA | Viết ACs — US-003 | Ready |
| [TASK-006](.claude/docs/tasks/TASK-006.md) | DEV | Implement — US-003 | Blocked ← TASK-005 |
| [TASK-007](.claude/docs/tasks/TASK-007.md) | QC | Viết TCs — US-003 | Blocked ← TASK-006 |
| [TASK-008](.claude/docs/tasks/TASK-008.md) | BA | Viết ACs — US-004 | Ready |
| [TASK-009](.claude/docs/tasks/TASK-009.md) | DEV | Implement — US-004 | Blocked ← TASK-008 |

### Artifacts có sẵn

- Requirements: [REQ-1](.claude/docs/requirements/REQ-1.md)
- Design: [REQ-1](.claude/docs/design/REQ-1.md)

### Bottleneck hiện tại

BA cần hoàn thành TASK-002, TASK-005, TASK-008 (viết ACs cho US-002/003/004) để unblock toàn bộ pipeline DEV + QC của Sprint S2/S3.

## Skills Reference

| Skill | Role | Mô tả |
|-------|------|--------|
| `/pm` | PM | Tạo/quản lý User Stories |
| `/requirements` | BA | Viết ACs từ US |
| `/design` | DEV | Gen/update design.md |
| `/task` | DEV | Plan + implement tasks |
| `/testing` | TEST | Gen test scripts từ requirements |
| `/qa` | TEST | Chạy QA, maintain matrix |
