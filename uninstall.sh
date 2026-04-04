#!/bin/bash
set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
SETTINGS="${CLAUDE_DIR}/settings.json"
TARGET="${CLAUDE_DIR}/statusline.sh"

echo "🗑️  Uninstalling claude-status-bar..."

# 1. statusline.sh 삭제
if [ -f "$TARGET" ]; then
  rm "$TARGET"
  echo "✅ Removed ${TARGET}"
else
  echo "⚠️  ${TARGET} not found — skipping."
fi

# 2. settings.json에서 statusLine 제거
if [ ! -f "$SETTINGS" ]; then
  echo "⚠️  ${SETTINGS} not found — skipping."
  exit 0
fi

PY=$(command -v python3 || command -v python || command -v py)
if [ -z "$PY" ]; then
  echo "❌ python3 not found. Please remove statusLine from settings.json manually."
  exit 1
fi

$PY -c "
import json

path = '$SETTINGS'
with open(path) as f:
    data = json.load(f)

if 'statusLine' not in data:
    print('⚠️  statusLine not found in settings.json — skipping.')
else:
    del data['statusLine']
    with open(path, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write('\n')
    print('✅ Removed statusLine from settings.json.')
"

echo ""
echo "🎉 Done! Restart Claude Code to apply changes."
