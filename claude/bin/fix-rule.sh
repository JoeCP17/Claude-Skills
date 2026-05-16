#!/usr/bin/env bash
# _fix-rule.py 를 호출하는 shell wrapper

# Usage: fix-rule.sh <path/to/rule.md>

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <path/to/rule.md>" >&2
  exit 2
fi

HELPER=""
for c in \
  "$SCRIPT_DIR/_fix-rule.py" \
  "$HOME/.claude/bin/_fix-rule.py"
do
  [ -f "$c" ] && HELPER="$c" && break
done

if [ -z "$HELPER" ]; then
  echo "FATAL: _fix-rule.py 미설치." >&2
  exit 2
fi

python3 "$HELPER" "$1"
