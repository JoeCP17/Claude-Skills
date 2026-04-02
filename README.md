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
│       └── wrap/                     # 세션 작업 내용 메모리 저장 스킬
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

# 8. 플러그인 설치
claude plugins install superpowers

# 9. MCP 서버 등록 → claude/mcp/README.md 참고
```

## 가이드라인

항목별 추가 방법 → [docs/GUIDELINE.md](docs/GUIDELINE.md)
