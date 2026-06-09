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
# Clone template
cp -r agile-ai-aps my-project
cd my-project
git init && git add . && git commit -m "init: agile-ai-aps template"

# Tạo GitHub repo và push
gh repo create company/my-project --private
git remote add origin git@github.com:company/my-project.git
git push -u origin main
```

### 2. Setup workspace cho từng role

```bash
# Fork master repo cho từng role
gh repo fork company/my-project --clone --fork-name pm-workspace
gh repo fork company/my-project --clone --fork-name ba-workspace
gh repo fork company/my-project --clone --fork-name dev-workspace
gh repo fork company/my-project --clone --fork-name test-workspace

# Trong mỗi workspace: đặt CLAUDE.md phù hợp
# PM workspace:
cp CLAUDE.pm.md pm-workspace/CLAUDE.md

# BA workspace:
cp CLAUDE.ba.md ba-workspace/CLAUDE.md

# DEV workspace:
cp CLAUDE.dev.md dev-workspace/CLAUDE.md

# TEST workspace:
cp CLAUDE.test.md test-workspace/CLAUDE.md
```

### 3. Adapt cho tech stack

- **`testing/fixtures/test.ts`** — thay `apiClient` bằng client thực tế
- **`testing/global-setup.ts`** — implement auth flow thực tế
- **`testing/playwright.config.ts`** — cập nhật `BASE_URL`
- **`.claude/skills/testing/SKILL.md`** — chọn adapter (Playwright/Detox/pytest)

### 4. Rename project

Thay `[PROJECT_NAME]` trong:
- `CLAUDE.md`
- `.claude/docs/us/_index.md`
- `.claude/docs/requirements.md`
- `.claude/docs/design.md`
- `.claude/docs/tasks/_index.md`
- `testing/artifacts/REQ-Coverage-Matrix.md`

## Workflow Chain

```
PM: /pm create US-001
  → BA: /requirements US-001
    → DEV: /task (tạo TASK-001)
      → TEST: /testing REQ-1 → /qa run REQ-1 → /qa matrix
```

## Sync với Master

Mỗi workspace chạy trước khi làm:
```bash
./sync.sh
```

## Skills Reference

| Skill | Role | Mô tả |
|-------|------|--------|
| `/pm` | PM | Tạo/quản lý User Stories |
| `/requirements` | BA | Viết ACs từ US |
| `/design` | DEV | Gen/update design.md |
| `/task` | DEV | Plan + implement tasks |
| `/testing` | TEST | Gen test scripts từ requirements |
| `/qa` | TEST | Chạy QA, maintain matrix |
