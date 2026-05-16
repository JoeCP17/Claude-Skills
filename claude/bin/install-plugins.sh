#!/usr/bin/env bash
# Claude Code 플러그인을 lock 파일(installed.json + marketplaces.json) 로부터 일괄 설치

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="${BASE_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
PLUGINS_DIR="$BASE_DIR/claude/plugins"
INSTALLED="$PLUGINS_DIR/installed.json"
MARKETPLACES="$PLUGINS_DIR/marketplaces.json"

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
[[ -f "$INSTALLED" ]]    || { err "$INSTALLED 없음 — claude plugin list --json > $INSTALLED 로 백업 먼저"; exit 1; }
[[ -f "$MARKETPLACES" ]] || { err "$MARKETPLACES 없음 — claude plugin marketplace list --json > $MARKETPLACES 로 백업 먼저"; exit 1; }

# 1. 마켓플레이스 등록
log "marketplaces 등록 — 소스: $MARKETPLACES"
existing_mp=$(claude plugin marketplace list --json 2>/dev/null | jq -r '.[].name' 2>/dev/null || true)
mp_ok=0; mp_skip=0; mp_fail=0

while IFS=$'\t' read -r name repo; do
  if echo "$existing_mp" | grep -qx "$name"; then
    ok "marketplace $name 이미 등록됨"
    mp_skip=$((mp_skip + 1))
    continue
  fi
  log "marketplace add: $name ($repo)"
  if claude plugin marketplace add "$repo" >/dev/null 2>&1; then
    ok "$name 등록 완료"
    mp_ok=$((mp_ok + 1))
  else
    err "$name 등록 실패"
    mp_fail=$((mp_fail + 1))
  fi
done < <(jq -r '.[] | "\(.name)\t\(.repo)"' "$MARKETPLACES")

echo
# 2. 플러그인 설치
log "plugins 설치 — 소스: $INSTALLED"
existing_pl=$(claude plugin list --json 2>/dev/null | jq -r '.[].id' 2>/dev/null || true)
pl_ok=0; pl_skip=0; pl_fail=0

while IFS= read -r id; do
  if echo "$existing_pl" | grep -qx "$id"; then
    ok "plugin $id 이미 설치됨"
    pl_skip=$((pl_skip + 1))
    continue
  fi
  log "plugin install: $id"
  if claude plugin install "$id" >/dev/null 2>&1; then
    ok "$id 설치 완료"
    pl_ok=$((pl_ok + 1))
  else
    err "$id 설치 실패"
    pl_fail=$((pl_fail + 1))
  fi
done < <(jq -r '.[].id' "$INSTALLED")

echo
log "marketplaces: 신규 $mp_ok · skip $mp_skip · 실패 $mp_fail"
log "plugins     : 신규 $pl_ok · skip $pl_skip · 실패 $pl_fail"
log "현황 확인: claude plugin list"
[[ $((mp_fail + pl_fail)) -eq 0 ]] || exit 1
