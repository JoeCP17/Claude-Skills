#!/usr/bin/env bash
# Claude rule 마크다운 파일의 골격·스타일을 검증해 경고만 출력하는 스크립트

# Usage: check-md-rule.sh <file.md> [<file.md> ...]
# Exit: 항상 0 (warning-only 모드). 향후 strict 모드 추가 가능.
# Reference: claude/rules/_meta-rule-authoring.md, claude/rules/korean-output-style.md

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 결과 카운트
warn_total=0
file_total=0

# 색상 (TTY일 때만)
if [ -t 2 ]; then
  C_YEL=$'\033[33m'
  C_BLU=$'\033[34m'
  C_RST=$'\033[0m'
else
  C_YEL=""
  C_BLU=""
  C_RST=""
fi

warn() {
  local file="$1" rule="$2" msg="$3"
  echo "${C_YEL}[WARN]${C_RST} ${C_BLU}${file}${C_RST} [${rule}] ${msg}" >&2
  warn_total=$((warn_total + 1))
}

# 파일이 rule/agent/skill 영역에 속하는지 판정
is_rule_file() {
  local file="$1"
  case "$file" in
    *"/rules/"*|*"/agents/"*|*"/skills/"*) return 0 ;;
    *) return 1 ;;
  esac
}

# 1. # Title 한 개 존재 (H1) — 코드블록 안의 # 는 무시
check_title() {
  local file="$1"
  local count
  count=$(awk '
    /^```/ { in_code = !in_code; next }
    !in_code && /^# [^#]/ { n++ }
    END { print n + 0 }
  ' "$file")
  if [ "$count" -eq 0 ]; then
    warn "$file" "title" "H1 제목 (# Title) 이 없습니다."
  elif [ "$count" -gt 1 ]; then
    warn "$file" "title" "H1 제목이 ${count}개. 한 개여야 합니다."
  fi
}

# 2. > Purpose 인용구 존재 (제목 다음 5줄 안)
check_purpose() {
  local file="$1"
  local h1_line
  h1_line=$(grep -nE '^# [^#]' "$file" | head -1 | cut -d: -f1)
  if [ -z "$h1_line" ]; then return; fi
  local has_quote
  has_quote=$(awk -v start="$h1_line" 'NR > start && NR <= start + 5 && /^> / { print; exit }' "$file")
  if [ -z "$has_quote" ]; then
    warn "$file" "purpose" "H1 다음 5줄 안에 '> Purpose ...' 인용구가 없습니다."
  fi
}

# 3. ## Tradeoff 섹션 존재
check_tradeoff() {
  local file="$1"
  if ! grep -qE '^## Tradeoff' "$file"; then
    warn "$file" "tradeoff" "'## Tradeoff' 섹션이 없습니다."
  fi
}

# 4. 안티패턴 섹션 (❌ 마커 ≥ 1개)
check_antipatterns() {
  local file="$1"
  local count
  count=$(grep -cF '❌' "$file" || true)
  if [ "$count" -eq 0 ]; then
    warn "$file" "antipatterns" "❌ 마커가 하나도 없습니다. 안티패턴 섹션 추가 권장."
  fi
}

# 5. 한국어 콜론 종결 탐지 (warning-only)
# BSD awk UTF-8 한계 회피용으로 외부 python3 헬퍼 호출. 코드블록 안은 헬퍼가 제외.
check_korean_colon() {
  local file="$1"
  local helper
  for candidate in \
    "$SCRIPT_DIR/_check-korean-colon.py" \
    "$HOME/.claude/bin/_check-korean-colon.py"
  do
    if [ -f "$candidate" ]; then
      helper="$candidate"
      break
    fi
  done
  if [ -z "${helper:-}" ]; then
    return
  fi
  local hits
  hits=$(python3 "$helper" "$file" 2>/dev/null || true)
  if [ -n "$hits" ]; then
    local n
    n=$(echo "$hits" | wc -l | tr -d ' ')
    warn "$file" "korean-colon" "한국어 문장이 ':' 로 종결된 라인 ${n}건 (warning-only)."
    if [ -n "${VERBOSE:-}" ]; then
      echo "$hits" | head -5 | sed 's/^/    /' >&2
    fi
  fi
}

# 메인 루프
for f in "$@"; do
  if [ ! -f "$f" ]; then
    continue
  fi
  case "$f" in
    *.md|*.MD) ;;
    *) continue ;;
  esac
  if ! is_rule_file "$f"; then
    continue
  fi
  file_total=$((file_total + 1))
  check_title "$f"
  check_purpose "$f"
  check_tradeoff "$f"
  check_antipatterns "$f"
  check_korean_colon "$f"
done

if [ "$file_total" -gt 0 ] && [ "$warn_total" -gt 0 ]; then
  echo "" >&2
  echo "${C_YEL}check-md-rule${C_RST}: ${file_total} file(s) scanned, ${warn_total} warning(s)." >&2
  echo "상세 라인 보기: VERBOSE=1 check-md-rule.sh <file>" >&2
fi

# warning-only 모드 — 항상 0 종료
exit 0
