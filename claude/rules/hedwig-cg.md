# hedwig-cg — Local Code Graph & Hybrid Search

## Purpose

`hedwig-cg` 는 레포지토리에서 **코드 그래프 + 5-signal 하이브리드 검색**을 로컬로 제공합니다. 코딩 에이전트가 "다음에 무엇을 읽어야 할지(what to read next)" 를 결정하는 지도 역할입니다. 수천 파일 규모 레포에서 grep 루프를 줄여 토큰과 시간을 절약합니다.

이 룰은 wrapper `hedwig-cg-auto` 를 전제로 합니다. wrapper는 **per-repo `.hedwig-cg/` 를 만들지 않고** 중앙 경로(`$HEDWIG_CG_DB_ROOT`, 기본 `~/.hedwig-cg/dbs/<repo>/`)에 DB를 보관합니다. 즉 어떤 레포에서 쓰든 레포에는 흔적이 남지 않습니다.

## Installation Verification

```bash
which hedwig-cg          # pipx 로 설치된 원본 바이너리
which hedwig-cg-auto     # wrapper (LLM-Dot-files 에서 symlink)
hedwig-cg --version      # >= 0.13.1
hedwig-cg-auto where     # 현재 레포의 DB 위치 + 상태
hedwig-cg-auto list      # 인덱싱된 레포 전체
```

설치 안 돼 있으면:
```bash
brew install pipx && pipx install hedwig-cg && pipx inject hedwig-cg mcp
# wrapper는 LLM-Dot-files/claude/bin/hedwig-cg-auto 를 $PATH 에 심볼릭 링크
```

## When to Use (탐색 의사결정 트리)

```
Java 심볼(클래스/메서드) 정의/참조/호출 → LSP(jdtls) 우선
   │
   ├─ LSP로는 의미 기반 매칭이 안 될 때 (광의 질의, 도메인 탐색)
   │    → hedwig-cg-auto search (map builder 역할)
   │
문자열 리터럴/정규식/파일명 글롭 → rg (Grep) 직접
   │
다중 모듈·서비스에 걸친 기능 지도 → hedwig-cg-auto search 우선 → 상위 N개를 Read로 deep-dive
   │
일회성 파일 Read 전 "어디부터 봐야 하나?" → hedwig-cg-auto search
```

## 역할 분담 (다른 룰과의 관계)

이 룰은 `java-lsp-exploration.md`, `token-optimization.md` 와 **보완** 관계입니다:

| 상황 | 1순위 | 2순위 | 3순위 |
|------|-------|-------|-------|
| Java 심볼 정확 탐색 (정의/참조/호출) | **LSP (jdtls)** | hedwig-cg-auto | rg |
| 대형 레포 **아키텍처·도메인 탐색** (의미 기반) | **hedwig-cg-auto search** | Read | LSP |
| 여러 서비스 걸친 기능 매핑 | **hedwig-cg-auto search** | LSP | rg |
| 문자열·로그·에러메시지 | **rg** | hedwig-cg-auto search-keyword | — |
| DI / annotation 기반 의존성 | **LSP** | rg | hedwig-cg-auto |
| 비 Java (Python/Go/TS/Kotlin 등) | **hedwig-cg-auto** + LSP | rg | — |

## Usage Rules

### 1. 검색은 **영어**로

`intfloat/multilingual-e5-small` 이 다국어 지원이긴 하나, 공식 README 는 영어 쿼리가 precision 이 훨씬 높다고 명시. 한국어 등으로 들어온 요청이라도 내부 쿼리는 영어로 번역.

```bash
# ❌ hedwig-cg-auto search "결제 가상계좌 처리"
# ✅ hedwig-cg-auto search "payment virtual account handler"
```

### 2. **Round 검색** — 한 번에 멈추지 말 것

1차 결과의 도메인 용어를 뽑아 재검색 → 범위를 좁혀가며 지도 완성.

```bash
Round 1: hedwig-cg-auto search "payment event consumer"   # 넓게
Round 2: hedwig-cg-auto search "<발견한 구체 클래스명>"    # 좁게
Round 3: Read <발견한 파일>                                # 실제 확인
```

### 3. **score 절대값 믿지 말 것**

`score`는 상대 랭킹. 0.05 여도 최상위면 충분히 관련성 있음. **상위 N개 전부 검토**. 순위가 근거.

### 4. 모드 활용

```bash
hedwig-cg-auto search "auth middleware" --fast      # text vector only (~0.2s)
hedwig-cg-auto search "auth middleware" --top-k 10  # 정밀 랭킹
hedwig-cg-auto search "auth middleware" --expand    # 쿼리 확장 (recall↑)
```

### 5. 그래프가 없으면 wrapper가 자동 빌드

wrapper는 DB 부재 시 자동 `build` 실행. 첫 검색은 수분 걸릴 수 있으니 사전 빌드 원하면:

```bash
hedwig-cg-auto build             # 현재 레포
hedwig-cg-auto update            # 증분 (커밋 후 최신화)
hedwig-cg-auto rebuild           # 풀 재빌드
```

자동 빌드 끄고 싶으면: `HEDWIG_CG_AUTO_BUILD=0`.

### 5-1. 자동 최신화 (pull/checkout/rebase 시)

**git 전역 훅** (`core.hooksPath` → `LLM-Dot-files/claude/git-hooks`) 이 설치되어 있어 `git pull`, `git checkout <branch>`, `git rebase` 시 **기존 DB가 있는 레포에 한해** 백그라운드로 `hedwig-cg-auto update` 실행됩니다 (~4초, git 커맨드 지연 없음).

**Claude Code SessionStart 훅** 도 등록되어 세션 시작 시 동일 업데이트 시도합니다.

- 임시 비활성: `HEDWIG_CG_DISABLE_HOOK=1 git pull ...`
- 전역 비활성: `git config --global --unset core.hooksPath`
- 업데이트 로그: `~/.hedwig-cg/logs/<repo>.log`

### 6. Ignore 관리

- 전역: `~/.config/git/ignore` 에 `.hedwig-cg/` 등록 권장 (혹시 레거시 경로 사용 시)
- 레포 노이즈 제외: 레포 루트 `.hedwig-cg-ignore` (gitignore 문법). 없어도 기본적으로 `.git`, `node_modules`, `build`, `dist`, `__pycache__` 등 제외.

### 7. 결과 Offloading

`--top-k 50` 같은 큰 결과는 컨텍스트 대신 파일로 (token-optimization.md 원칙):

```bash
hedwig-cg-auto search "payment" --top-k 50 > /tmp/hg-payment.json
# 요약: "50개 파일 후보, /tmp/hg-payment.json 참조"
```

## Wrapper 운영 커맨드

```bash
hedwig-cg-auto where    # 이 레포 DB 경로 / 상태 / 크기
hedwig-cg-auto list     # 인덱싱된 모든 레포
hedwig-cg-auto clean    # 이 레포 DB 삭제
hedwig-cg-auto update   # 증분 빌드
```

환경변수:
- `HEDWIG_CG_DB_ROOT` : DB 저장 루트 (기본 `~/.hedwig-cg/dbs`)
- `HEDWIG_CG_AUTO_BUILD` : `0` 이면 자동 빌드 비활성
- `HEDWIG_CG_BUILD_ARGS` : 빌드에 추가 인자 전달

## Anti-patterns

- ❌ Java 심볼 정의를 hedwig-cg 로 찾기 (→ LSP `goToDefinition` 이 정확)
- ❌ 한국어 쿼리로 검색
- ❌ 1차 결과만 보고 결론
- ❌ score 0.08 이라서 "관련성 없음" 판단
- ❌ 레포에 `.hedwig-cg/` 생성 (wrapper는 중앙 경로 사용 → per-repo 흔적 남기지 않음)
- ❌ grep 5회 + Read 3회 루프 돌고도 hedwig-cg-auto 시도 안 함

## 참고

- 공식 스킬: `~/.claude/skills/hedwig-cg/SKILL.md` (상세 사용법)
- 공식 레포: https://github.com/hedwig-ai/hedwig-code-graph
- Wrapper 소스: `LLM-Dot-files/claude/bin/hedwig-cg-auto`
- 관련 룰: `java-lsp-exploration.md`, `token-optimization.md`
