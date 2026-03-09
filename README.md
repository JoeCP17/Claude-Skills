# Claude-Skills

Claude Code를 효과적으로 사용하기 위한 개인 설정, 스킬, 환경 구성을 관리하는 dotfiles 레포지토리입니다.

## 구조

```
Claude-Skills/
├── homebrew/
│   └── Brewfile              # brew 설치 패키지 목록
├── shell/
│   └── .zshrc                # zsh 설정
├── claude/
│   ├── settings/             # Claude Code 설정 파일
│   └── skills/               # 커스텀 Claude 스킬
└── docs/
    └── GUIDELINE.md          # 항목 추가 가이드라인
```

## 빠른 시작

### 새 PC 세팅 시

```bash
# 레포 클론
git clone https://github.com/JoeCP17/Claude-Skills.git ~/Claude-Skills

# brew 패키지 일괄 설치
brew bundle install --file=~/Claude-Skills/homebrew/Brewfile

# zshrc 적용
cat ~/Claude-Skills/shell/.zshrc >> ~/.zshrc && source ~/.zshrc

# Claude 설정 복원
cp ~/Claude-Skills/claude/settings/settings.json ~/.claude/settings.json
cp ~/Claude-Skills/claude/settings/settings.local.json ~/.claude/settings.local.json
cp -r ~/Claude-Skills/claude/skills/* ~/.claude/skills/
```

### claude-squad 실행

어느 디렉토리에서나 `cs` 입력 → `~/Claude-Skills`에서 자동 실행

## 가이드라인

항목 추가 방법 → [docs/GUIDELINE.md](docs/GUIDELINE.md)
