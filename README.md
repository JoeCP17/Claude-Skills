# Claude-Skills

Claude Code를 효과적으로 사용하기 위한 개인 설정, 스킬, 환경 구성을 관리하는 dotfiles 레포지토리입니다.

## 구조

```
Claude-Skills/
├── homebrew/
│   └── Brewfile                      # brew 설치 패키지 목록
├── shell/
│   └── .zshrc                        # zsh 설정
├── claude/
│   ├── settings/                     # Claude Code 설정 파일
│   ├── mcp/                          # MCP 서버 설정 (secrets 제외)
│   ├── plugins/                      # 설치된 플러그인 목록
│   └── skills/
│       ├── superpowers/              # superpowers 플러그인 스킬 백업
│       └── datadog-error-report/     # 커스텀 스킬
└── docs/
    └── GUIDELINE.md                  # 항목 추가 가이드라인
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
| context7 | 라이브러리 최신 문서 조회 |
| notion | Notion 연동 |
| datadog-mcp | Datadog 모니터링 조회 |

## 설치된 플러그인

| 플러그인 | 버전 |
|----------|------|
| superpowers | 4.3.1 |

## 빠른 시작 (새 PC 세팅)

```bash
# 1. 레포 클론
git clone https://github.com/JoeCP17/Claude-Skills.git ~/Claude-Skills

# 2. brew 패키지 일괄 설치
brew bundle install --file=~/Claude-Skills/homebrew/Brewfile

# 3. zshrc 적용
cat ~/Claude-Skills/shell/.zshrc >> ~/.zshrc && source ~/.zshrc

# 4. Claude 설정 복원
cp ~/Claude-Skills/claude/settings/settings.json ~/.claude/settings.json
cp ~/Claude-Skills/claude/settings/settings.local.json ~/.claude/settings.local.json

# 5. 커스텀 스킬 복원
cp -r ~/Claude-Skills/claude/skills/datadog-error-report ~/.claude/skills/

# 6. 플러그인 설치
claude plugins install superpowers

# 7. MCP 서버 등록 → claude/mcp/README.md 참고
```

## 가이드라인

항목별 추가 방법 → [docs/GUIDELINE.md](docs/GUIDELINE.md)
