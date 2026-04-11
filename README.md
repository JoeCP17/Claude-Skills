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
│   │   ├── development-workflow.md  # 기능 개발 파이프라인
│   │   ├── git-workflow.md          # 커밋/PR 워크플로우
│   │   ├── performance.md           # 모델 선택/컨텍스트 전략
│   │   ├── coding-style.md          # 코딩 스타일 가이드
│   │   ├── patterns.md              # 공통 패턴
│   │   ├── security.md              # 보안 가이드
│   │   ├── testing.md               # 테스트 가이드
│   │   └── hooks.md                 # 훅 사용 가이드
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
│       └── pr/                       # rebase + PR 생성
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
```

## 가이드라인

항목별 추가 방법 → [docs/GUIDELINE.md](docs/GUIDELINE.md)
