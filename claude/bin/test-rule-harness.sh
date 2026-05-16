#!/usr/bin/env bash
# 룰 md 1개에 대해 5단계 통합 검증을 수행하는 runner

# Usage: test-rule-harness.sh <path/to/rule.md>
# Exit: 모든 단계 PASS면 0, 하나라도 FAIL이면 1
# Stages:
#   1. 정적 검증 (check-md-rule.sh, 경고 0건 기대)
#   2. 글로벌 sync 상태 (LLM-Dot-files ↔ ~/.claude/)
#   3. CLAUDE.md @import 라인 존재
#   4. Hook end-to-end 시뮬레이션 (md-rule-guard.sh)
#   5. 종합 리포트
# Reference: claude/bin/check-md-rule.sh, claude/hooks/md-rule-guard.sh

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_CLAUDE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <path/to/rule.md>" >&2
  exit 2
fi

TARGET="$1"
if [ ! -f "$TARGET" ]; then
  echo "FATAL: 파일 없음: $TARGET" >&2
  exit 2
fi

# 색상
if [ -t 1 ]; then
  C_GRN=$'\033[32m'
  C_RED=$'\033[31m'
  C_YEL=$'\033[33m'
  C_BLU=$'\033[34m'
  C_RST=$'\033[0m'
else
  C_GRN="" C_RED="" C_YEL="" C_BLU="" C_RST=""
fi

# 경로 정규화
ABS_TARGET=$(cd "$(dirname "$TARGET")" && pwd)/$(basename "$TARGET")

# 도구 위치 탐색
find_bin() {
  local name="$1"
  for c in \
    "$SCRIPT_DIR/$name" \
    "$HOME/.claude/bin/$name"
  do
    [ -x "$c" ] && { echo "$c"; return; }
    [ -f "$c" ] && { echo "$c"; return; }
  done
}

find_hook() {
  local name="$1"
  for c in \
    "$REPO_CLAUDE_DIR/hooks/$name" \
    "$HOME/.claude/hooks/$name"
  do
    [ -x "$c" ] && { echo "$c"; return; }
  done
}

CHECKER=$(find_bin "check-md-rule.sh")
GUARD=$(find_hook "md-rule-guard.sh")

if [ -z "$CHECKER" ]; then
  echo "FATAL: check-md-rule.sh 미설치." >&2
  exit 2
fi

pass=0
fail=0
warns=0

report() {
  local result="$1" stage="$2" msg="$3"
  case "$result" in
    PASS) echo "${C_GRN}[PASS]${C_RST} ${stage} — ${msg}"; pass=$((pass+1)) ;;
    FAIL) echo "${C_RED}[FAIL]${C_RST} ${stage} — ${msg}"; fail=$((fail+1)) ;;
    WARN) echo "${C_YEL}[WARN]${C_RST} ${stage} — ${msg}"; warns=$((warns+1)) ;;
    INFO) echo "${C_BLU}[INFO]${C_RST} ${stage} — ${msg}" ;;
  esac
}

echo "${C_BLU}=== test-rule-harness ===${C_RST}"
echo "Target: ${ABS_TARGET}"
echo ""

# -----------------------------
# Stage 1. 정적 검증
# -----------------------------
echo "${C_BLU}--- Stage 1. 정적 검증 (check-md-rule.sh) ---${C_RST}"
stage1=$("$CHECKER" "$ABS_TARGET" 2>&1 >/dev/null || true)
stage1_warns=$(echo "$stage1" | grep -cE '^\[WARN\]' || true)
if [ "$stage1_warns" -eq 0 ]; then
  report PASS "stage1-static" "경고 0건"
else
  report WARN "stage1-static" "경고 ${stage1_warns}건 (warning-only)"
  echo "$stage1" | sed 's/^/    /'
fi
echo ""

# -----------------------------
# Stage 2. 글로벌 sync 상태
# -----------------------------
echo "${C_BLU}--- Stage 2. 글로벌 sync 상태 ---${C_RST}"
case "$ABS_TARGET" in
  "$REPO_CLAUDE_DIR"/*)
    rel="${ABS_TARGET#"$REPO_CLAUDE_DIR/"}"
    global_path="$HOME/.claude/$rel"
    ;;
  *"/.claude/"*)
    rel="${ABS_TARGET#*/.claude/}"
    global_path="$REPO_CLAUDE_DIR/$rel"
    ;;
  *)
    rel=""
    global_path=""
    ;;
esac

if [ -z "$global_path" ]; then
  report INFO "stage2-sync" "repo/~/.claude 영역 밖 — sync 점검 생략"
elif [ ! -f "$global_path" ]; then
  report FAIL "stage2-sync" "미러 파일 없음: $global_path (sync 누락)"
elif cmp -s "$ABS_TARGET" "$global_path"; then
  report PASS "stage2-sync" "로컬 ↔ 글로벌 내용 일치"
else
  report FAIL "stage2-sync" "로컬과 글로벌 내용 불일치: $global_path"
fi
echo ""

# -----------------------------
# Stage 3. CLAUDE.md @import 라인
# -----------------------------
echo "${C_BLU}--- Stage 3. CLAUDE.md @import ---${C_RST}"
case "$ABS_TARGET" in
  *"/rules/"*)
    rule_name=$(basename "$ABS_TARGET")
    if grep -qE "^@rules/${rule_name}$" "$HOME/.claude/CLAUDE.md" 2>/dev/null; then
      report PASS "stage3-import" "~/.claude/CLAUDE.md 에 @rules/${rule_name} 존재"
    else
      report WARN "stage3-import" "~/.claude/CLAUDE.md 에 @rules/${rule_name} 없음 (의도적이면 무시)"
    fi
    ;;
  *"/agents/"*|*"/skills/"*)
    report INFO "stage3-import" "agents/skills 는 CLAUDE.md @import 대상 아님 (생략)"
    ;;
  *)
    report INFO "stage3-import" "rule 영역 아님 (생략)"
    ;;
esac
echo ""

# -----------------------------
# Stage 4. Hook end-to-end 시뮬레이션
# -----------------------------
echo "${C_BLU}--- Stage 4. Hook end-to-end ---${C_RST}"
if [ -z "$GUARD" ]; then
  report WARN "stage4-hook" "md-rule-guard.sh 미설치 — 시뮬레이션 생략"
else
  payload="{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"${ABS_TARGET}\",\"content\":\"...\"}}"
  hook_stderr=$(echo "$payload" | bash "$GUARD" 2>&1 >/dev/null)
  hook_code=$?
  if [ "$hook_code" -eq 0 ]; then
    if [ -z "$hook_stderr" ]; then
      report PASS "stage4-hook" "hook 정상 종료, 경고 없음"
    else
      report PASS "stage4-hook" "hook 정상 종료, 경고 전달:"
      echo "$hook_stderr" | sed 's/^/    /'
    fi
  else
    report FAIL "stage4-hook" "hook 비정상 종료 (exit ${hook_code})"
    echo "$hook_stderr" | sed 's/^/    /'
  fi
fi
echo ""

# -----------------------------
# Stage 5. 종합
# -----------------------------
echo "${C_BLU}=== Summary ===${C_RST}"
echo "PASS: ${pass}, WARN: ${warns}, FAIL: ${fail}"

if [ "$fail" -gt 0 ]; then
  exit 1
fi
# STRICT=1 이면 WARN 도 실패로 취급 (rule-loop.sh 가 fix 시도를 위해 사용)
if [ -n "${STRICT:-}" ] && [ "$warns" -gt 0 ]; then
  exit 1
fi
exit 0
