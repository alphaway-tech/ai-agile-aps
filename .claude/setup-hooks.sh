#!/bin/bash
# setup-hooks.sh
# Cài git post-commit hook để auto-detect handoff commits.
# Chạy 1 lần sau khi clone repo:  bash .claude/setup-hooks.sh

set -e

HOOK_DIR=".git/hooks"
HOOK_FILE="$HOOK_DIR/post-commit"
SCRIPT=".claude/hooks/detect-handoff.sh"

# Verify we're in the repo root
if [ ! -d "$HOOK_DIR" ]; then
  echo "❌ Không tìm thấy .git/hooks/ — chạy từ repo root"
  exit 1
fi

if [ ! -f "$SCRIPT" ]; then
  echo "❌ Không tìm thấy $SCRIPT"
  exit 1
fi

# Check if hook already exists (non-empty)
if [ -s "$HOOK_FILE" ]; then
  echo "⚠️  post-commit hook đã tồn tại:"
  echo "   $(cat $HOOK_FILE)"
  echo ""
  read -p "Ghi đè? (y/N) " -n 1 -r
  echo
  [[ ! $REPLY =~ ^[Yy]$ ]] && echo "Cancelled." && exit 0
fi

cat > "$HOOK_FILE" << 'EOF'
#!/bin/bash
# Auto-installed by .claude/setup-hooks.sh
bash .claude/hooks/detect-handoff.sh
EOF

chmod +x "$HOOK_FILE"

echo "✅ Git post-commit hook installed: $HOOK_FILE"
echo "   Từ giờ mỗi commit sẽ tự detect handoff pattern."
