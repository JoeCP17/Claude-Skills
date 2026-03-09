# Claude Plugins 설정

## 설치된 플러그인

| 플러그인 | 버전 | 설치일 | 용도 |
|----------|------|--------|------|
| `superpowers@claude-plugins-official` | 4.3.1 | 2026-02-24 | 개발 워크플로우 스킬 모음 |

## 복원 방법

```bash
# Claude Code 플러그인 설치
claude plugins install superpowers
```

## superpowers 플러그인 포함 스킬

superpowers 플러그인은 아래 스킬을 자동으로 제공합니다 (별도 설치 불필요):

| 스킬명 | 트리거 시점 |
|--------|------------|
| `using-superpowers` | 모든 대화 시작 시 |
| `brainstorming` | 기능 구현/컴포넌트 생성 전 |
| `writing-plans` | 멀티스텝 태스크 계획 시 |
| `executing-plans` | 작성된 계획 실행 시 |
| `test-driven-development` | 기능/버그픽스 구현 전 |
| `systematic-debugging` | 버그/테스트 실패 발생 시 |
| `requesting-code-review` | 주요 기능 완성 후 |
| `receiving-code-review` | 코드 리뷰 피드백 수신 시 |
| `verification-before-completion` | 완료 선언/커밋/PR 전 |
| `subagent-driven-development` | 독립 태스크 병렬 실행 시 |
| `dispatching-parallel-agents` | 2개 이상 독립 태스크 처리 시 |
| `using-git-worktrees` | 격리된 기능 개발 시작 시 |
| `finishing-a-development-branch` | 개발 브랜치 완료 시 |
| `writing-skills` | 새 스킬 작성/수정 시 |
