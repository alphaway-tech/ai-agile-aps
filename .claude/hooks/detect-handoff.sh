#!/bin/bash
# detect-handoff.sh
# Detect handoff(US-NNN → ROLE) pattern in latest commit → auto-update task status
# Called by: git post-commit hook + Claude Code PostToolUse hook

# Read latest commit message
MSG=$(git log -1 --pretty=%s 2>/dev/null)
[ -z "$MSG" ] && exit 0

# Match pattern: handoff(US-NNN → ROLE): ...
# Support both ASCII arrow (->) and Unicode arrow (→)
PATTERN='^handoff\(([A-Z]+-[0-9]+)[[:space:]]*(→|->)[[:space:]]*([A-Z]+)\)'
if [[ ! "$MSG" =~ $PATTERN ]]; then
  exit 0
fi

US="${BASH_REMATCH[1]}"    # e.g. US-001
ROLE="${BASH_REMATCH[3]}"  # e.g. QC

TASKS_DIR=".claude/docs/tasks"
[ ! -d "$TASKS_DIR" ] && exit 0

FOUND=""
TASK_ID=""

# Find task file matching: US Reference + Role + Blocked status
for f in "$TASKS_DIR"/TASK-*.md; do
  [ -f "$f" ] || continue
  if grep -q "US Reference.*$US" "$f" 2>/dev/null && \
     grep -q "^\*\*Role:\*\* $ROLE" "$f" 2>/dev/null && \
     grep -q "^\*\*Status:\*\* Blocked" "$f" 2>/dev/null; then
    FOUND="$f"
    TASK_ID=$(basename "$f" .md)
    break
  fi
done

if [ -z "$FOUND" ]; then
  # No blocked task found for this role+US — might already be unblocked or not exist
  echo ""
  echo "📬 Handoff detected: $US → $ROLE (no blocked task found to unblock)"
  exit 0
fi

# Update Status: Blocked → Ready
# macOS sed requires '' after -i
sed -i '' "s/^\*\*Status:\*\* Blocked.*/\*\*Status:\*\* Ready/" "$FOUND"

# Stage the updated file
git add "$FOUND"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📬 Handoff: $US → $ROLE"
echo "   $TASK_ID: Blocked → Ready (staged)"
echo ""
echo "   👉 $ROLE: mở $TASK_ID.md"
echo "      Điền Approach + Plan → Pending Approval"
echo "      Bảo Claude 'làm' để bắt đầu"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
