# Token Optimization Principles

> 출처: [msbaek/dotfiles](https://github.com/msbaek/dotfiles) `.claude/CLAUDE.md` 의 컨텍스트/토큰 절약 패턴을 적용. RTK 훅은 명령어 출력 단계에서 토큰을 줄이고, 이 규칙은 **Claude의 행동·출력 단계**에서 토큰을 줄이는 것을 목표로 함.

## P0 — Always-on (모든 인터랙션 적용)

### 1. Output Offloading (출력 분리)

- **2KB(약 500토큰) 이상의 도구 출력은 Read/Bash 결과로 받지 말고 파일로 빼라.**
- 큰 결과는 `/tmp/` 또는 `~/.claude/scratch/` 에 저장 → 컨텍스트에는 **파일 경로 + 2~3줄 요약**만 남긴다.
- 세션 종료 시 scratch 파일 정리.

```bash
# ❌ BAD — 5MB 로그를 통째로 컨텍스트에 받음
Bash: cat huge.log

# ✅ GOOD — 결과를 파일로 빼고 요약만 컨텍스트로
Bash: tail -200 huge.log > /tmp/log-tail-$$.txt && wc -l /tmp/log-tail-$$.txt
→ 사용자에게 "200줄 요약: /tmp/log-tail-$$.txt" 보고 후, 필요한 부분만 Read offset/limit
```

### 2. Deterministic Offload (결정론적 작업 위임)

- **개수 세기, 정규식 매칭, 텍스트 변환, 반복 작업** → AI에게 시키지 말고 **셸/스크립트로 작성해서 실행**.
- "Use AI to explore. Use code to repeat."

```bash
# ❌ BAD — 200개 파일 라인 수를 AI가 보고 합산
# ✅ GOOD
fd -e java | xargs wc -l | tail -1
```

### 3. File Reading Safety

- **1000줄 이상 파일은 반드시 `offset`+`limit`** 옵션 사용. 절대 통째로 Read 금지.
- Java 등 LSP 사용 가능 언어는 `documentSymbol` 로 구조부터 보고 필요한 라인만 Read.
- Edit 직전: `old_string` 의 유일성을 다시 확인 (replace_all 의도가 아니라면).

### 4. Noise Cancellation (응답 압축)

- **U-shaped attention curve**: 중요한 정보는 응답의 **시작 또는 끝**에 배치, 가운데 묻지 마라.
- 사족·반복 설명·"좋은 질문입니다" 같은 preamble 금지.
- 사용자가 이미 본 diff/output을 다시 요약하지 않는다 (사용자가 읽을 수 있음).

## P1 — 컨텍스트 건강 관리

### 5. Context Health Signals

다음 신호가 보이면 즉시 대응:

| 증상 | 원인 | 대응 |
|------|------|------|
| 같은 실수 반복 | Poisoning | 컨텍스트 truncate or `/clear` |
| 답변 품질 저하 | Distraction (불필요 retrieved 컨텐츠) | 사전에 필터링 |
| 무관한 작업 섞임 | Confusion | 서브에이전트로 격리 |
| 80% 컨텍스트 도달 | Window pressure | Anchored summary 후 진행 |

### 6. Anchored Iterative Summarization

컨텍스트 80% 도달 시 — **전체 재요약 금지**, 다음 5섹션을 증분 업데이트:

```
## Session Intent
## Files Modified (with changes)
## Decisions Made
## Current State
## Next Steps
```

### 7. Subagent Token Multiplier 인지

- **멀티에이전트 ≈ 15× 토큰 곱셈**. 단일 에이전트 + 도구 호출(~4×)로 충분하면 단일 에이전트 사용.
- 서브에이전트 결과는 **중간 요약 없이 그대로 전달** (Telephone-game 방지: 재요약 시 정보 50% 손실).
- 위임이 필요한 경우만 위임: 독립적 분석, 컨텍스트 격리, 병렬 가능 작업.

## P2 — 도구 선택 우선순위

### 8. Tool Preferences

| 작업 | 1순위 | 2순위 | 3순위 |
|------|-------|-------|-------|
| Java 심볼 탐색 | LSP (jdtls) | — | grep (fallback) |
| 구문 인식 검색 (AST) | `sg --lang <lang> -p '<pattern>'` | rg | grep |
| 텍스트 검색 | `rg` (Grep tool) | — | — |
| 파일 찾기 | `fd` | Glob tool | find |
| 큰 파일 (>500줄) | LSP `documentSymbol` / Read offset | — | full Read |
| 웹 컨텐츠 (동적/auth) | Playwright MCP | WebFetch (정적만) | curl/wget 금지 |
| 세션/메모리 검색 | `agf` | — | manual find |
| Obsidian/마크다운 백링크 | markdown-oxide LSP | rg | — |

### 9. ast-grep (sg) 활용

`sg` 는 구문 트리 매칭이라 정규식보다 정확하면서 더 짧은 패턴으로 가능. Java/TS/Python 리팩토링·탐색에 특히 효과적.

```bash
# Java 메서드 시그니처 찾기 (오버로드 구분)
sg --lang java -p 'public $RET $METHOD($$$ARGS) { $$$ }'

# TypeScript 특정 props 사용처
sg --lang tsx -p '<$COMP $$$ onClick={$HANDLER} $$$ />'

# Python 데코레이터 사용처
sg --lang python -p '@$DEC\ndef $FN($$$): $$$'
```

## Anti-patterns

- ❌ 1만 줄 파일을 통째로 Read 후 "정리해줘"
- ❌ 100개 파일 grep 결과를 컨텍스트에 받고 AI가 헤아리기
- ❌ "여기까지 한 거 요약해드리면..." 으로 사용자가 본 diff 재서술
- ❌ 같은 질문 4번째 시도하면서 컨텍스트 오염 인지 못 함
- ❌ 단순 lookup 작업에 서브에이전트 dispatch (15× 토큰 낭비)
- ❌ 서브에이전트 결과를 메인이 다시 200토큰으로 압축해 사용자에게 전달
