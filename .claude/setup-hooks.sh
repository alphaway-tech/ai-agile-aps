#!/bin/bash
# setup-hooks.sh
# Cài git hooks: post-commit (handoff detection) + commit-msg (format validator)
# Chạy 1 lần sau khi clone repo:  bash .claude/setup-hooks.sh

set -e

HOOK_DIR=".git/hooks"
POST_COMMIT_HOOK="$HOOK_DIR/post-commit"
COMMIT_MSG_HOOK="$HOOK_DIR/commit-msg"

# Verify we're in the repo root
if [ ! -d "$HOOK_DIR" ]; then
  echo "❌ Không tìm thấy .git/hooks/ — chạy từ repo root"
  exit 1
fi

if [ ! -f ".claude/hooks/detect-handoff.sh" ]; then
  echo "❌ Không tìm thấy .claude/hooks/detect-handoff.sh"
  exit 1
fi

install_hook() {
  local HOOK_FILE="$1"
  local HOOK_BODY="$2"
  local HOOK_NAME="$3"

  if [ -s "$HOOK_FILE" ]; then
    echo "⚠️  $HOOK_NAME hook đã tồn tại. Ghi đè? (y/N)"
    read -r -n 1 REPLY; echo
    [[ ! "$REPLY" =~ ^[Yy]$ ]] && echo "   Skipped $HOOK_NAME." && return
  fi

  echo "$HOOK_BODY" > "$HOOK_FILE"
  chmod +x "$HOOK_FILE"
  echo "✅ $HOOK_NAME hook installed: $HOOK_FILE"
}

# ── post-commit: detect handoff + unblock task ────────────────────────────────
install_hook "$POST_COMMIT_HOOK" '#!/bin/bash
bash .claude/hooks/detect-handoff.sh' "post-commit"

# ── commit-msg: validate handoff format ──────────────────────────────────────
install_hook "$COMMIT_MSG_HOOK" '#!/bin/bash
bash .claude/hooks/validate-handoff-msg.sh "$1"' "commit-msg"

echo ""
echo "🎯 Shortcuts:"
echo "   bash .claude/hooks/handoff.sh US-NNN ROLE \"message\"  ← tạo handoff commit"
echo "   git log --oneline --grep='handoff'                   ← xem handoff log"
