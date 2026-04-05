#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
TARGET="$CLAUDE_DIR/statusline.sh"

BACKUP_DIR=$(mktemp -d)
PASS=0
FAIL=0

# ── backup & restore ──────────────────────────────

backup() {
  [ -f "$SETTINGS" ] && cp "$SETTINGS" "$BACKUP_DIR/settings.json.bak"
  [ -f "$TARGET" ] && cp "$TARGET" "$BACKUP_DIR/statusline.sh.bak"
}

restore() {
  if [ -f "$BACKUP_DIR/settings.json.bak" ]; then
    cp "$BACKUP_DIR/settings.json.bak" "$SETTINGS"
  fi
  if [ -f "$BACKUP_DIR/statusline.sh.bak" ]; then
    cp "$BACKUP_DIR/statusline.sh.bak" "$TARGET"
    chmod +x "$TARGET"
  else
    rm -f "$TARGET"
  fi
  rm -rf "$BACKUP_DIR"
}

trap restore EXIT

# ── helpers ───────────────────────────────────────

assert_pass() {
  local tc="$1" desc="$2"
  PASS=$((PASS + 1))
  echo "  ✅ $tc: $desc"
}

assert_fail() {
  local tc="$1" desc="$2" reason="$3"
  FAIL=$((FAIL + 1))
  echo "  ❌ $tc: $desc — $reason"
}

has_statusline_key() {
  python3 -c "
import json
with open('$SETTINGS') as f:
    data = json.load(f)
exit(0 if 'statusLine' in data else 1)
"
}

get_json_key() {
  local key="$1"
  python3 -c "
import json
with open('$SETTINGS') as f:
    data = json.load(f)
print(data.get('$key', ''))
"
}

# prepare: statusLine 없는 깨끗한 settings.json
clean_settings() {
  python3 -c "
import json
with open('$SETTINGS') as f:
    data = json.load(f)
data.pop('statusLine', None)
with open('$SETTINGS', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
"
  rm -f "$TARGET"
}

echo "🧪 E2E Tests for claude-status-bar"
echo "   scripts: $SCRIPT_DIR"
echo "   target:  $CLAUDE_DIR"
echo ""

backup

# ══════════════════════════════════════════════════
# TC-01: install — 클린 설치
# ══════════════════════════════════════════════════
clean_settings
bash "$SCRIPT_DIR/install.sh" > /dev/null 2>&1
if [ -f "$TARGET" ] && has_statusline_key; then
  assert_pass "TC-01" "install: 클린 설치"
else
  assert_fail "TC-01" "install: 클린 설치" "statusline.sh 또는 statusLine 키 없음"
fi

# ══════════════════════════════════════════════════
# TC-02: install — 재설치 + 기존 키 보존
# ══════════════════════════════════════════════════
# 기존 키 하나 추가
python3 -c "
import json
with open('$SETTINGS') as f:
    data = json.load(f)
data['testMarker'] = 'keep-me'
with open('$SETTINGS', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
"
bash "$SCRIPT_DIR/install.sh" > /dev/null 2>&1
MARKER=$(get_json_key "testMarker")
if [ -f "$TARGET" ] && has_statusline_key && [ "$MARKER" = "keep-me" ]; then
  assert_pass "TC-02" "install: 재설치 + 기존 키 보존"
else
  assert_fail "TC-02" "install: 재설치 + 기존 키 보존" "덮어쓰기 또는 키 보존 실패"
fi
# testMarker 정리
python3 -c "
import json
with open('$SETTINGS') as f:
    data = json.load(f)
data.pop('testMarker', None)
with open('$SETTINGS', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
"

# ══════════════════════════════════════════════════
# TC-03: install — ~/.claude 없음 → exit 1
# ══════════════════════════════════════════════════
FAKE_HOME=$(mktemp -d)
HOME="$FAKE_HOME" bash "$SCRIPT_DIR/install.sh" > /dev/null 2>&1
EXIT_CODE=$?
rm -rf "$FAKE_HOME"
if [ "$EXIT_CODE" -eq 1 ]; then
  assert_pass "TC-03" "install: ~/.claude 없음 → exit 1"
else
  assert_fail "TC-03" "install: ~/.claude 없음 → exit 1" "exit code=$EXIT_CODE"
fi

# ══════════════════════════════════════════════════
# TC-04: uninstall — 정상 제거 + 다른 키 보존
# ══════════════════════════════════════════════════
# 먼저 설치
clean_settings
bash "$SCRIPT_DIR/install.sh" > /dev/null 2>&1
# 다른 키 추가
python3 -c "
import json
with open('$SETTINGS') as f:
    data = json.load(f)
data['otherKey'] = 'survive'
with open('$SETTINGS', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
"
bash "$SCRIPT_DIR/uninstall.sh" > /dev/null 2>&1
OTHER=$(get_json_key "otherKey")
if [ ! -f "$TARGET" ] && ! has_statusline_key && [ "$OTHER" = "survive" ]; then
  assert_pass "TC-04" "uninstall: 정상 제거 + 키 보존"
else
  assert_fail "TC-04" "uninstall: 정상 제거 + 키 보존" "삭제 또는 키 보존 실패"
fi
# otherKey 정리
python3 -c "
import json
with open('$SETTINGS') as f:
    data = json.load(f)
data.pop('otherKey', None)
with open('$SETTINGS', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
"

# ══════════════════════════════════════════════════
# TC-05: uninstall — 이미 제거된 상태
# ══════════════════════════════════════════════════
clean_settings
bash "$SCRIPT_DIR/uninstall.sh" > /dev/null 2>&1
EXIT_CODE=$?
if [ "$EXIT_CODE" -eq 0 ]; then
  assert_pass "TC-05" "uninstall: 이미 제거된 상태 → 정상 종료"
else
  assert_fail "TC-05" "uninstall: 이미 제거된 상태" "exit code=$EXIT_CODE"
fi

# ══════════════════════════════════════════════════
# TC-06: update — 파일 변경됨
# ══════════════════════════════════════════════════
# install 먼저
bash "$SCRIPT_DIR/install.sh" > /dev/null 2>&1
# 타겟을 다른 내용으로 변경
echo "# old version" > "$TARGET"
bash "$SCRIPT_DIR/update.sh" > /dev/null 2>&1
if diff -q "$SCRIPT_DIR/statusline.sh" "$TARGET" > /dev/null 2>&1; then
  assert_pass "TC-06" "update: 변경된 파일 덮어씀"
else
  assert_fail "TC-06" "update: 변경된 파일 덮어씀" "파일 내용 불일치"
fi

# ══════════════════════════════════════════════════
# TC-07: update — 이미 최신
# ══════════════════════════════════════════════════
OUTPUT=$(bash "$SCRIPT_DIR/update.sh" 2>&1)
if echo "$OUTPUT" | grep -q "Already up to date"; then
  assert_pass "TC-07" "update: 이미 최신"
else
  assert_fail "TC-07" "update: 이미 최신" "expected 'Already up to date' in output"
fi

# ══════════════════════════════════════════════════
# TC-08: update — 미설치 상태 → exit 1
# ══════════════════════════════════════════════════
rm -f "$TARGET"
bash "$SCRIPT_DIR/update.sh" > /dev/null 2>&1
EXIT_CODE=$?
if [ "$EXIT_CODE" -eq 1 ]; then
  assert_pass "TC-08" "update: 미설치 → exit 1"
else
  assert_fail "TC-08" "update: 미설치 → exit 1" "exit code=$EXIT_CODE"
fi

# ══════════════════════════════════════════════════
# TC-09: statusline.sh — JSON 파싱
# ══════════════════════════════════════════════════
# install 해서 TARGET에 최신 복사
bash "$SCRIPT_DIR/install.sh" > /dev/null 2>&1

TEST_JSON='{
  "model": {"display_name": "TestModel"},
  "workspace": {"current_dir": "/tmp/test-project"},
  "cost": {"total_cost_usd": 1.234, "total_duration_ms": 3600000},
  "context_window": {"remaining_percentage": 75},
  "version": "9.9.9"
}'

OUTPUT=$(echo "$TEST_JSON" | bash "$TARGET" 2>/dev/null)
LINE1=$(echo "$OUTPUT" | head -1)
LINE2=$(echo "$OUTPUT" | tail -1)

OK=true
echo "$LINE1" | grep -q "test-project" || OK=false
echo "$LINE1" | grep -q "TestModel" || OK=false
# version is not displayed in statusline output
echo "$LINE2" | grep -q "25%" || OK=false
echo "$LINE2" | grep -q '\$1.23' || OK=false

if [ "$OK" = true ]; then
  assert_pass "TC-09" "statusline.sh: JSON 파싱 정확"
else
  assert_fail "TC-09" "statusline.sh: JSON 파싱" "output: $OUTPUT"
fi

# ══════════════════════════════════════════════════
# TC-10: 컨텍스트 경고 — <70% → 🧊
# ══════════════════════════════════════════════════
TEST_JSON_NORMAL='{
  "model": {"display_name": "TestModel"},
  "workspace": {"current_dir": "/tmp/test-project"},
  "cost": {"total_cost_usd": 0, "total_duration_ms": 0},
  "context_window": {"remaining_percentage": 50},
  "version": "1.0.0"
}'
OUTPUT=$(echo "$TEST_JSON_NORMAL" | bash "$TARGET" 2>/dev/null)
LINE2=$(echo "$OUTPUT" | tail -1)
if echo "$LINE2" | grep -q "🧊"; then
  assert_pass "TC-10" "컨텍스트 <70% → 🧊"
else
  assert_fail "TC-10" "컨텍스트 <70% → 🧊" "output: $LINE2"
fi

# ══════════════════════════════════════════════════
# TC-11: 컨텍스트 경고 — 70~79% → ⚠️
# ══════════════════════════════════════════════════
TEST_JSON_WARN='{
  "model": {"display_name": "TestModel"},
  "workspace": {"current_dir": "/tmp/test-project"},
  "cost": {"total_cost_usd": 0, "total_duration_ms": 0},
  "context_window": {"remaining_percentage": 25},
  "version": "1.0.0"
}'
OUTPUT=$(echo "$TEST_JSON_WARN" | bash "$TARGET" 2>/dev/null)
LINE2=$(echo "$OUTPUT" | tail -1)
if echo "$LINE2" | grep -q "⚠"; then
  assert_pass "TC-11" "컨텍스트 70~79% → ⚠️"
else
  assert_fail "TC-11" "컨텍스트 70~79% → ⚠️" "output: $LINE2"
fi

# ══════════════════════════════════════════════════
# TC-12: 컨텍스트 경고 — >=80% → ❗
# ══════════════════════════════════════════════════
TEST_JSON_CRIT='{
  "model": {"display_name": "TestModel"},
  "workspace": {"current_dir": "/tmp/test-project"},
  "cost": {"total_cost_usd": 0, "total_duration_ms": 0},
  "context_window": {"remaining_percentage": 15},
  "version": "1.0.0"
}'
OUTPUT=$(echo "$TEST_JSON_CRIT" | bash "$TARGET" 2>/dev/null)
LINE2=$(echo "$OUTPUT" | tail -1)
if echo "$LINE2" | grep -q "❗"; then
  assert_pass "TC-12" "컨텍스트 >=80% → ❗"
else
  assert_fail "TC-12" "컨텍스트 >=80% → ❗" "output: $LINE2"
fi

# ── 최종 정리 (restore는 trap이 처리) ──────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  PASS: $PASS / $((PASS + FAIL))"
if [ "$FAIL" -gt 0 ]; then
  echo "  FAIL: $FAIL"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
else
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
fi
