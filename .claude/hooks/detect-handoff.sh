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
  # No blocked task found — if handoff → DEV, this is likely QC→DEV fail: auto-increment qc_dev_rounds
  if [ "$ROLE" = "DEV" ]; then
    US_FILE=$(grep -rl "^code: $US" ".claude/docs/us/" 2>/dev/null | head -1)
    if [ -n "$US_FILE" ]; then
      CURRENT=$(grep "^qc_dev_rounds:" "$US_FILE" 2>/dev/null | sed 's/qc_dev_rounds: *//')
      CURRENT=${CURRENT:-0}
      NEW=$((CURRENT + 1))
      sed -i '' "s/^qc_dev_rounds:.*/qc_dev_rounds: $NEW/" "$US_FILE"
      git add "$US_FILE"
      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "📬 Handoff: $US → DEV  (QC fail re-handoff)"
      echo "   🔄 qc_dev_rounds: $CURRENT → $NEW (auto)"
      if [ "$NEW" -ge 2 ]; then
        echo "   ⚠️  ESCALATE: $US đã ping-pong DEV↔QC $NEW lần — báo PM/BA"
      fi
      echo ""
      echo "   ⚡ git pull origin main   ← chạy trước khi bắt đầu"
      echo "   👉 DEV: đọc bug report trong handoff commit"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    else
      echo "📬 Handoff: $US → $ROLE (no blocked task + no US file found)"
    fi
  else
    echo "📬 Handoff: $US → $ROLE (no blocked task found to unblock)"
  fi
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
echo "   ⚡ git pull origin main   ← chạy trước khi bắt đầu"
echo "   👉 $ROLE: mở $TASK_ID.md"
echo "      Điền Approach + Plan → Pending Approval"
echo "      Bảo Claude 'làm' để bắt đầu"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
