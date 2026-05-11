# Korean Output Style

> 한국어 응답 종결부호 + 신규 소스 파일 한국어 헤더. [Karpathy 원칙](https://github.com/datajuny/andrej-karpathy-skills/blob/main/CLAUDE.md) 5·6번.

## Tradeoff

이 룰은 **응답 가독성 + 다른 세션 onboarding 비용 절감**이 목적. 코드 동작에는 영향 없음.
기존 파일을 재작성하라는 의미가 아닙니다 — **새로 쓰는 라인 / 새로 만드는 파일**에만 적용.

---

## 5. No Closing Colons — 한국어 문장 종결부호

**한국어 문장은 마침표(`.`), 물음표(`?`), 느낌표(`!`) 로 끝내세요. 콜론(`:`)으로 끝내지 마세요.**

LLM 학습 데이터의 영어 문서 습관이 한국어로 새어 나오는 패턴입니다. 다음 줄이 리스트나 코드 블록이라 해도 — 앞 문장은 마침표로 종결합니다.

### Anti-example

```markdown
# ❌ BAD
다음 명령어를 실행하세요:
```

```markdown
# ✅ GOOD
다음 명령어를 실행하세요.
```

```markdown
# ❌ BAD
이 함수는 다음을 수행합니다:
- 입력 검증
- 데이터 저장

# ✅ GOOD
이 함수는 다음을 수행합니다.
- 입력 검증
- 데이터 저장
```

### 콜론이 허용되는 경우

- **코드 안** — `if x:`, `field: Type`, `port: 8080`, etc.
- **Key-value 라벨** — `Note:`, `TODO:`, `Author:` (단어 직후 콜론, 문장 종결 아님)
- **마크다운 yaml frontmatter** — `name: foo`
- **표 안의 cell**

### 자기 검증

응답 작성 후 — 한국어 문장이 콜론으로 끝나는 곳을 빠르게 스캔. 있으면 마침표로 교체.

---

## 6. File Header — 신규 소스 파일 한국어 헤더

**새 소스 파일의 첫 줄 (또는 필수 지시자 직후) 은 한 줄 한국어 주석 — 파일의 역할 설명.**

LLM/사람이 파일을 부분적으로만 읽을 때, 첫 줄만 봐도 즉시 맥락이 잡히게 합니다.

### 언어별 형태

```typescript
// 사용자 인증 상태를 관리하는 Context Provider
```

```python
# KIS API 호출을 비동기로 래핑하는 클라이언트
```

```kotlin
// 결제 이벤트를 처리하는 도메인 서비스
```

```sql
-- 일별 집계 결과를 저장하는 머티리얼라이즈드 뷰
```

```rust
// 토큰 사용량 통계를 계산하는 누적기
```

```go
// JWT 토큰을 검증하는 미들웨어
```

### 배치 규칙

필수 지시자(`'use client'`, `'use server'`, shebang `#!/usr/bin/env bash`) 가 있으면 — 그 **직후** 줄에 헤더.

```typescript
'use client';
// 결제 위젯의 상태를 관리하는 클라이언트 컴포넌트

import { useState } from 'react';
```

```bash
#!/usr/bin/env bash
# 일일 토큰 사용량 집계 후 Slack에 보고

set -euo pipefail
```

### 면제 대상

- 설정 파일 — `*.config.ts`, `*.config.js`, `package.json`, `tsconfig.json`, `Cargo.toml`, `pom.xml`, `build.gradle.kts`, `*.yaml`, `*.yml`, `Dockerfile`, `Makefile`
- 자동 생성 파일 — `*.generated.*`, `*.pb.go`, `*_pb2.py`
- `__init__.py` (빈 파일이면)
- 마크다운 — 대신 첫 `# 제목` 직후 한 줄 `> Purpose` 로 헤더 역할 대체

### 왜 이게 가치 있는가

- 에이전트는 파일을 **선택적으로** 읽음. 헤더 한 줄이 곧 navigation의 시작점.
- 다음 세션 (사용자든 LLM이든) 이 전체 파일을 재독해 없이 진입 가능.
- 토큰 절약 (`token-optimization.md` 와 호환).

---

## 검증 (하네스 연동)

`claude/bin/check-md-rule.sh` 가 다음을 점검합니다.

- 한국어 문장 콜론 종결 — **경고**만 출력 (현재 (c) warning-only 모드)
- 마크다운 파일의 `# 제목` + `> Purpose` 골격 누락 — **경고**

차단(blocking)은 안 합니다. 작성자가 인지하고 자율 교정하는 게 목적.

---

## 안티패턴

- ❌ "다음과 같이 구현했습니다:" → "다음과 같이 구현했습니다."
- ❌ 새 React 컴포넌트 파일을 헤더 없이 `import React from 'react'`로 시작
- ❌ shebang 앞에 한국어 헤더 (인터프리터가 깨짐)
- ❌ 영어로 "사용자 인증 컴포넌트" 같은 직역 — 자연스러운 한국어로
- ❌ 헤더에 TODO/메타정보 (`// TODO: refactor this`) — **역할** 설명만
