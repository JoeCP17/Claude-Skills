# Claude-Skills 관리 가이드라인

## 디렉토리 구조

```
Claude-Skills/
├── homebrew/
│   └── Brewfile              # brew 설치 패키지 목록
├── shell/
│   └── .zshrc                # zsh 설정 (alias, function, PATH, source 등)
├── claude/
│   ├── settings/
│   │   ├── settings.json      # Claude Code 전역 설정
│   │   └── settings.local.json # Claude Code 권한 설정
│   └── skills/
│       └── <skill-name>/      # 커스텀 Claude 스킬
│           └── SKILL.md
└── docs/
    └── GUIDELINE.md           # 이 파일
```

---

## 항목별 추가 방법

### 1. brew 패키지 추가 시

`homebrew/Brewfile`에 항목 추가 후 커밋:

```bash
# Brewfile에 추가 예시
brew "패키지명"      # CLI 도구
cask "앱이름"        # GUI 앱

# 전체 복원 방법 (새 PC 세팅 시)
brew bundle install --file=~/Claude-Skills/homebrew/Brewfile
```

**규칙:**
- 설치 후 Brewfile에 바로 반영
- 주석으로 용도 설명 추가 (한 줄)
- formula / cask 섹션 구분 유지

---

### 2. zsh 설정 추가 시 (alias, function, source, PATH)

`shell/.zshrc`에 추가 후 커밋:

```bash
# 예시: 새 alias 추가
alias ll='ls -la'

# 예시: 새 source 추가
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# 예시: 새 PATH 추가
export PATH="$PATH:/new/path"
```

**규칙:**
- 섹션 주석(`# ---------------------------------------------------------------------------`) 유지
- 업무 관련 환경변수(DB 주소, 비밀번호 등)는 절대 포함하지 않음
- 변경 후 `source ~/.zshrc` 로 테스트 먼저

---

### 3. Claude 스킬 추가 시

`claude/skills/<skill-name>/SKILL.md` 파일 추가 후 커밋:

```bash
# 실제 스킬 파일 위치: ~/.claude/skills/<skill-name>/SKILL.md
# Claude-Skills 레포에도 동일하게 복사

cp -r ~/.claude/skills/<new-skill> ~/Claude-Skills/claude/skills/
```

**규칙:**
- SKILL.md는 실제 `~/.claude/skills/` 와 동기화 유지
- 스킬 파일에 업무 기밀 정보 포함 금지

---

### 4. Claude 설정 변경 시

`claude/settings/settings.json` 또는 `settings.local.json` 수정 후 커밋:

```bash
# 실제 파일 위치
~/.claude/settings.json       → claude/settings/settings.json
~/.claude/settings.local.json → claude/settings/settings.local.json
```

---

## 커밋 컨벤션

```
<type>: <what changed>

type:
  brew     - Brewfile 변경
  shell    - .zshrc 변경
  skill    - Claude 스킬 추가/수정
  settings - Claude 설정 변경
  docs     - 문서 변경
```

**예시:**
```
brew: add gh (GitHub CLI)
shell: add cs function for claude-squad
skill: add datadog-error-report skill
settings: allow mcp__github__get_file_contents permission
```

---

## 새 PC 세팅 시 복원 순서

```bash
# 1. 레포 클론
git clone https://github.com/JoeCP17/Claude-Skills.git ~/Claude-Skills

# 2. brew 패키지 일괄 설치
brew bundle install --file=~/Claude-Skills/homebrew/Brewfile

# 3. zshrc 적용
cat ~/Claude-Skills/shell/.zshrc >> ~/.zshrc
source ~/.zshrc

# 4. Claude 설정 복원
cp ~/Claude-Skills/claude/settings/settings.json ~/.claude/settings.json
cp ~/Claude-Skills/claude/settings/settings.local.json ~/.claude/settings.local.json

# 5. Claude 스킬 복원
cp -r ~/Claude-Skills/claude/skills/* ~/.claude/skills/
```
