#!/bin/bash
set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
SETTINGS="${CLAUDE_DIR}/settings.json"
TARGET="${CLAUDE_DIR}/statusline.sh"
RAW_URL="https://raw.githubusercontent.com/kangraemin/claude-status-bar/main/statusline.sh"

echo "🔧 Installing claude-status-bar..."

# 1. ~/.claude 디렉토리 확인
if [ ! -d "$CLAUDE_DIR" ]; then
  echo "❌ ${CLAUDE_DIR} not found. Is Claude Code installed?"
  exit 1
fi

# 2. statusline.sh 가져오기 (로컬 우선, 없으면 다운로드)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/statusline.sh" ]; then
  cp "$SCRIPT_DIR/statusline.sh" "$TARGET"
  echo "✅ Copied statusline.sh → ${TARGET}"
else
  curl -fsSL "$RAW_URL" -o "$TARGET"
  echo "✅ Downloaded statusline.sh → ${TARGET}"
fi
chmod +x "$TARGET"

# 3. settings.json에 statusLine 설정 추가
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

PY=$(command -v python3 || command -v python || command -v py || true)
if [ -z "$PY" ]; then
  echo "❌ python3 not found. Please add statusLine config to settings.json manually:"
  echo '  "statusLine": { "type": "command", "command": "~/.claude/statusline.sh" }'
  exit 1
fi

$PY -c "
import json

path = '$SETTINGS'
with open(path) as f:
    data = json.load(f)

if 'statusLine' in data:
    print('⚠️  statusLine already configured — overwriting.')

data['statusLine'] = {
    'type': 'command',
    'command': '~/.claude/statusline.sh'
}

with open(path, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')

print('✅ Updated settings.json with statusLine config.')
"

echo ""
echo "🎉 Done! Restart Claude Code to see the status bar."
