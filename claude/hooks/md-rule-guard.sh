#!/usr/bin/env bash
# Claude Code PostToolUse 훅 — Write/Edit 대상이 rule/agent/skill md면 check-md-rule.sh 호출

# Input: stdin으로 Claude Code hook JSON (tool_input.file_path 추출)
# Exit: 0 (warning-only)
# Reference: claude/bin/check-md-rule.sh, claude/rules/_meta-rule-authoring.md

set -uo pipefail
HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_CLAUDE_DIR="$(cd "$HOOK_DIR/.." && pwd)"

# stdin JSON 읽기
payload=$(cat 2>/dev/null || echo "")

if [ -z "$payload" ]; then
  exit 0
fi

# tool_input.file_path 추출 (jq 우선, 없으면 grep fallback)
file_path=""
if command -v jq >/dev/null 2>&1; then
  file_path=$(echo "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
fi
if [ -z "$file_path" ]; then
  file_path=$(echo "$payload" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"file_path"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')
fi

if [ -z "$file_path" ]; then
  exit 0
fi

# md 파일만 검증
case "$file_path" in
  *.md|*.MD) ;;
  *) exit 0 ;;
esac

# rule/agent/skill 영역만 검증 (check-md-rule.sh 내부에서도 한번 더 필터)
case "$file_path" in
  *"/rules/"*|*"/agents/"*|*"/skills/"*) ;;
  *) exit 0 ;;
esac

# 검증 스크립트 위치 (현재 레포 우선, 글로벌 fallback)
CHECKER=""
for candidate in \
  "$REPO_CLAUDE_DIR/bin/check-md-rule.sh" \
  "$HOME/.claude/bin/check-md-rule.sh" \
  "$HOOK_DIR/../bin/check-md-rule.sh"
do
  if [ -x "$candidate" ]; then
    CHECKER="$candidate"
    break
  fi
done

if [ -z "$CHECKER" ]; then
  exit 0
fi

"$CHECKER" "$file_path"

exit 0
