#!/usr/bin/env bash
# 룰 md 1개에 대해 test → fix → test 루프를 최대 3회 수행

# Usage: rule-loop.sh <path/to/rule.md>
# Behavior:
#   1) test-rule-harness.sh 실행
#   2) FAIL/WARN 있으면 fix-rule.sh 호출
#   3) 다시 1)로 (최대 3회)
#   4) 마지막 상태 보고
# Exit: 최종 PASS면 0, 마지막에도 FAIL이면 1.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <path/to/rule.md>" >&2
  exit 2
fi

TARGET="$1"

if [ -t 1 ]; then
  C_BLU=$'\033[34m'
  C_RST=$'\033[0m'
else
  C_BLU="" C_RST=""
fi

find_bin() {
  local name="$1"
  for c in \
    "$SCRIPT_DIR/$name" \
    "$HOME/.claude/bin/$name"
  do
    [ -x "$c" ] && { echo "$c"; return; }
  done
}

HARNESS=$(find_bin "test-rule-harness.sh")
FIXER=$(find_bin "fix-rule.sh")

if [ -z "$HARNESS" ] || [ -z "$FIXER" ]; then
  echo "FATAL: test-rule-harness.sh 또는 fix-rule.sh 미설치." >&2
  exit 2
fi

MAX_ITER=3
for i in $(seq 1 "$MAX_ITER"); do
  echo ""
  echo "${C_BLU}===== Iteration ${i}/${MAX_ITER} =====${C_RST}"
  if STRICT=1 "$HARNESS" "$TARGET"; then
    echo ""
    echo "${C_BLU}=== rule-loop: PASS (iter ${i}) ===${C_RST}"
    exit 0
  fi
  if [ "$i" -lt "$MAX_ITER" ]; then
    echo ""
    echo "${C_BLU}--- fix attempt ${i} ---${C_RST}"
    "$FIXER" "$TARGET" || true
  fi
done

echo ""
echo "${C_BLU}=== rule-loop: 3회 시도 후에도 FAIL — 수동 검토 필요 ===${C_RST}"
exit 1
