# Session & Memory Search (agf)

## Purpose

**`agf` (AI Agent Session Finder)** 는 Claude Code / Codex / Gemini 등 모든 에이전트 세션 이력을 fuzzy 검색/재개할 수 있는 로컬 CLI입니다. 과거 세션·메모리·대화 이력을 찾아달라는 요청이 들어오면 **반드시 `agf`를 우선 사용**합니다.

## Trigger

다음 요청이 들어오면 즉시 `agf`로 검색하세요:

| 한국어 | 영어 |
|--------|------|
| 이전 세션 찾아줘 | find previous session |
| 지난 대화 검색 | search past conversation |
| 어제/저번주 뭐 했었지 | what did I do yesterday |
| PayPal 조사 세션 어디 갔지 | where is the PayPal session |
| 토스 웹훅 이관 세션 resume | resume the toss webhook session |
| 메모리 찾아줘 | find memory |
| 세션 목록 보여줘 | show sessions |
| agf로 찾아줘 | search with agf |

## Commands Cheatsheet

```bash
# 1. Fuzzy 검색 (TUI) — 키워드를 넣어 후보 목록 띄우기
agf <keyword>

# 2. 스크립트용 plain text 리스트 (테이블/JSON/CSV)
agf list --agent claude --limit 20                  # 최근 20개
agf list --agent claude --format json --limit 50    # JSON으로 파싱용

# 3. 직접 resume (최고 매치 세션을 바로 재개)
agf resume <keyword>
agf resume paypal --list 5                          # 상위 5개 중 선택
agf resume toss --mode acceptEdits                  # 권한 모드 지정

# 4. 통계 / 라이브 대시보드
agf stats                                           # 에이전트별/프로젝트별/기간별 통계
agf watch                                           # 실시간 세션 모니터링
```

## Usage Rules

1. **메모리/세션 검색 요청 → 바로 `agf list` 또는 `agf resume`** — 수동으로 `~/.claude/projects/...` 를 `find`/`ls` 하지 않습니다.
2. **키워드 구성**: 사용자가 언급한 프로젝트명/PR번호/PG사명/배송ID 등을 그대로 쿼리에 전달합니다. (예: `agf resume paypal vbank`)
3. **요약만 필요하면 `agf list --format json`** 으로 받아서 파싱 → 토큰 효율적.
4. **세션 재개가 목적이면 `agf resume`** — TUI 진입 없이 바로 해당 세션으로 점프합니다.
5. **메모리 인덱스(MEMORY.md) 와 병행**: `agf`는 세션 로그 검색용, 메모리는 영구 저장용. 두 경로를 모두 확인한 뒤 사용자에게 결과를 종합해 보고합니다.
6. **추측 금지**: "아마 그 세션은 X월 Y일쯤..." 같은 추정 대신, `agf`로 실제 데이터를 조회하세요.

## Anti-patterns

- ❌ `find ~/.claude/projects -name "*.jsonl" | head` 로 수동 탐색
- ❌ `ls ~/.claude/projects/*/memory/` 로 디렉토리 뒤지기
- ❌ `agf` 설치 여부 재확인 없이 "세션 찾을 수 없음" 보고
- ❌ fuzzy 쿼리 없이 `agf list` 만 호출해 20개 중 눈대중으로 고르기 (키워드 쿼리를 먼저)

## Installation Verification

```bash
which agf             # /opt/homebrew/bin/agf 이어야 함
agf --version         # agf X.Y.Z
agf stats             # 세션이 인덱싱됐는지 확인
```

설치돼 있지 않으면: `brew install agf` 로 설치합니다.
