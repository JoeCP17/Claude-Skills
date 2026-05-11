# Development Workflow

> 기능 구현 파이프라인 — research → plan → TDD → review → commit. 행동 원칙은 [`behavioral-principles.md`](./behavioral-principles.md), 산출물은 [`artifact-discipline.md`](./artifact-discipline.md), commit 규율은 [`git-workflow.md`](./git-workflow.md) 참고.

## Tradeoff

이 파이프라인은 **2개 이상 파일·30분 이상 작업**에 적용. 단순 typo·1줄 fix는 0번(Research) + 5번(Commit) 만으로 충분.

## Feature Implementation Workflow

0. **Research & Reuse** _(mandatory before any new implementation)_
   - **GitHub code search first.** Run `gh search repos` and `gh search code` to find existing implementations, templates, and patterns before writing anything new.
   - **Library docs second.** Use Context7 or primary vendor docs to confirm API behavior, package usage, and version-specific details before implementing.
   - **Exa only when the first two are insufficient.** Use Exa for broader web research or discovery after GitHub search and primary docs.
   - **Check package registries.** Search npm, PyPI, crates.io, and other registries before writing utility code. Prefer battle-tested libraries over hand-rolled solutions.
   - **Search for adaptable implementations.** Look for open-source projects that solve 80%+ of the problem and can be forked, ported, or wrapped.
   - Prefer adopting or porting a proven approach over writing net-new code when it meets the requirement.

1. **Plan First**
   - Use **planner** agent to create implementation plan
   - Generate three artifacts per `artifact-discipline.md` — Plan / Checklist / Context Notes
   - Identify dependencies and risks
   - Break down into phases with verifiable success criteria (per `behavioral-principles.md` 원칙 4)

2. **TDD Approach**
   - Implement via **coder** agent (the `tdd-guide` agent referenced in older versions of this doc does not exist in `~/.claude/agents/` — use `coder` with TDD instruction in the brief)
   - Write tests first (RED)
   - Implement to pass tests (GREEN)
   - Refactor (IMPROVE)
   - Verify 80%+ coverage

3. **Code Review**
   - Use **reviewer** agent immediately after writing code (auto-invoked per `agents.md` 즉시 위임 규칙 #4)
   - Address CRITICAL and HIGH issues
   - Fix MEDIUM issues when possible

4. **Run Tests Before Marking Complete** _([Karpathy 원칙 8](https://github.com/datajuny/andrej-karpathy-skills/blob/main/CLAUDE.md))_
   - 코드를 만졌으면 — "끝났어"라고 말하기 전에 **테스트를 실행**합니다.
   - `npm test`, `pytest`, `cargo test`, `./gradlew test` — 프로젝트가 쓰는 명령어로.
   - 통과하면 결과 보고. 실패하면 fix하고 재실행.
   - 테스트가 없는 프로젝트면 — 최소 빌드/컴파일 통과 확인.
   - LLM이 가장 자주 건너뛰는 단계. **non-negotiable**.

5. **Commit & Push**
   - Detailed commit messages
   - Follow conventional commits format
   - Apply Semantic Commits — 1 logical change per commit (per `git-workflow.md`)
   - See [git-workflow.md](./git-workflow.md) for commit message format and PR process

## 안티패턴

- ❌ 0번 (Research) 건너뛰고 바로 구현 — 라이브러리에 이미 있는 걸 재발명
- ❌ Plan 없이 코딩 시작 — 절반 와서 "근데 X는 어떻게?" 발견하고 되돌리기
- ❌ 4번 (Run Tests) 건너뛰고 "끝났어요" 보고 — 가장 자주 일어나는 LLM 실수
- ❌ 5단계를 다 한 PR에 묶기 — Semantic Commits 위반, rollback 능력 상실
- ❌ `tdd-guide`·`code-reviewer` 같은 존재하지 않는 agent 이름 호출 — `agents.md` 표에 있는 5개만 사용
