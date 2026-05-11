#!/usr/bin/env python3
# check-md-rule.sh의 한국어 콜론 종결 탐지 헬퍼

# Usage: _check-korean-colon.py <file.md>
# Output: stdout으로 'LINENO: line' 형식 출력 (위반 없으면 빈 출력)
# Note: 코드블록(``` 으로 둘러싼) 안은 제외.

import re
import sys

if len(sys.argv) < 2:
    sys.exit(0)

path = sys.argv[1]
CODE_FENCE = chr(0x60) * 3  # 백틱 3개 — bash heredoc 우회용

in_code = False
results = []
with open(path, encoding="utf-8", errors="replace") as f:
    for idx, raw in enumerate(f, start=1):
        line = raw.rstrip("\n")
        if line.lstrip().startswith(CODE_FENCE):
            in_code = not in_code
            continue
        if in_code:
            continue
        stripped = line.rstrip()
        if not stripped.endswith(":"):
            continue
        if not re.search(r"[가-힣]", stripped):
            continue
        before = stripped[:-1].rstrip()
        if not before:
            continue
        last = before[-1]
        if "가" <= last <= "힣":
            results.append(f"{idx}: {line}")

if results:
    print("\n".join(results))
