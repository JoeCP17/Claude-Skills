---
name: wrap
description: Use when user wants to save current session's work summary to memory before ending conversation, 세션 정리, 세션 저장, 작업 내용 저장, 메모리 저장, 세션 마무리, 세션 wrap-up
---

# Session Wrap-up

## Overview

현재 세션에서 진행한 작업 내용을 분석하여 메모리 시스템에 저장한다. 다음 세션에서 컨텍스트를 빠르게 복원할 수 있도록 핵심 내용만 정리한다.

## When to Use

- 사용자가 `/wrap` 또는 "세션 정리", "작업 내용 저장" 등을 요청할 때
- 긴 세션을 마무리하며 진행 상황을 기록하고 싶을 때

## Execution Steps

### Step 1: 세션 내용 분석

현재 대화에서 수행한 작업을 분석하여 아래 카테고리로 분류한다:

- **완료된 작업**: 구현, 수정, 배포 등 완료된 항목
- **진행 중인 작업**: 시작했으나 미완료인 항목
- **발견된 이슈**: 해결이 필요한 버그나 문제
- **결정 사항**: 설계/아키텍처 관련 결정
- **다음 단계**: 후속 세션에서 이어서 해야 할 작업

### Step 2: 메모리 파일 작성

메모리 디렉토리: `~/.claude/projects/{project-path}/memory/`

**파일명 규칙**: `session-{YYYY-MM-DD}-{주제키워드}.md`

```markdown
---
name: {날짜} {주제} 세션 요약
description: {한줄 요약 - 무엇을 했고 어디까지 진행했는지}
type: project
---

## 세션 요약 ({날짜})

### 완료된 작업
- 항목 1
- 항목 2

### 진행 중인 작업
- 항목 (현재 상태 설명)

### 결정 사항
- 결정 내용 — **Why:** 이유

### 다음 단계
- [ ] 후속 작업 1
- [ ] 후속 작업 2
```

### Step 3: MEMORY.md 인덱스 업데이트

`MEMORY.md`에 새 메모리 파일 링크를 추가한다. `## Sessions` 섹션이 없으면 생성한다.

```markdown
## Sessions
- [{날짜} {주제}](session-{date}-{topic}.md) - 한줄 요약
```

### Step 4: 기존 메모리 업데이트 확인

세션 중 기존 메모리에 해당하는 내용이 변경되었다면 (예: 프로젝트 상태 변경, 새로운 결정 등) 해당 메모리 파일도 함께 업데이트한다.

### Step 5: 결과 리포트

```markdown
## Session Wrap-up 완료

| 항목 | 내용 |
|------|------|
| 저장된 파일 | `session-{date}-{topic}.md` |
| 완료 작업 | N건 |
| 진행 중 | N건 |
| 다음 단계 | N건 |
| 기존 메모리 업데이트 | 있음/없음 |
```

## Common Mistakes

- 세션 내용을 너무 상세하게 기록하면 메모리가 비대해진다 — 핵심만 간결하게
- 코드 변경사항을 메모리에 복사하지 말 것 — git log로 확인 가능
- 상대 날짜(오늘, 내일) 대신 절대 날짜(2026-03-15)를 사용할 것
