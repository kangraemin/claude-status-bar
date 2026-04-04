#!/bin/bash
set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
TARGET="${CLAUDE_DIR}/statusline.sh"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="${SCRIPT_DIR}/statusline.sh"

echo "🔄 Updating claude-status-bar..."

if [ ! -f "$TARGET" ]; then
  echo "❌ ${TARGET} not found. Run install.sh first."
  exit 1
fi

# 변경 확인
if diff -q "$SOURCE" "$TARGET" &>/dev/null; then
  echo "✅ Already up to date."
  exit 0
fi

cp "$SOURCE" "$TARGET"
chmod +x "$TARGET"
echo "✅ Updated statusline.sh"

echo ""
echo "🎉 Done! Restart Claude Code to apply changes."
