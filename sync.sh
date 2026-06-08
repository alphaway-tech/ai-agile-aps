#!/bin/bash
# sync.sh — Pull latest từ master repo trước khi bắt đầu làm việc
# Chạy: ./sync.sh

set -e

MASTER_REMOTE="upstream"

# Kiểm tra upstream remote đã được set chưa
if ! git remote | grep -q "$MASTER_REMOTE"; then
  echo "⚠️  Upstream remote chưa được cấu hình."
  echo "Chạy: git remote add upstream <master-repo-url>"
  exit 1
fi

echo "📥 Pulling từ master..."
git fetch "$MASTER_REMOTE"
git merge "$MASTER_REMOTE/main" --no-edit

echo "✅ Sync xong. Sẵn sàng làm việc."
echo ""
echo "Branch hiện tại: $(git branch --show-current)"
echo "Latest commit:   $(git log --oneline -1)"
