# Claude-Skills

Claude Code를 효과적으로 사용하기 위한 개인 설정, 스킬, 환경 구성을 관리하는 dotfiles 레포지토리입니다.

## 구조

```
Claude-Skills/
├── homebrew/
│   └── Brewfile                      # brew 설치 패키지 목록
├── shell/
│   └── .zshrc                        # zsh 설정 (NVM, claude-squad 등)
├── claude/
│   ├── CLAUDE.md                     # 글로벌 Claude 지시사항
│   ├── RTK.md                        # RTK 메타 커맨드 레퍼런스
│   ├── agents/                       # 커스텀 서브 에이전트 정의
│   │   ├── planner.md               # 설계/계획 수립
│   │   ├── coder.md                 # 구현/리팩토링
│   │   ├── debugger.md              # 버그 분석/수정
│   │   ├── researcher.md            # 조사/분석/문서화
│   │   └── reviewer.md              # 코드 리뷰/품질 검증
│   ├── rules/                        # 글로벌 규칙 (CLAUDE.md에서 @import)
│   │   ├── agents.md                # 에이전트 자동 위임 결정 트리
│   │   ├── session-memory-search.md # 세션/메모리 검색 시 agf 강제 사용
│   │   ├── java-lsp-exploration.md  # Java 탐색 시 jdtls LSP 강제 사용
│   │   ├── hedwig-cg.md             # 로컬 코드 그래프 + 5-signal 하이브리드 검색
│   │   ├── token-optimization.md    # 출력 분리/결정론적 위임/U-curve 등 토큰 절약
│   │   ├── development-workflow.md  # 기능 개발 파이프라인
│   │   ├── git-workflow.md          # 커밋/PR 워크플로우
│   │   ├── performance.md           # 모델 선택/컨텍스트 전략
│   │   ├── coding-style.md          # 코딩 스타일 가이드
│   │   ├── patterns.md              # 공통 패턴
│   │   ├── security.md              # 보안 가이드
│   │   ├── testing.md               # 테스트 가이드
│   │   └── hooks.md                 # 훅 사용 가이드
│   ├── bin/
│   │   └── hedwig-cg-auto           # 중앙 DB 라우팅 래퍼 (per-repo 흔적 없음)
│   ├── hooks/
│   │   └── rtk-rewrite.sh           # RTK 자동 재작성 훅
│   ├── settings/
│   │   ├── settings.json            # 플러그인, 훅 설정
│   │   └── settings.local.json      # 권한 화이트리스트
│   ├── mcp/                          # MCP 서버 설정 (secrets 제외)
│   ├── plugins/                      # 설치된 플러그인 목록
│   └── skills/
│       ├── superpowers/              # superpowers 플러그인 스킬 백업
│       ├── datadog-error-report/     # Datadog 에러 리포트 스킬
│       ├── daily-upgrade/            # brew/rtk 일일 업그레이드 스킬
│       ├── wrap/                     # 세션 작업 내용 메모리 저장 스킬
│       ├── commit/                   # Conventional Commits 자동 생성
│       ├── commit-push/              # 커밋 + 푸시 원스텝
│       ├── pr/                       # rebase + PR 생성
│       ├── obsidian-vault/           # Obsidian/마크다운 작업, markdown-oxide LSP 가이드
│       └── code-search-efficient/    # ast-grep/fd/rg/LSP 도구 선택 결정 트리
└── docs/
    └── GUIDELINE.md                  # 항목 추가 가이드라인
```

## RTK (Rust Token Killer)

LLM 토큰 소비를 **60-90% 절감**하는 CLI 프록시. PreToolUse 훅으로 Claude Code의 모든 Bash 커맨드를 자동 재작성합니다.

| 작업 | 절감률 |
|------|--------|
| git status/log/diff | -75~80% |
| cat/read 파일 | -70% |
| grep/rg 검색 | -80% |
| test/build | -80~90% |
| git add/commit/push | -92% |

```bash
rtk gain          # 토큰 절약 통계
rtk discover      # 놓친 절약 기회 분석
```

## agf (AI Agent Session Finder)

`agf`는 Claude Code / Codex / Gemini 등 로컬에 있는 **모든 에이전트 세션을 fuzzy 검색·재개**하는 CLI입니다. `claude/rules/session-memory-search.md`에 등록되어 있어, **"세션 찾아줘", "메모리 검색", "지난 대화 찾아줘"** 같은 요청이 들어오면 Claude가 자동으로 `agf`를 호출합니다.

```bash
agf <keyword>                      # fuzzy TUI 검색
agf resume <keyword>               # 최고 매치 세션 바로 재개
agf list --agent claude --limit 20 # 스크립트용 plain text 목록
agf list --format json             # JSON 파싱용
agf stats                          # 에이전트·프로젝트별 통계
agf watch                          # 실시간 세션 대시보드
```

설치: `brew install agf` (Brewfile에 포함). 자세한 트리거/안티패턴은 [session-memory-search.md](claude/rules/session-memory-search.md) 참고.

## Java LSP 기반 코드 탐색 (jdtls)

Claude Code 2.0.74+ 의 LSP 지원을 활용해 **Java 코드 탐색 시 `grep`/`find` 대신 Eclipse JDT Language Server**를 직접 호출합니다. `claude/rules/java-lsp-exploration.md` 규칙으로 강제되며, 정의/참조/호출 계층/심볼 검색이 IDE 수준 정확도로 수행됩니다.

### 제공 기능

| LSP 함수 | 용도 |
|----------|------|
| `workspaceSymbol` | 워크스페이스 전체에서 클래스/메서드 검색 |
| `documentSymbol` | 파일 내 심볼 트리 (Read 대체) |
| `goToDefinition` | 심볼 정의 위치 점프 |
| `goToImplementation` | 인터페이스/추상 메서드 → 구현체 |
| `findReferences` | 심볼의 모든 참조 찾기 |
| `incomingCalls` / `outgoingCalls` | 메서드 호출 계층 추적 |
| `hover` | 타입·시그니처·Javadoc 조회 |

### 설치

```bash
# 1. jdtls 바이너리 (Brewfile에 포함됨)
brew install jdtls

# 2. claude-code-lsps 마켓플레이스 등록
claude plugin marketplace add Piebald-AI/claude-code-lsps

# 3. jdtls 플러그인 설치 (반드시 claude-code-lsps 마켓플레이스 선택)
claude plugin install jdtls@claude-code-lsps

# 4. Claude Code 재시작 후 검증
claude plugin list | grep jdtls            # enabled 확인
```

> ⚠️ `jdtls-lsp@claude-plugins-official` 은 README만 있고 LSP 설정이 없으므로 **설치 금지**. 반드시 `@claude-code-lsps` 마켓플레이스 버전을 사용하세요.

### 다른 언어 LSP 추가

`claude-code-lsps` 마켓플레이스는 TypeScript(`vtsls`), Rust(`rust-analyzer`), Go(`gopls`), Python(`basedpyright`), Kotlin(`kotlin-lsp`) 등 다수 LSP를 제공합니다. 필요 시 `claude plugin install <name>@claude-code-lsps` 로 추가.

## hedwig-cg (로컬 코드 그래프 검색)

[`hedwig-cg`](https://github.com/hedwig-ai/hedwig-code-graph) 는 레포지토리에서 **5-signal 하이브리드 검색**(code vector + text vector + graph expansion + FTS5 keyword + community → RRF fusion → Cross-Encoder rerank)을 **100% 로컬**로 제공합니다. 수천 파일 규모 레포에서 Claude가 grep 루프 대신 먼저 "어느 파일부터 읽어야 하는지" 지도를 얻어 **토큰·시간을 절감**합니다.

### 중앙 DB 아키텍처 (per-repo `.hedwig-cg/` 없음)

`claude/bin/hedwig-cg-auto` 래퍼가 모든 호출을 **중앙 경로** (`$HEDWIG_CG_DB_ROOT`, 기본 `~/.hedwig-cg/dbs/<repo>/`) 로 라우팅합니다. 레포 작업 디렉토리는 그대로 깨끗하게 유지되고, 새 레포는 첫 검색 시 자동 빌드됩니다.

```bash
hedwig-cg-auto search "payment event consumer"   # 필요 시 자동 빌드 후 검색
hedwig-cg-auto where                             # 현재 레포 DB 경로/상태
hedwig-cg-auto list                              # 인덱싱된 모든 레포 목록
hedwig-cg-auto update                            # 증분 재빌드
hedwig-cg-auto rebuild                           # 풀 재빌드
hedwig-cg-auto clean                             # 이 레포 DB 삭제
```

환경변수:
- `HEDWIG_CG_DB_ROOT` — DB 저장 루트 (기본 `~/.hedwig-cg/dbs`)
- `HEDWIG_CG_AUTO_BUILD=0` — 자동 빌드 비활성
- `HEDWIG_CG_BUILD_ARGS` — 빌드 추가 인자 (e.g. `--max-file-size 200000`)

### 역할 분담

| 상황 | 1순위 |
|------|-------|
| Java 심볼 정확 탐색 (정의/참조/호출) | **LSP (jdtls)** |
| 아키텍처·도메인 탐색 (의미 기반) | **hedwig-cg-auto search** |
| 다중 모듈 기능 매핑 | **hedwig-cg-auto search** |
| 문자열·로그 | **rg** |
| 비-Java 레포 탐색 | **hedwig-cg-auto** + LSP |

상세: [claude/rules/hedwig-cg.md](claude/rules/hedwig-cg.md)

### 자동 최신화

`pull`/`checkout`/`rebase` 시 DB를 알아서 증분 갱신합니다 (기존 DB 있는 레포 한정, 백그라운드 ~4초).

- **전역 git 훅**: `claude/git-hooks/` (`post-merge`/`post-checkout`/`post-rewrite`) + `git config --global core.hooksPath`
- **Claude Code SessionStart 훅**: 세션 시작 시 동일 업데이트

임시 비활성화: `HEDWIG_CG_DISABLE_HOOK=1 git pull ...`

### 설치

```bash
brew install pipx                                          # 파이썬 격리 설치 도구
pipx install hedwig-cg                                      # 본체
pipx inject hedwig-cg mcp                                   # MCP 서버 옵셔널 의존성
ln -sf ~/Claude-Skills/claude/bin/hedwig-cg-auto ~/.local/bin/hedwig-cg-auto

# 자동 최신화 훅 활성화
git config --global core.hooksPath ~/Claude-Skills/claude/git-hooks

# 공식 Claude 통합 (Skill + 훅) — 전역
hedwig-cg claude install --scope user
```

## 토큰 최적화 (msbaek/dotfiles 패턴 차용)

[msbaek/dotfiles](https://github.com/msbaek/dotfiles) 의 `.claude/CLAUDE.md` 에서 검증된 토큰·컨텍스트 절약 패턴을 `claude/rules/token-optimization.md` 와 `claude/skills/code-search-efficient/`, `claude/skills/obsidian-vault/` 로 분리해 적용했습니다. RTK 훅이 **명령어 출력 단계**에서 토큰을 깎는 반면, 이 규칙/스킬은 **Claude의 행동·도구 선택 단계**에서 토큰을 깎습니다.

### 핵심 원칙 (rules/token-optimization.md)

| 원칙 | 효과 |
|------|------|
| **Output Offloading** | 2KB 이상 결과는 `/tmp/` 파일로 빼고 컨텍스트엔 경로+요약만 |
| **Deterministic Offload** | 카운트/파싱/반복 작업은 AI 대신 셸 스크립트로 |
| **U-shaped attention** | 중요 정보는 응답 시작/끝 (가운데 묻지 말 것) |
| **File Reading Safety** | 1000줄 이상 파일은 `offset/limit` 강제 |
| **Subagent Multiplier** | 멀티에이전트 ≈ 15× 토큰. 단일 에이전트+도구(~4×) 우선 |
| **Telephone-game 방지** | 서브에이전트 결과 재요약 금지 (50% 정보 손실) |
| **Anchored Compaction** | 80% 컨텍스트 도달 시 5섹션 증분 요약 (전체 재요약 금지) |

### 도구 우선순위 (skills/code-search-efficient)

```
Java 심볼     → jdtls LSP        (rules/java-lsp-exploration.md)
구조 패턴     → sg (ast-grep)   ← AST 매칭, 정규식보다 정확
텍스트 검색   → rg (Grep tool)
파일명        → fd / Glob
큰 파일 구조  → LSP documentSymbol → Read offset/limit fallback
백링크/마크다운 → markdown-oxide LSP / obsidian-vault skill
```

### 새로 설치된 CLI

| 도구 | 용도 |
|------|------|
| `fd` | `find` 대체. 빠르고 `.gitignore` 자동 존중 |
| `ast-grep` (`sg`) | AST 패턴 매칭. `sg --lang java -p '$x.foo($$$)'` 같은 구문 인식 검색·일괄 변환 |

Brewfile에 포함되어 새 PC에서 자동 설치됩니다.

### Obsidian/마크다운 (skills/obsidian-vault)

`markdown-oxide` LSP 우선, 미설치 시 `rg` fallback. Zettelkasten 폴더 구조(000-SLIPBOX/001-INBOX/...), Hierarchical tags, 토큰 절약 작업 패턴을 명문화했습니다. 실제 vault가 있을 때 자동으로 적용됩니다.

## 설치된 MCP 서버

| 서버 | 용도 |
|------|------|
| jetbrains | JetBrains IDE 연동 |
| github | GitHub 이슈/PR 조회 |
| atlassian | Jira, Confluence 연동 |
| mysql-mcp-server | AWS RDS MySQL 읽기 전용 |
| taskmaster-ai | AI 태스크 관리 |
| mcp-installer | MCP 설치 도우미 |
| sequential-thinking | 단계적 사고 지원 |
| browsermcp | 브라우저 자동화 |
| playwright | Playwright 브라우저 테스트 |
| context7 | 라이브러리 최신 문서 조회 |
| notion | Notion 연동 |
| datadog-mcp | Datadog 모니터링 조회 |

## 설치된 플러그인

| 플러그인 | 설명 |
|----------|------|
| superpowers | TDD, 디버깅, 코드리뷰 등 개발 워크플로우 스킬 |
| msbaek-tdd | TDD Red/Green/Blue 사이클 관리 |

## 커스텀 스킬

| 스킬 | 설명 |
|------|------|
| datadog-error-report | Datadog 에러 현황 종합 리포트 생성 |
| daily-upgrade | brew 패키지 및 Claude Code 일일 업그레이드 |
| wrap | 세션 작업 내용을 메모리에 저장하여 다음 세션에서 컨텍스트 복원 |
| commit | Conventional Commits 형식의 커밋 메시지 자동 생성 |
| commit-push | 커밋 + 원격 푸시를 원스텝으로 처리 |
| pr | 현재 브랜치를 base에 rebase 후 GitHub PR 생성 |
| obsidian-vault | Obsidian/마크다운 작업, markdown-oxide LSP 우선, 토큰 절약 패턴 |
| code-search-efficient | 코드 탐색 시 ast-grep/fd/rg/LSP 도구 선택 결정 트리 |

## 커스텀 서브 에이전트

`claude/agents/`에 정의된 5개 에이전트는 `claude/rules/agents.md`의 결정 트리를 통해 **자동 위임**됩니다.

| 에이전트 | 역할 | 트리거 |
|----------|------|--------|
| **planner** | 설계/계획 수립 | 설계, 계획, PRD, ADR, 아키텍처, 이관 전략 |
| **coder** | 구현/리팩토링 | 구현, 추가, 만들어, 리팩토링, implement, refactor |
| **debugger** | 버그 분석/수정 | 왜 안 돼, 에러, CS, 장애, 배송ID 기반 조사 |
| **researcher** | 조사/분석/문서화 | 조사, 분석, 비교, 리포트, Datadog 트래픽 분석 |
| **reviewer** | 코드 리뷰/품질 검증 | 리뷰, PR 리뷰, 품질 검증, 보안 검토 (코드 변경 직후 자동) |

## 빠른 시작 (새 PC 세팅)

```bash
# 1. 레포 클론
git clone git@github.com:JoeCP17/Claude-Skills.git ~/Claude-Skills

# 2. brew 패키지 일괄 설치 (rtk 포함)
brew bundle install --file=~/Claude-Skills/homebrew/Brewfile

# 3. Claude Code 네이티브 설치 (Homebrew가 아닌 공식 설치 방식)
curl -fsSL https://claude.ai/install.sh | sh

# 4. zshrc 적용
cat ~/Claude-Skills/shell/.zshrc >> ~/.zshrc && source ~/.zshrc

# 5. Claude 설정 복원
cp ~/Claude-Skills/claude/settings/settings.json ~/.claude/settings.json
cp ~/Claude-Skills/claude/settings/settings.local.json ~/.claude/settings.local.json

# 6. RTK 훅 설치 (토큰 절약 자동화)
rtk init --global --auto-patch

# 7. 커스텀 스킬 복원
mkdir -p ~/.claude/skills
cp -r ~/Claude-Skills/claude/skills/datadog-error-report ~/.claude/skills/
cp -r ~/Claude-Skills/claude/skills/daily-upgrade ~/.claude/skills/
cp -r ~/Claude-Skills/claude/skills/wrap ~/.claude/skills/
cp -r ~/Claude-Skills/claude/skills/commit ~/.claude/skills/
cp -r ~/Claude-Skills/claude/skills/commit-push ~/.claude/skills/
cp -r ~/Claude-Skills/claude/skills/pr ~/.claude/skills/

# 8. 커스텀 에이전트 + 규칙 복원
mkdir -p ~/.claude/agents ~/.claude/rules
cp -r ~/Claude-Skills/claude/agents/* ~/.claude/agents/
cp -r ~/Claude-Skills/claude/rules/* ~/.claude/rules/

# 9. 플러그인 설치
claude plugins install superpowers

# 10. MCP 서버 등록 → claude/mcp/README.md 참고

# 11. hedwig-cg 설치 + 래퍼 심볼릭 링크
pipx install hedwig-cg && pipx inject hedwig-cg mcp
mkdir -p ~/.local/bin
ln -sf ~/Claude-Skills/claude/bin/hedwig-cg-auto ~/.local/bin/hedwig-cg-auto
hedwig-cg claude install --scope user

# 12. git 전역 훅 (pull/checkout 시 자동 인덱스 갱신)
git config --global core.hooksPath ~/Claude-Skills/claude/git-hooks
```

## 가이드라인

항목별 추가 방법 → [docs/GUIDELINE.md](docs/GUIDELINE.md)
