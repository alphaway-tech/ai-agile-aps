#!/bin/bash
# validate-handoff-msg.sh — Git commit-msg hook
# Reject commit nếu message bắt đầu "handoff" nhưng format sai.
# Installed by setup-hooks.sh vào .git/hooks/commit-msg

MSG_FILE="$1"
MSG=$(cat "$MSG_FILE")

# Chỉ validate nếu message bắt đầu bằng "handoff"
if [[ "$MSG" != handoff* ]]; then
  exit 0
fi

# Pattern: handoff(US-NNN → ROLE): ...
PATTERN='^handoff\([A-Z]+-[0-9]+ *(→|->) *[A-Z]+\):'

if [[ ! "$MSG" =~ $PATTERN ]]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "❌ Handoff commit format sai!"
  echo ""
  echo "   Đúng:  handoff(US-NNN → ROLE): mô tả"
  echo "   Sai:   $MSG"
  echo ""
  echo "   Cách nhanh nhất:"
  echo "   bash .claude/hooks/handoff.sh US-NNN ROLE \"mô tả\""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
fi

exit 0
