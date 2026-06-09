#!/bin/bash
# handoff.sh — Tạo handoff commit đúng format
# Usage: bash .claude/hooks/handoff.sh US-NNN ROLE "mô tả ngắn"
# Ví dụ: bash .claude/hooks/handoff.sh US-001 QC "TASK-003 done"

US="$1"
ROLE="$2"
MSG="$3"

# Validate args
if [ -z "$US" ] || [ -z "$ROLE" ] || [ -z "$MSG" ]; then
  echo "❌ Thiếu tham số."
  echo "   Usage: bash .claude/hooks/handoff.sh US-NNN ROLE \"mô tả\""
  echo "   Ví dụ: bash .claude/hooks/handoff.sh US-001 QC \"TASK-003 done\""
  exit 1
fi

# Validate US format
if [[ ! "$US" =~ ^[A-Z]+-[0-9]+$ ]]; then
  echo "❌ US format sai: '$US' — phải là dạng US-001, US-012, ..."
  exit 1
fi

# Validate ROLE
VALID_ROLES="PM BA DEV QC"
if [[ ! " $VALID_ROLES " =~ " $ROLE " ]]; then
  echo "❌ ROLE không hợp lệ: '$ROLE' — phải là: PM BA DEV QC"
  exit 1
fi

# Check có staged changes không (hoặc cho phép chạy dù không có staged changes)
STAGED=$(git diff --cached --name-only 2>/dev/null)
if [ -z "$STAGED" ]; then
  echo "⚠️  Không có staged changes. Bạn có muốn commit chỉ với handoff message không? (y/N)"
  read -r -n 1 CONFIRM
  echo
  [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && echo "Cancelled." && exit 0
fi

# Build commit message — dùng Unicode →
COMMIT_MSG="handoff($US → $ROLE): $MSG"

echo "📤 Committing:"
echo "   $COMMIT_MSG"
echo ""

git commit -m "$COMMIT_MSG"

echo ""
echo "✅ Handoff committed. detect-handoff.sh sẽ tự xử lý unblock."
