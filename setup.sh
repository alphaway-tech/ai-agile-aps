#!/bin/bash
# setup.sh — Khởi tạo workspace cho một role cụ thể
# Chạy 1 lần duy nhất khi clone repo về
#
# Usage: ./setup.sh [pm|ba|dev|qc]
#
# Tác dụng:
#   1. Copy CLAUDE.<role>.md → CLAUDE.md (local-only, gitignored)
#   2. Nhắc cấu hình upstream remote nếu chưa có
#   3. Nhắc chạy sync.sh để pull dữ liệu mới nhất

set -e

ROLE="$1"
VALID_ROLES=("pm" "ba" "dev" "qc")
MASTER_REMOTE="upstream"

# ── Validate role ─────────────────────────────────────────────────────────────
if [[ -z "$ROLE" ]]; then
  echo "❌ Thiếu role. Usage: ./setup.sh [pm|ba|dev|qc]"
  exit 1
fi

VALID=false
for r in "${VALID_ROLES[@]}"; do
  [[ "$ROLE" == "$r" ]] && VALID=true && break
done

if [[ "$VALID" == false ]]; then
  echo "❌ Role không hợp lệ: '$ROLE'"
  echo "   Các role hợp lệ: ${VALID_ROLES[*]}"
  exit 1
fi

ROLE_FILE="CLAUDE.${ROLE}.md"

if [[ ! -f "$ROLE_FILE" ]]; then
  echo "❌ Không tìm thấy $ROLE_FILE trong repo."
  exit 1
fi

# ── Copy role file → CLAUDE.md ────────────────────────────────────────────────
cp "$ROLE_FILE" CLAUDE.md
echo "✅ CLAUDE.md đã được set cho role: $ROLE"
echo "   (gitignored — chỉ tồn tại local, không push lên master)"

# ── Kiểm tra upstream remote ─────────────────────────────────────────────────
if ! git remote | grep -q "$MASTER_REMOTE"; then
  echo ""
  echo "⚠️  Upstream remote chưa được cấu hình."
  echo "   Chạy: git remote add upstream <master-repo-url>"
  echo "   Sau đó: ./sync.sh"
else
  echo ""
  echo "📌 Remote upstream: $(git remote get-url $MASTER_REMOTE)"
  echo "   Chạy ./sync.sh để pull dữ liệu mới nhất từ master."
fi

echo ""
echo "🚀 Workspace '$ROLE' sẵn sàng. Mở Claude Code và bắt đầu làm việc."
