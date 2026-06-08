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

# ── Xóa tất cả CLAUDE.*.md — đã copy vào CLAUDE.md rồi, không cần nữa ────────
for r in "${VALID_ROLES[@]}"; do
  f="CLAUDE.${r}.md"
  if [[ -f "$f" ]]; then
    rm "$f"
    git update-index --skip-worktree "$f" 2>/dev/null || true
  fi
done
echo "🗑️  Đã xóa tất cả CLAUDE.*.md (nội dung đã có trong CLAUDE.md)"

# ── Skills — copy đúng skill cho từng role ───────────────────────────────────
TEMPLATE_SKILLS=".claude/templates/skills"
SKILLS_DIR=".claude/skills"
mkdir -p "$SKILLS_DIR"

case "$ROLE" in
  pm)  ROLE_SKILL_LIST="pm" ;;
  ba)  ROLE_SKILL_LIST="requirements" ;;
  dev) ROLE_SKILL_LIST="design" ;;
  qc)  ROLE_SKILL_LIST="qa testing" ;;
esac

for skill in $ROLE_SKILL_LIST; do
  cp -r "$TEMPLATE_SKILLS/$skill" "$SKILLS_DIR/$skill"
done
# Global skills — copy cho mọi role
for skill in task drift; do
  cp -r "$TEMPLATE_SKILLS/$skill" "$SKILLS_DIR/$skill"
done
echo "📦 Skills đã copy: $ROLE_SKILL_LIST + task drift (global)"

# ── Testing folder — chỉ init cho QC ────────────────────────────────────────
TEMPLATE_TESTING=".claude/templates/testing"

if [[ "$ROLE" == "qc" ]]; then
  mkdir -p testing/specs testing/artifacts testing/fixtures
  cp "$TEMPLATE_TESTING/playwright.config.ts" testing/playwright.config.ts
  cp "$TEMPLATE_TESTING/global-setup.ts" testing/global-setup.ts
  cp "$TEMPLATE_TESTING/fixtures/test.ts" testing/fixtures/test.ts
  echo "🧪 testing/ đã được khởi tạo cho QC"
else
  # Xóa testing/ khỏi working tree (trừ artifacts — mọi role đọc được)
  if [[ -d testing ]]; then
    find testing -type f ! -path "testing/artifacts/*" | while read f; do
      git update-index --skip-worktree "$f" 2>/dev/null || true
      rm -f "$f"
    done
    # Dọn thư mục rỗng
    find testing -mindepth 1 -type d -empty -delete 2>/dev/null || true
  fi
  echo "📋 testing/artifacts/ có sẵn để đọc (REQ Coverage Matrix)"
fi

# ── src/ — chỉ DEV và QC cần ────────────────────────────────────────────────
if [[ "$ROLE" != "dev" ]]; then
  if [[ -d src ]]; then
    find src -type f | while read f; do
      git update-index --skip-worktree "$f" 2>/dev/null || true
      rm -f "$f"
    done
    find src -mindepth 1 -type d -empty -delete 2>/dev/null || true
    rmdir src 2>/dev/null || true
  fi
  echo "🚫 src/ đã ẩn (không cần cho role $ROLE)"
fi

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
