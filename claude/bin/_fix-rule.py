#!/usr/bin/env python3
# 룰 md의 mechanical 결함을 자동 수정하는 헬퍼

# Usage: _fix-rule.py <file.md>
# Behavior: in-place 수정 + <file>.bak 백업 생성 (변경 없으면 백업 삭제)
# Fixes:
#   1. 한국어 콜론 종결 → 마침표 (코드블록 제외)
#   2. > Purpose 누락 → H1 직후 빈 인용구 삽입
#   3. ## Tradeoff 누락 → Purpose 직후 스텁 삽입
#   4. ❌ 안티패턴 마커 누락 → 파일 끝에 스텁 섹션 삽입
# Exit: 항상 0 (변경 요약 stdout 출력)

import re
import shutil
import sys
from pathlib import Path

CODE_FENCE = chr(0x60) * 3

PURPOSE_STUB = "> TODO: 이 룰의 목적을 한 문장으로 작성하세요."
TRADEOFF_STUB = """## Tradeoff

TODO: 이 룰을 따르는 비용과 효익, 언제 생략 가능한지 명시하세요.
"""
ANTIPATTERNS_STUB = """
## 안티패턴

- ❌ TODO: 이 룰을 어겼을 때 발생하는 구체적 실패 사례
- ❌ TODO: 추가 사례
"""


def load(path):
    return Path(path).read_text(encoding="utf-8", errors="replace").splitlines(keepends=True)


def save(path, lines):
    Path(path).write_text("".join(lines), encoding="utf-8")


def fix_korean_colons(lines):
    in_code = False
    fixed = 0
    out = []
    for raw in lines:
        line = raw.rstrip("\n")
        nl = "\n" if raw.endswith("\n") else ""
        if line.lstrip().startswith(CODE_FENCE):
            in_code = not in_code
            out.append(raw)
            continue
        if in_code:
            out.append(raw)
            continue
        stripped = line.rstrip()
        if stripped.endswith(":") and re.search(r"[가-힣]", stripped):
            before = stripped[:-1].rstrip()
            if before and "가" <= before[-1] <= "힣":
                idx = line.rfind(":")
                new_line = line[:idx] + "." + line[idx + 1 :]
                out.append(new_line + nl)
                fixed += 1
                continue
        out.append(raw)
    return out, fixed


def find_h1_index(lines):
    in_code = False
    for idx, raw in enumerate(lines):
        line = raw.rstrip("\n")
        if line.lstrip().startswith(CODE_FENCE):
            in_code = not in_code
            continue
        if in_code:
            continue
        if re.match(r"^# [^#]", line):
            return idx
    return -1


def has_purpose(lines, h1_idx):
    if h1_idx < 0:
        return False
    for raw in lines[h1_idx + 1 : h1_idx + 6]:
        if raw.lstrip().startswith("> "):
            return True
    return False


def has_tradeoff(lines):
    in_code = False
    for raw in lines:
        line = raw.rstrip("\n")
        if line.lstrip().startswith(CODE_FENCE):
            in_code = not in_code
            continue
        if in_code:
            continue
        if re.match(r"^## Tradeoff", line):
            return True
    return False


def has_antipattern_marker(lines):
    in_code = False
    for raw in lines:
        line = raw.rstrip("\n")
        if line.lstrip().startswith(CODE_FENCE):
            in_code = not in_code
            continue
        if in_code:
            continue
        if "❌" in line:
            return True
    return False


def insert_purpose(lines, h1_idx):
    insert_at = h1_idx + 1
    if insert_at < len(lines) and lines[insert_at].strip() == "":
        insert_at += 1
    lines.insert(insert_at, PURPOSE_STUB + "\n\n")
    return lines


def insert_tradeoff(lines, h1_idx):
    insert_at = h1_idx + 1
    while insert_at < len(lines) and lines[insert_at].lstrip().startswith(">"):
        insert_at += 1
    while insert_at < len(lines) and lines[insert_at].strip() == "":
        insert_at += 1
    lines.insert(insert_at, TRADEOFF_STUB + "\n")
    return lines


def append_antipatterns(lines):
    if lines and not lines[-1].endswith("\n"):
        lines[-1] += "\n"
    lines.append(ANTIPATTERNS_STUB)
    return lines


def main():
    if len(sys.argv) < 2:
        print("Usage: _fix-rule.py <file.md>", file=sys.stderr)
        sys.exit(2)
    path = sys.argv[1]
    if not Path(path).is_file():
        print(f"FATAL: 파일 없음: {path}", file=sys.stderr)
        sys.exit(2)

    shutil.copy2(path, path + ".bak")
    lines = load(path)
    changes = []

    lines, n = fix_korean_colons(lines)
    if n > 0:
        changes.append(f"korean-colon: {n}건 마침표로 교체")

    h1_idx = find_h1_index(lines)

    if h1_idx >= 0 and not has_purpose(lines, h1_idx):
        lines = insert_purpose(lines, h1_idx)
        changes.append("purpose: H1 직후 빈 Purpose 스텁 삽입")

    h1_idx = find_h1_index(lines)
    if not has_tradeoff(lines):
        lines = insert_tradeoff(lines, h1_idx)
        changes.append("tradeoff: ## Tradeoff 스텁 삽입")

    if not has_antipattern_marker(lines):
        lines = append_antipatterns(lines)
        changes.append("antipatterns: ## 안티패턴 스텁 추가")

    if changes:
        save(path, lines)
        print(f"fixed: {path}")
        for c in changes:
            print(f"  - {c}")
    else:
        Path(path + ".bak").unlink()
        print("no-op")


if __name__ == "__main__":
    main()
