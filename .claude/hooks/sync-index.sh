#!/bin/bash
# sync-index.sh
# Auto-rebuild _index.md for tasks/ and us/ when their files change.
# Triggered by Claude Code PostToolUse (Write/Edit) + can run manually.

set -uo pipefail

TASKS_DIR=".claude/docs/tasks"
US_DIR=".claude/docs/us"
TODAY=$(date +%Y-%m-%d)

# ── Detect what changed ────────────────────────────────────────────────────────
CHANGED=$(git status --porcelain 2>/dev/null | awk '{print $2}')

NEED_TASKS=false
NEED_US=false

if echo "$CHANGED" | grep -qE "docs/tasks/TASK-[0-9]+\.md"; then
  NEED_TASKS=true
fi
if echo "$CHANGED" | grep -qE "docs/us/US-[0-9]+\.md"; then
  NEED_US=true
fi

# Manual run with no changes: rebuild everything
if [ -z "$CHANGED" ]; then
  NEED_TASKS=true
  NEED_US=true
fi

# ── Rebuild tasks/_index.md ────────────────────────────────────────────────────
rebuild_tasks() {
  local index="$TASKS_DIR/_index.md"
  local project
  project=$(grep -h "^\*\*Project:" "$TASKS_DIR/_index.md" 2>/dev/null | head -1 | sed 's/\*\*Project:\*\* //' || echo "Todo Manager")

  # Build table rows sorted by task number
  local rows=""
  for f in $(ls "$TASKS_DIR"/TASK-*.md 2>/dev/null | sort -V); do
    local task_id
    task_id=$(basename "$f" .md)

    local role type title status completed
    role=$(grep    "^\*\*Role:\*\*"      "$f" 2>/dev/null | head -1 | sed 's/^\*\*Role:\*\* //'      || true)
    type=$(grep    "^\*\*Type:\*\*"      "$f" 2>/dev/null | head -1 | sed 's/^\*\*Type:\*\* //'      || true)
    title=$(grep   "^\*\*Title:\*\*"     "$f" 2>/dev/null | head -1 | sed 's/^\*\*Title:\*\* //'     || true)
    status=$(grep  "^\*\*Status:\*\*"    "$f" 2>/dev/null | head -1 | sed 's/^\*\*Status:\*\* //'    || true)
    completed=$(grep "^Completed At:"   "$f" 2>/dev/null | head -1 | sed 's/^Completed At: //'       || true)

    role="${role:-—}"
    type="${type:-—}"
    title="${title:-—}"
    status="${status:-—}"
    completed="${completed:-—}"

    rows+="| [$task_id]($task_id.md) | $role | $title | $type | $status | $completed |"$'\n'
  done

  cat > "$index" << EOF
# Task Index

**Project:** $project
**Updated:** $TODAY

| Task | Role | Title | Type | Status | Completed |
|------|------|-------|------|--------|-----------|
${rows}
---

## Status Legend

| Status | Nghĩa |
|--------|-------|
| Ready | Stub task do PM tạo, role owner điền Plan rồi chuyển Pending Approval |
| Pending Approval | Plan đã viết, chờ confirm "làm" |
| In Progress | Đang implement |
| Blocked ← TASK-N | Chờ TASK-N hoàn thành trước |
| Done | Hoàn thành, đã đóng |
| Cancelled | Hủy |
EOF

  echo "🔄 tasks/_index.md synced ($(ls "$TASKS_DIR"/TASK-*.md 2>/dev/null | wc -l | tr -d ' ') tasks)"
}

# ── Rebuild us/_index.md ───────────────────────────────────────────────────────
rebuild_us() {
  local index="$US_DIR/_index.md"

  # Count statuses
  local cnt_draft cnt_ac_ready cnt_in_dev cnt_in_test cnt_done
  cnt_draft=$(grep -rl "^status: draft" "$US_DIR"/US-*.md 2>/dev/null | wc -l | tr -d ' ')
  cnt_ac_ready=$(grep -rl "^status: ac-ready" "$US_DIR"/US-*.md 2>/dev/null | wc -l | tr -d ' ')
  cnt_in_dev=$(grep -rl "^status: in-dev" "$US_DIR"/US-*.md 2>/dev/null | wc -l | tr -d ' ')
  cnt_in_test=$(grep -rl "^status: in-test" "$US_DIR"/US-*.md 2>/dev/null | wc -l | tr -d ' ')
  cnt_done=$(grep -rl "^status: done" "$US_DIR"/US-*.md 2>/dev/null | wc -l | tr -d ' ')

  local total=$(ls "$US_DIR"/US-*.md 2>/dev/null | wc -l | tr -d ' ')
  local progress="$cnt_done / $total"

  # Build table rows
  local rows=""
  for f in $(ls "$US_DIR"/US-*.md 2>/dev/null | sort -V); do
    local code title priority status sprint linked_reqs
    # Parse YAML frontmatter (between first and second ---)
    code=$(awk '/^---/{f++} f==1 && /^code:/{print}' "$f" | sed 's/^code: //')
    title=$(awk '/^---/{f++} f==1 && /^title:/{print}' "$f" | sed 's/^title: //')
    priority=$(awk '/^---/{f++} f==1 && /^priority:/{print}' "$f" | sed 's/^priority: //')
    status=$(awk '/^---/{f++} f==1 && /^status:/{print}' "$f" | sed 's/^status: //')
    sprint=$(awk '/^---/{f++} f==1 && /^sprint:/{print}' "$f" | sed 's/^sprint: //')

    # Linked REQs (from body, not frontmatter)
    linked_reqs=$(grep "^## Linked REQs" -A 3 "$f" 2>/dev/null | grep "REQ-" | tr '\n' ',' | sed 's/,$//' | sed 's/^[- ]*//' || echo "—")
    [ -z "$linked_reqs" ] && linked_reqs="—"

    code="${code:-$(basename $f .md)}"
    title="${title:-—}"
    priority="${priority:-—}"
    status="${status:-—}"
    sprint="${sprint:-—}"

    local us_id
    us_id=$(basename "$f" .md)
    rows+="| [$us_id]($us_id.md) | $title | $priority | $status | $linked_reqs | ⬛ | $sprint |"$'\n'
  done

  cat > "$index" << EOF
# US Dashboard

**Project:** Todo Manager
**Updated:** $TODAY

## Summary

| Status | Count |
|--------|-------|
| draft | $cnt_draft |
| ac-ready | $cnt_ac_ready |
| in-dev | $cnt_in_dev |
| in-test | $cnt_in_test |
| done | $cnt_done |

**Progress:** $progress

## US List

| US | Title | Priority | Status | Linked REQs | GoLive | Sprint |
|----|-------|----------|--------|-------------|--------|--------|
${rows}
---

## Status Legend

| Status | Nghĩa |
|--------|-------|
| \`draft\` | PM tạo, BA chưa viết ACs |
| \`ac-ready\` | BA viết ACs xong, DEV có thể bắt đầu |
| \`in-dev\` | DEV đang implement |
| \`in-test\` | DEV xong, TEST đang viết/chạy TCs |
| \`done\` | TEST 🟢, US hoàn thành |

## GoLive Legend

| Symbol | Nghĩa |
|--------|-------|
| 🟢 | Ready — 100% testable ACs pass |
| 🟡 | Partial — không có ❌, còn gap hoặc chưa chạy |
| 🔴 | Blocked — có ❌ fail |
| ⬛ | Not started / Skip |

> GoLive được cập nhật bởi QC qua \`/qa matrix\`.
EOF

  echo "🔄 us/_index.md synced ($total USs)"
}

# ── Run ────────────────────────────────────────────────────────────────────────
if [ "$NEED_TASKS" = "true" ]; then rebuild_tasks; fi
if [ "$NEED_US"    = "true" ]; then rebuild_us;    fi

exit 0
