#!/usr/bin/env bash
# Claude Code MCP 서버를 claude/mcp/mcp.json 으로부터 일괄 등록 — 신규 PC 셋업 보조

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="${BASE_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
MCP_JSON="$BASE_DIR/claude/mcp/mcp.json"

if [[ -t 1 ]]; then
  RED='\033[0;31m'; GRN='\033[0;32m'; YEL='\033[1;33m'; CYN='\033[0;36m'; NC='\033[0m'
else
  RED=''; GRN=''; YEL=''; CYN=''; NC=''
fi
ok()   { echo -e "${GRN}✓${NC} $*"; }
warn() { echo -e "${YEL}⚠${NC} $*"; }
err()  { echo -e "${RED}✗${NC} $*" >&2; }
log()  { echo -e "${CYN}→${NC} $*"; }

command -v jq >/dev/null     || { err "jq 미설치 — brew install jq"; exit 1; }
command -v claude >/dev/null || { err "claude CLI 미설치"; exit 1; }
[[ -f "$MCP_JSON" ]]         || { err "$MCP_JSON 없음"; exit 1; }

# 누락된 env 변수 체크 (사용자에게 알리되 등록은 계속)
check_env_vars() {
  local server="$1" body="$2"
  local missing=()
  while IFS= read -r var; do
    [[ -z "$var" ]] && continue
    if [[ -z "${!var:-}" ]]; then
      missing+=("$var")
    fi
  done < <(echo "$body" | grep -oE '\$\{[A-Z_][A-Z0-9_]*\}' | sed 's/[${}]//g' | sort -u)
  if (( ${#missing[@]} > 0 )); then
    warn "$server: 누락 env — ${missing[*]} (등록은 진행하나 실제 호출 시 실패함)"
  fi
}

log "MCP 등록 시작 — 소스: $MCP_JSON"

count_ok=0; count_skip=0; count_fail=0

while IFS= read -r row; do
  decoded=$(echo "$row" | base64 --decode)
  name=$(echo "$decoded" | jq -r '.key')
  body=$(echo "$decoded" | jq -c '.value')

  if claude mcp get "$name" >/dev/null 2>&1; then
    ok "$name 이미 등록됨 — skip"
    count_skip=$((count_skip + 1))
    continue
  fi

  check_env_vars "$name" "$body"
  log "$name 등록 시도"
  if claude mcp add-json "$name" "$body" >/dev/null 2>&1; then
    ok "$name 등록 완료"
    count_ok=$((count_ok + 1))
  else
    err "$name 등록 실패 — 수동 점검 필요"
    count_fail=$((count_fail + 1))
  fi
done < <(jq -r '.mcpServers | to_entries[] | @base64' "$MCP_JSON")

echo
log "결과: 신규 $count_ok · skip $count_skip · 실패 $count_fail"
log "현황 확인: claude mcp list"
[[ $count_fail -eq 0 ]] || exit 1
