# Agent Orchestration

## Installed Agents

실제 `~/.claude/agents/`에 설치된 에이전트는 다음 5개입니다.
**이 목록에 없는 이름(architect, tdd-guide, code-reviewer 등)은 존재하지 않으므로 호출하지 마세요.**

| Agent | 역할 | 트리거 키워드 |
|-------|------|--------------|
| **planner** | 설계·계획 수립 | 설계, 계획, PRD, ADR, 아키텍처, 이관 전략, 마이그레이션, "어떻게 구현" |
| **coder** | 구현·리팩토링 | 구현, 추가, 만들어, 리팩토링, 수정, implement, add, refactor |
| **debugger** | 버그 분석·수정 | 왜 안 돼, 에러, 조사, CS, 장애, 배송ID/주문ID 기반 원인 분석 |
| **researcher** | 조사·분석·문서화 | 조사, 분석, 비교, 찾아봐, 리포트, TPS/QPS/트래픽 분석 |
| **reviewer** | 코드 리뷰·품질 검증 | 리뷰, PR 리뷰, 품질 검증, 보안 검토 |

## 자동 위임 결정 트리

사용자 요청이 들어오면 **먼저** 아래 결정 트리를 적용해 적합한 에이전트가 있는지 확인합니다.

```
요청이 들어옴
  │
  ├─ 버그/에러/CS/장애 조사인가? ──── YES ──► debugger
  │
  ├─ 설계/계획/ADR/이관 전략인가? ─── YES ──► planner
  │   (구현 전 단계, 여러 파일/서비스에 걸친 작업)
  │
  ├─ 조사/비교/분석/리포트인가? ───── YES ──► researcher
  │   (Datadog 트래픽 분석, 라이브러리 비교, 기술 조사)
  │
  ├─ 코드 구현/추가/리팩토링인가? ─── YES ──► coder
  │
  └─ 코드 변경이 방금 끝났는가? ───── YES ──► reviewer
      (자동 — 사용자가 요청하지 않아도 호출)
```

## 즉시 위임 규칙 (사용자 명시 요청 불필요)

메인 세션은 다음 상황에서 **반드시** 해당 에이전트에게 위임합니다.

1. **복잡한 기능 요청** (2개 이상 파일, 설계 결정 포함) → **planner** 먼저, 그 다음 **coder**
2. **버그/CS 조사 요청** → **debugger** (추측 금지, MCP로 실제 데이터 확인)
3. **구현 작업** → **coder** (인라인으로 직접 구현 금지)
4. **코드 변경 완료 직후** → **reviewer** 자동 호출 (사용자 승인 대기 금지)
5. **Datadog/Jira/Notion 조사** → **researcher**
6. **production-bound 코드·multi-file 변경 직후** → 위 4번 reviewer **+** Codex CLI 교차 리뷰 (cross-agent). 자세한 트리거·호출 방법은 아래 "Cross-Agent Review" 섹션 참고.

## Cross-Agent Review — Claude 작성 → Codex 리뷰

**목적**. Claude(Opus) 한 모델로 작성·자가리뷰 하면 같은 편향·맹점에 갇힙니다. 독립 모델(Codex GPT-5.5) 을 두 번째 리뷰어로 붙여 **모델 다양성으로 false-PASS 위험**을 낮춥니다. `everything-claude-code` 플러그인의 `/santa-loop` 가 이 흐름을 자동화하지만, 본 룰은 슬래시 커맨드 없이도 Claude 가 **선제적으로** Codex 를 호출하도록 강제합니다.

### 언제 트리거

다음 중 하나라도 해당하면 reviewer 에이전트 호출 **직후** Codex 도 호출합니다.

- production 으로 나갈 가능성이 있는 코드 변경 (PR 직전, push 직전, deploy 직전)
- 보안·결제·인증·migration 관련 코드 (`auth`, `payment`, `migration`, `secret`, `token` 키워드 매치)
- 3개 이상 파일에 걸친 multi-file 변경
- 사용자가 명시적으로 "교차 리뷰", "double-check", "Codex 도 봐줘", "cross-review" 라고 요청

다음은 트리거하지 **않음**.

- 단일 typo·1줄 fix, 문서 전용 변경, 일회성 스크립트, prototype
- 빌드/포맷팅 정도 (이건 build-error-resolver / formatter 영역)

### 호출 방법 — 결정 트리

```
변경 scope?
  │
  ├─ uncommitted (working tree + staged) → codex review --uncommitted -c sandbox_mode="read-only"
  │
  ├─ 특정 commit  → codex review --commit <SHA> -c sandbox_mode="read-only"
  │
  ├─ 브랜치 전체 → codex review --base main -c sandbox_mode="read-only"
  │
  └─ free-form prompt 필요 (특정 파일·관심사 한정)
        → codex exec --sandbox read-only "<prompt>"
```

**원칙**.
- 반드시 `sandbox_mode="read-only"` (또는 `--sandbox read-only`) — Codex 가 우리 working tree 를 변경하지 않게.
- 한 호출당 한 가지 scope. `--commit`·`--base`·`--uncommitted` 와 free-form prompt 는 **상호 배타** (codex CLI 제약).
- 출력은 stdout 로 옴 — Claude 가 받아서 Findings 만 추출해 사용자에게 보여줍니다.

### 워크플로우 (Reviewer 에이전트 + Codex 교차)

```
1. coder 가 구현 완료
   │
2. reviewer 에이전트 호출 (Claude Opus) — CRITICAL/HIGH/MEDIUM/LOW 분류
   │
3. (위 "언제 트리거" 조건 매치 시) Codex 도 병렬 호출:
   │   codex review --uncommitted -c sandbox_mode="read-only"
   │
4. 두 리뷰 결과를 합쳐 사용자에게 보고:
   ┌────────────────────────┬──────────┬──────────┐
   │ 항목                   │ Claude   │ Codex    │
   ├────────────────────────┼──────────┼──────────┤
   │ CRITICAL/HIGH 개수     │ N        │ M        │
   │ 공통 지적              │ ...      │          │
   │ Claude only            │ ...      │          │
   │ Codex only             │ ...      │          │
   └────────────────────────┴──────────┴──────────┘
   │
5. 합의 (둘 다 통과) → 푸시/머지 진행 OK
   불일치 → 사용자 판단 받기 (자동 fix 금지)
```

### Codex 측 사전 조건

Codex 가 **자신의** Claude 룰·코딩 스타일 가이드를 알고 같은 기준으로 리뷰하도록 `~/.codex/AGENTS.md` 가 이미 다음을 import 합니다. 추가 설정 불필요.

- `claude/rules/coding-style.md`
- `claude/rules/git-workflow.md`
- `claude/rules/security.md`
- `claude/rules/java-lsp-exploration.md`
- `claude/rules/token-optimization.md`
- `claude/rules/korean-output-style.md`

### 실패 처리

| 상황 | 대응 |
|------|------|
| `codex` 명령 없음 | `brew install --cask codex` 안내. Claude 단독 리뷰로 fallback. |
| `codex login` 안 됨 | "터미널에서 `codex login` 후 재시도" 안내. Claude 단독 fallback. |
| Codex 호출 5분 초과 | Bash timeout 으로 종료. 부분 출력만 활용하거나 작은 scope 로 재시도. |
| 두 리뷰가 충돌 (Claude PASS · Codex FAIL 등) | **자동으로 한쪽 편들기 금지**. 사용자에게 양측 근거 그대로 표시 후 판단 받음. |

## 위임 시 전달 원칙

에이전트는 메인 세션의 대화 컨텍스트를 보지 못합니다. 반드시 자체 완결형 브리프를 전달하세요:
- **목표**: 무엇을 달성해야 하는가
- **컨텍스트**: 이미 알고 있는 사실, 배제한 가설
- **제약**: 건드리면 안 되는 파일/설정, 지켜야 할 패턴
- **완료 기준**: 어떤 결과물을 기대하는가

단순 명령어 스타일 ("X 해줘")는 피하고, 에이전트가 판단할 수 있도록 충분한 배경을 제공합니다.

## 병렬 실행

독립적인 작업은 **반드시 병렬**로 실행합니다. 단일 메시지에 여러 Agent 호출을 포함하세요.

```
GOOD: 한 메시지에서
  - researcher: 인증 모듈 보안 분석
  - researcher: 캐시 시스템 성능 분석
  - reviewer: 유틸리티 타입 체크

BAD: 순차 실행 (의존성 없는데도)
  먼저 하나, 끝나면 다음
```

## 안티패턴 (하지 말 것)

- ❌ 적합한 에이전트가 있는데 메인 세션이 직접 구현 ("간단하니까 내가 하자" 금지)
- ❌ 존재하지 않는 에이전트 이름 호출 (architect, tdd-guide, code-reviewer 등 — 이 파일의 표에 없으면 없는 것)
- ❌ 위임 후 메인 세션이 동일 작업을 중복 수행
- ❌ 코드 변경 후 reviewer 호출 생략
- ❌ 에이전트에 대화 히스토리 맥락 없이 한 줄 명령만 전달
- ❌ production-bound 변경에 Codex 교차 리뷰 생략 → Claude 단일 모델 편향에 그대로 빠짐
- ❌ Codex 호출 시 sandbox 미지정 → working tree 가 의도치 않게 변경될 위험
- ❌ Codex 와 Claude 의견이 갈렸을 때 Claude 가 임의 판정 → 의견이 갈릴 경우 사용자에게 판단을 맡깁니다.
