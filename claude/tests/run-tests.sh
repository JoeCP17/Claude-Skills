#!/usr/bin/env bash
# check-md-rule.sh의 회귀 방지용 fixture 테스트 러너

# Usage: bash claude/tests/run-tests.sh
# Exit: PASS면 0, 하나라도 FAIL이면 1.
# Reference: claude/tests/fixtures/rules/, claude/bin/check-md-rule.sh

set -uo pipefail

TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
FX="$TESTS_DIR/fixtures/rules"
CHECKER=""
for c in \
  "$TESTS_DIR/../bin/check-md-rule.sh" \
  "$HOME/.claude/bin/check-md-rule.sh"
do
  if [ -x "$c" ]; then CHECKER="$c"; break; fi
done

if [ -z "$CHECKER" ]; then
  echo "FATAL: check-md-rule.sh 를 찾지 못함." >&2
  exit 2
fi

if [ -t 1 ]; then
  C_GRN=$'\033[32m'
  C_RED=$'\033[31m'
  C_YEL=$'\033[33m'
  C_RST=$'\033[0m'
else
  C_GRN="" C_RED="" C_YEL="" C_RST=""
fi

pass_total=0
fail_total=0

assert_warns() {
  local fixture="$1"
  local rule_key="$2"
  local expect_count="$3"   # "0" 이면 경고 없어야, "1+" 이면 1건 이상
  local stderr_capture
  stderr_capture=$("$CHECKER" "$fixture" 2>&1 >/dev/null || true)
  local actual
  if [ "$rule_key" = "any" ]; then
    actual=$(echo "$stderr_capture" | grep -cE '^\[WARN\]' || true)
  else
    actual=$(echo "$stderr_capture" | grep -cE "\[${rule_key}\]" || true)
  fi
  local ok=0
  case "$expect_count" in
    0)   [ "$actual" -eq 0 ] && ok=1 ;;
    1+)  [ "$actual" -ge 1 ] && ok=1 ;;
    *)   [ "$actual" -eq "$expect_count" ] && ok=1 ;;
  esac
  if [ "$ok" -eq 1 ]; then
    echo "${C_GRN}PASS${C_RST} $(basename "$fixture") expect ${rule_key}=${expect_count}, got ${actual}"
    pass_total=$((pass_total + 1))
  else
    echo "${C_RED}FAIL${C_RST} $(basename "$fixture") expect ${rule_key}=${expect_count}, got ${actual}"
    echo "${C_YEL}  ─── stderr ───${C_RST}"
    echo "$stderr_capture" | sed 's/^/  /'
    fail_total=$((fail_total + 1))
  fi
}

echo "=== check-md-rule.sh fixture tests ==="

# Fixture 1. good — 경고 0건
assert_warns "$FX/_fx_good.md" "any" "0"

# Fixture 2. missing purpose — purpose 경고 1건 이상
assert_warns "$FX/_fx_missing_purpose.md" "purpose" "1+"

# Fixture 3. missing tradeoff — tradeoff 경고 1건 이상
assert_warns "$FX/_fx_missing_tradeoff.md" "tradeoff" "1+"

# Fixture 4. missing antipatterns — antipatterns 경고 1건 이상
assert_warns "$FX/_fx_missing_antipatterns.md" "antipatterns" "1+"

# Fixture 5. korean colon — korean-colon 경고 1건 이상
assert_warns "$FX/_fx_colon_violation.md" "korean-colon" "1+"

# Fixture 6. multi H1 — title 경고 1건 이상
assert_warns "$FX/_fx_multi_h1.md" "title" "1+"

echo ""
echo "=== Summary ==="
echo "PASS: ${pass_total}, FAIL: ${fail_total}"

if [ "$fail_total" -gt 0 ]; then
  exit 1
fi
exit 0
