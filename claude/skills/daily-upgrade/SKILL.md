---
name: daily-upgrade
description: Use when user requests daily upgrade, brew update, package upgrade, claude-code update, 데일리 업그레이드, 브루 업데이트, 패키지 업데이트, 일일 업그레이드
---

# Daily Upgrade

## Overview

Homebrew 패키지 및 Claude Code를 포함한 전체 개발 환경을 최신 상태로 업그레이드한다. Brewfile 기반으로 누락 패키지도 함께 설치한다.

## When to Use

- 사용자가 "daily-upgrade", "브루 업데이트", "패키지 업그레이드" 등을 요청할 때
- 개발 환경을 최신 상태로 유지하고 싶을 때
- Claude Code 업데이트가 필요할 때

## Execution Steps

### Step 1: Homebrew 자체 업데이트

```bash
brew update
```

### Step 2: Brewfile 기반 누락 패키지 설치

```bash
brew bundle install --file=~/Desktop/Claude-Skills/homebrew/Brewfile
```

### Step 3: 설치된 전체 패키지 업그레이드

Formula와 Cask(Claude Code 포함)를 모두 업그레이드한다.

```bash
brew upgrade
```

### Step 4: 정리

오래된 버전 캐시를 제거하여 디스크 공간을 확보한다.

```bash
brew cleanup
```

### Step 5: 결과 리포트

아래 형식으로 결과를 출력한다:

```markdown
## Daily Upgrade 완료

| 항목 | 결과 |
|------|------|
| brew update | OK / 실패 사유 |
| Brewfile 동기화 | N개 패키지 설치됨 / 이미 최신 |
| brew upgrade | N개 업그레이드 / 이미 최신 |
| brew cleanup | N개 정리됨 / 정리 불필요 |
| Claude Code 버전 | vX.X.X |
```

## Common Mistakes

- `brew update`를 빠뜨리면 최신 패키지 정보 없이 upgrade가 실행되어 업데이트를 놓칠 수 있다
- Brewfile 경로가 `~/Desktop/Claude-Skills/homebrew/Brewfile`인지 확인. 경로가 다르면 bundle install이 실패한다
- `brew cleanup`을 빠뜨리면 오래된 버전이 계속 쌓여 디스크를 차지한다
