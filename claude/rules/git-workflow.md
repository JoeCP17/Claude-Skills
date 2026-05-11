# Git Workflow

> Commit·PR 표기 + Semantic Commits 원칙. 자세한 행동 원칙은 [`behavioral-principles.md`](./behavioral-principles.md), 산출물 규율은 [`artifact-discipline.md`](./artifact-discipline.md) 참고.

## Tradeoff

이 룰은 **rollback 단위를 작게 유지**하는 게 목적. 일회성 throwaway 스크립트나 prototype에는 느슨하게 적용 가능.

## Commit Message Format
```
<type>: <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci, rule

Note: Attribution disabled globally via ~/.claude/settings.json.

## Semantic Commits — 1 logical change per commit

[Karpathy 원칙 9](https://github.com/datajuny/andrej-karpathy-skills/blob/main/CLAUDE.md). 한 커밋 = 한 논리적 변경.

- **테스트**. "이 커밋을 한 문장으로 설명할 수 있는가." Yes면 commit, No면 변경이 섞인 것 — 분리.
- ✅ Good. `feat: auth 미들웨어 추가`
- ❌ Bad. `chore: auth 추가하고 UI도 고치고 버그도 수정` (3개로 분리)
- 20개 무관한 변경을 한 커밋에 누적하지 마세요 — 개별 rollback 능력 상실.
- 단, **prototype / 일회성 스크립트**는 ceremony 줄이고 묶어도 OK. 목적은 reversibility지 의식이 아님.

`artifact-discipline.md` 의 Checklist 한 체크박스 = 한 커밋 자연스럽게 매칭.

## Pull Request Workflow

When creating PRs:
1. Analyze full commit history (not just latest commit)
2. Use `git diff [base-branch]...HEAD` to see all changes
3. Draft comprehensive PR summary
4. Include test plan with TODOs
5. Push with `-u` flag if new branch

> For the full development process (planning, TDD, code review) before git operations,
> see [development-workflow.md](./development-workflow.md).
