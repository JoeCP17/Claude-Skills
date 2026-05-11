# Artifact Discipline

> 비-trivial 작업 시작 전 산출물 3종 — Plan + Checklist + Context Notes. [Karpathy 원칙](https://github.com/datajuny/andrej-karpathy-skills/blob/main/CLAUDE.md) 7번.

## Tradeoff

이 규율은 **다음 세션 (사용자 또는 다른 LLM 인스턴스) 의 onboarding 비용**을 0에 수렴시키는 게 목적.
일회성 한 줄 수정·명백한 버그 fix에는 불필요. **2개 이상 파일·30분 이상 작업·여러 결정점이 있는 작업**에 적용.

---

## 7. Plan + Checklist + Context Notes — 3종 산출물

비-trivial 작업을 시작하기 전 **세 가지 산출물**을 만들고, 코딩에 들어갑니다.

### 산출물 1. Plan — 무엇을 왜 만드는가

목표·범위·비범위 (out-of-scope) 를 한 문서에 명시.

```markdown
# Plan: <작업 제목>

## 목표
<한 줄 요약>

## 왜
<배경 — 무슨 문제 / 어떤 트레이드오프 / 어떤 제약>

## 범위
- [ ] X
- [ ] Y

## 비범위 (이번에는 안 함)
- Z (이유: 다음 PR에서)

## 성공 기준
<verify-loop 기준 — `behavioral-principles.md` 원칙 4>
```

### 산출물 2. Checklist — `checklist.md`

Plan을 **체크박스 단위**로 분해. 진행하면서 즉시 체크. 다음 세션이 "어디까지 됐지?"를 0초에 파악 가능.

```markdown
# Checklist: <작업 제목>

## Phase 1. 도메인 모델
- [x] User 엔티티 정의
- [x] Result<T> 래퍼 도입
- [ ] UserRepository 인터페이스 ← **여기서 멈춤**

## Phase 2. 인프라
- [ ] InMemoryUserRepository
- [ ] HttpUserRepository
```

**규칙**.
- 한 체크박스 = 한 작은 commit 단위 (Semantic Commits — `git-workflow.md` 와 호환).
- "Phase 2를 더 작은 체크박스로 쪼개고 싶다" — 즉시 쪼개세요. 큰 체크박스는 못 끝낸 표시일 뿐.
- 완료한 항목은 절대 지우지 마세요 — 히스토리가 곧 다음 세션의 context.

### 산출물 3. Context Notes — `context-notes.md`

**왜 그렇게 결정했는지** 만 남기는 누적 로그. ADR보다 가볍고, commit 메시지보다 친절.

```markdown
# Context Notes: <작업 제목>

## 2026-05-11 14:20
- `Result<T>` vs Kotlin `runCatching` 비교 → `Result<T>` 선택
  - 이유: 도메인 에러를 sealed class로 표현해야 호출자가 exhaustive when 가능
  - 참고: `rules/patterns.md` 53-65줄

## 2026-05-11 15:40
- UserRepository.findById 의 반환 타입을 `Result<User?>` 로 결정
  - 이유: not-found 가 에러가 아닌 정상 흐름. exception 던지는 건 control flow 남용.
  - 다음 세션 주의: PaymentRepository는 다른 정책 (not-found = 에러) — 일관성 강요 금지.
```

**규칙**.
- 시각 + 결정 + 이유. 결정만 적고 이유를 빼면 가치 절반.
- "왜 이렇게 안 했는지" (rejected alternatives) 도 짧게.
- 코드에는 안 남기는 게 좋은 메타정보 (조직 정치, 우선순위 트레이드오프, deadline 압박) 를 여기에.

---

## 언제 강제로 만들지 안 만들지

| 작업 성격 | Plan | Checklist | Context Notes |
|----------|------|-----------|---------------|
| 한 줄 typo fix | ❌ | ❌ | ❌ |
| 단일 파일 버그 fix | ❌ | ❌ | ❌ |
| 새 API 엔드포인트 1개 | ⚠️ optional | ❌ | ⚠️ optional |
| 새 기능 (2+ 파일) | ✅ | ✅ | ✅ |
| 마이그레이션·이관 | ✅ | ✅ | ✅ |
| 리팩터링 (3+ 파일) | ✅ | ✅ | ✅ |
| 외부 API 통합 | ✅ | ✅ | ✅ |

판단이 안 서면 — **만드세요**. 작성 비용 < 다음 세션 재발견 비용.

---

## 저장 위치 컨벤션

- 개인 작업 — `~/Documents/projects/<project>/plans/<YYYYMMDD>-<slug>.md`
- 회사 작업 — 회사 Notion / Confluence (claude-skills 외부)
- 프로젝트 내장 — `<repo>/.plans/<slug>/{plan,checklist,context-notes}.md` (`.gitignore` 추가 권장 — 개인 노트성이면)

---

## 사용자가 "그냥 코딩 시작해" 라고 하면

원칙 7에 따라 **멈추고 묻습니다**.

> "비-trivial 작업으로 보입니다. Plan/Checklist/Context Notes 먼저 만들까요? 아니면 trivial로 판단하시는 거면 그냥 진행하겠습니다."

사용자가 "그냥 진행해" 라고 답하면 — 진행. 사용자 명시 지시가 이 룰을 override.

---

## 다른 룰과의 관계

- `agents.md` — planner agent 는 본 룰의 자동화 (Plan 산출물을 대신 작성).
- `behavioral-principles.md` 4번 (Goal-Driven) — 본 룰의 "성공 기준" 항목과 호환.
- `git-workflow.md` (Semantic Commits) — 체크박스 1개 = 1 commit 이 자연스러움.

---

## 안티패턴

- ❌ Plan만 만들고 Checklist 생략 — "진행 상황 어디까지?" 답 못 함
- ❌ Checklist만 있고 Context Notes 없음 — "왜 X 대신 Y 선택?" 답 못 함
- ❌ Context Notes에 결과만 적고 이유 누락 — 다음 세션이 재토론
- ❌ 모든 작업에 3종 만들기 — 1줄 fix에 plan은 과잉
- ❌ Plan 작성을 LLM에게 시키면서 "알아서 해" — 사용자의 의도가 안 들어가면 빈 껍데기
