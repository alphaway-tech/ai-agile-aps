#!/bin/bash
# inject-settings.sh — Inject PostToolUse hooks vào .claude/settings.json
# Idempotent: bỏ qua nếu PostToolUse đã có.
# Chạy bởi setup.sh khi khởi tạo workspace mới.
# Manual: bash .claude/hooks/inject-settings.sh

SETTINGS=".claude/settings.json"

if [ ! -f "$SETTINGS" ]; then
  echo "❌ $SETTINGS không tồn tại"
  exit 1
fi

# Bỏ qua nếu đã inject
if python3 -c "
import json, sys
d = json.load(open('$SETTINGS'))
sys.exit(0 if 'PostToolUse' in d.get('hooks', {}) else 1)
" 2>/dev/null; then
  echo "✅ Hooks đã có trong $SETTINGS — bỏ qua"
  exit 0
fi

python3 - "$SETTINGS" <<'PYEOF'
import json, sys

path = sys.argv[1]
with open(path) as f:
    cfg = json.load(f)

cfg.setdefault('hooks', {})['PostToolUse'] = [
    {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "bash .claude/hooks/detect-handoff.sh 2>/dev/null || true"}]
    },
    {
        "matcher": "Write",
        "hooks": [{"type": "command", "command": "bash .claude/hooks/sync-index.sh 2>/dev/null || true"}]
    },
    {
        "matcher": "Edit",
        "hooks": [{"type": "command", "command": "bash .claude/hooks/sync-index.sh 2>/dev/null || true"}]
    }
]

with open(path, 'w') as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
    f.write('\n')

print("✅ PostToolUse hooks injected vào", path)
PYEOF
