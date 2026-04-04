#!/bin/bash
input=$(cat)

# jq 또는 python3으로 JSON 파싱
parse() {
  local field="$1"
  local default="$2"
  if command -v jq &>/dev/null; then
    echo "$input" | jq -r "$field // \"$default\""
  else
    local py=$(command -v python3 || command -v python || command -v py)
    [ -z "$py" ] && { echo "$default"; return; }
    echo "$input" | $py -c "
import sys, json
data = json.load(sys.stdin)
keys = '$field'.strip('.').split('.')
val = data
for k in keys:
    val = val.get(k, '$default') if isinstance(val, dict) else '$default'
print(val)
" 2>/dev/null || echo "$default"
  fi
}

MODEL=$(parse '.model.display_name' 'unknown')
DIR=$(parse '.workspace.current_dir' '.')
COST=$(parse '.cost.total_cost_usd' '0')
DURATION_MS=$(parse '.cost.total_duration_ms' '0')
REM=$(parse '.context_window.remaining_percentage' '100')
REM=${REM%%.*}
PCT=$((100 - REM))
VERSION=$(parse '.version' '')

# git branch + dirty check
BRANCH=$(cd "$DIR" 2>/dev/null && git branch --show-current 2>/dev/null || echo "")
if [ -n "$BRANCH" ] && cd "$DIR" 2>/dev/null && ! git diff --quiet HEAD 2>/dev/null; then
  BRANCH="${BRANCH}*"
fi

# context bar (usage-based: fills up as you use more)
FILLED=$((PCT / 10))
EMPTY=$((10 - FILLED))
BAR=$(printf "%${FILLED}s" | tr ' ' '=')$(printf "%${EMPTY}s" | tr ' ' '-')

# cost / hourly rate
COST_FMT=$(printf '$%.2f' "$COST")
DURATION_S=${DURATION_MS%.*}
SECS=$((DURATION_S / 1000))
if [ "$SECS" -gt 0 ]; then
  PY=$(command -v python3 || command -v python || command -v py)
  HOURLY=$($PY -c "print(f'{$COST / $SECS * 3600:.2f}')" 2>/dev/null || echo "0.00")
  HOURLY_FMT="\$${HOURLY}/h"
else
  HOURLY_FMT='$0.00/h'
fi

# context warning icon
if [ "$PCT" -ge 80 ]; then
  CTX_ICON="❗"
elif [ "$PCT" -ge 70 ]; then
  CTX_ICON="⚠️"
else
  CTX_ICON="🧊"
fi

# output
echo "📁 ${DIR##*/} 🌿 $BRANCH 🧠 $MODEL 📦 v$VERSION"
echo "${CTX_ICON} Context: ${PCT}% [${BAR}] 💰 ${COST_FMT} (${HOURLY_FMT})"
