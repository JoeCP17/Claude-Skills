#!/usr/bin/env bash
# _fix-rule.py 를 호출하는 shell wrapper

# Usage: fix-rule.sh <path/to/rule.md>

set -uo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <path/to/rule.md>" >&2
  exit 2
fi

HELPER=""
for c in \
  "$(dirname "$0")/_fix-rule.py" \
  "$HOME/Desktop/Claude-Skills/claude/bin/_fix-rule.py" \
  "$HOME/.claude/bin/_fix-rule.py"
do
  [ -f "$c" ] && HELPER="$c" && break
done

if [ -z "$HELPER" ]; then
  echo "FATAL: _fix-rule.py 미설치." >&2
  exit 2
fi

python3 "$HELPER" "$1"
