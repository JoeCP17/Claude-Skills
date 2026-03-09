---
name: datadog-error-report
description: Use when user requests Datadog error status report for a specific server instance and date range. Triggers on keywords like error report, error status, Datadog monitoring, instance error check, 서비스 현황, 에러 리포트, 장애 현황, latency 분석, API 성능.
---

# Datadog Error Report

## Overview

Datadog MCP를 통해 특정 서비스 인스턴스의 에러 현황과 API 성능을 종합 리포팅한다. 사용자가 인스턴스명과 날짜를 제공하면 에러 로그, 인시던트, 모니터, 이벤트, API Latency/TPS를 수집하여 리포트를 생성한다.

## When to Use

- 사용자가 특정 서버/인스턴스의 에러 현황을 요청할 때
- "에러 리포트", "에러 현황", "장애 현황", "서비스 현황" 등의 키워드가 포함될 때
- API 성능(Latency, TPS) 분석을 요청할 때
- Datadog 기반 모니터링 데이터 조회가 필요할 때

## Input Format

사용자가 다음 정보를 제공한다:
- **인스턴스명**: Datadog service 태그에 매핑되는 서비스 이름 (예: Thomas, Alice)
- **시작 시간**: 조회 시작 시점 (예: 2026.03.03 00:00:00)
- **종료 시간**: 조회 종료 시점 (미지정 시 현재 시간 사용)
- **환경**: prod/dev/stage (미지정 시 기본 `prod`)

## Execution Steps

### Step 1: 파라미터 파싱

사용자 입력에서 추출:
- `service_name`: 인스턴스명 (소문자 변환)
- `env`: 환경 (기본값: prod)
- `from_time`: 시작 시간 → Unix timestamp (**밀리초**)
- `to_time`: 종료 시간 → Unix timestamp (**밀리초**), 미지정 시 현재 시간

**반드시 Python으로 타임스탬프를 계산한다:**
```python
from datetime import datetime, timezone, timedelta
kst = timezone(timedelta(hours=9))
from_dt = datetime(YYYY, M, D, H, m, s, tzinfo=kst)
from_ms = int(from_dt.timestamp() * 1000)
```

### Step 2: ToolSearch로 Datadog MCP 도구 로드

**반드시 데이터 조회 전에 ToolSearch를 실행하여 도구를 로드해야 한다.**

기본 4종 + 성능 분석 2종 = **6종 병렬 로드**:
```
ToolSearch: select:mcp__datadog-mcp__search_datadog_logs
ToolSearch: select:mcp__datadog-mcp__search_datadog_incidents
ToolSearch: select:mcp__datadog-mcp__search_datadog_monitors
ToolSearch: select:mcp__datadog-mcp__search_datadog_events
ToolSearch: select:mcp__datadog-mcp__get_datadog_metric
ToolSearch: select:mcp__datadog-mcp__analyze_datadog_logs
```

### Step 3: 데이터 병렬 수집 (6가지)

모든 조회를 **병렬로** 실행한다.

#### 3-1. 에러 로그 조회 (패턴 모드)

**반드시 `use_log_patterns: true`로 먼저 조회**하여 에러 전체 윤곽을 파악한다.

```
mcp__datadog-mcp__search_datadog_logs
- query: "service:<service_name> env:<env> status:error"
- from: <unix_ms>
- to: <unix_ms>
- use_log_patterns: true
- max_tokens: 8000
```

#### 3-2. 인시던트 조회
```
mcp__datadog-mcp__search_datadog_incidents
- query: "title:*<service_name>*"
- from: <ISO8601_with_KST>
- to: <ISO8601_with_KST>
```

#### 3-3. 모니터 상태 조회
```
mcp__datadog-mcp__search_datadog_monitors
- query: "<service_name>"
```

#### 3-4. 이벤트 조회
```
mcp__datadog-mcp__search_datadog_events
- query: "<service_name>"
- from: <unix_ms>
- to: <unix_ms>
```

#### 3-5. API Latency 분석 (p99)
```
mcp__datadog-mcp__get_datadog_metric
- queries: ["p99:trace.servlet.request{service:<service_name>,env:<env>} by {resource_name}"]
- from: <unix_ms>
- to: <unix_ms>
- max_tokens: 15000
```
> 결과가 파일로 저장되면 Bash + Python으로 파싱하여 p99 avg 기준 내림차순 정렬한다.

#### 3-6. TPS / 총 요청량 분석
```
mcp__datadog-mcp__get_datadog_metric
- queries: ["sum:trace.servlet.request.hits{service:<service_name>,env:<env>}.as_count()"]
- from: <unix_ms>
- to: <unix_ms>
```
엔드포인트별 요청량:
```
- queries: ["sum:trace.servlet.request.hits{service:<service_name>,env:<env>} by {resource_name}.as_count()"]
```

### Step 4: 에러 로그 분류

패턴 결과를 아래 3가지로 **반드시 분류**한다:

#### 카테고리 A: 인프라/에이전트 노이즈 (리포트에서 별도 표기)
아래 패턴이 포함된 로그는 인프라 노이즈로 분류:
- `dd.trace` + `INFO` (Datadog agent 내부 로그가 error로 잘못 수집된 것)
- `JAVA_TOOL_OPTIONS`
- `OpenJDK 64-Bit Server VM warning`
- `logback` / `Appender named [CONSOLE]`
- `DebuggerAgent`, `StatusLogger`, `DDAgentStatsDConnection`
- `ProfileUploader`, `SymDB Report`
- `Picked up JAVA_TOOL_OPTIONS`

#### 카테고리 B: 배포(Rolling Update) 관련 에러
- HTTP 503 에러 중 배포 이벤트 시점과 일치하는 것
- Readiness probe 실패와 시간대가 겹치는 요청 에러

#### 카테고리 C: 실제 애플리케이션 에러 (핵심 리포트 대상)
- 카테고리 A, B에 해당하지 않는 모든 에러
- 에러 메시지별 빈도, 시간 분포, 영향도를 분석

### Step 5: 상세 에러 로그 조회 (카테고리 C)

카테고리 C 에러에 대해 **노이즈를 제외한 raw 로그**를 조회한다:
```
mcp__datadog-mcp__search_datadog_logs
- query: "service:<service_name> env:<env> status:error -\"dd.trace\" -\"JAVA_TOOL_OPTIONS\" -\"OpenJDK\" -\"Appender named\" -\"Picked up\""
- from: <unix_ms>
- to: <unix_ms>
- use_log_patterns: false
- extra_fields: ["http*", "error*", "exception*"]
- max_tokens: 10000
```

### Step 6: 리포트 생성

수집된 데이터를 아래 형식으로 정리:

```markdown
# [인스턴스명] 에러 현황 리포트

- 조회 기간: YYYY.MM.DD HH:mm:ss ~ YYYY.MM.DD HH:mm:ss (KST)
- 조회 환경: prod / dev / stage
- 보고서 생성 시각: YYYY.MM.DD HH:mm:ss (KST)

---

## 1. 에러 로그 요약

| 항목 | 내용 |
|------|------|
| 총 에러 로그 수 | N건 |
| 인프라 노이즈 (카테고리 A) | N건 |
| 배포 관련 에러 (카테고리 B) | N건 |
| **실제 애플리케이션 에러 (카테고리 C)** | **N건** |

### 1-1. 실제 애플리케이션 에러 상세

| 에러 메시지 | 발생 횟수 | 환경 | 발생 시간대 (KST) | 원인 분석 |
|------------|----------|------|------------------|----------|
| [에러 메시지] | N회 | prod/dev | HH:mm~HH:mm | [분석 내용] |

### 1-2. 에러 간 연관 관계 분석
- 같은 시간대에 발생한 에러들의 인과관계를 분석
- 예: PG 환불 실패 → NPE → 재고 복원 실패 등 연쇄 관계

---

## 2. 인시던트 현황

| 상태 | 건수 |
|------|------|
| Active | N건 |
| Resolved | N건 |

### 인시던트 목록
- [제목] - 상태 - 생성일시

---

## 3. 모니터 상태

| 상태 | 건수 |
|------|------|
| Alert | N건 |
| Warn | N건 |
| OK | N건 |

### 알림 발생 모니터 목록
- [모니터명] - 상태 - 마지막 트리거

---

## 4. 이벤트 현황

| 항목 | 내용 |
|------|------|
| 총 이벤트 수 | N건 |

### 주요 이벤트 (배포, 스케일링, 장애 관련)
- [이벤트 제목] - 발생 시각 (KST)

---

## 5. API 성능 분석

### 5-1. TPS / 요청량 요약

| 항목 | 수치 |
|------|------|
| 조회 기간 총 요청수 | N건 |
| 일 평균 요청수 | N건/일 |
| 평균 TPS | N TPS |
| 피크 TPS | N TPS (시간대) |

### 5-2. API별 요청량 Top 10

| # | API 엔드포인트 | 총 요청수 | 일평균 | 평균 TPS | 비중 |
|---|---------------|----------|--------|---------|------|
| 1 | [endpoint] | N건 | N건 | N | N% |

### 5-3. Slow API (p99 >= 800ms)

| # | API 엔드포인트 | p99 평균 | p99 최대 | 총 요청수 | 평균 TPS |
|---|---------------|---------|---------|----------|---------|
| 1 | [endpoint] | Nms | Nms | N건 | N |

### 5-4. 준-위험 구간 (p99 500~800ms)
- 800ms 미만이지만 주의가 필요한 API 목록

---

## 6. 종합 권장 사항

| 우선순위 | 항목 | 설명 |
|---------|------|------|
| HIGH | [항목] | [설명] |
| MED | [항목] | [설명] |
| LOW | [항목] | [설명] |
```

### Step 7: Datadog 딥링크 제공

사용자가 특정 에러의 상세 확인을 요청하면 Datadog Logs Explorer URL을 생성한다.

**URL 구성 규칙:**
```
https://app.datadoghq.com/logs?query=<URL_ENCODED_QUERY>&from_ts=<UNIX_MS>&to_ts=<UNIX_MS>&live=false
```

**쿼리 작성 규칙 (중요):**
- 에러 메시지 검색 시 **반드시 `@error.message` 또는 `@error.kind` 패싯을 사용**한다
- 풀텍스트 검색은 특수문자(괄호, 따옴표 등)로 인해 UI에서 동작하지 않을 수 있다
- 와일드카드 사용: `@error.message:*키워드*`

**올바른 예시:**
```
service:thomas env:dev status:error @error.message:*HasResultError*
service:thomas env:prod status:error @error.kind:java.lang.NullPointerException
service:thomas env:prod status:error @error.message:*refund*
```

**잘못된 예시 (UI에서 검색 안 됨):**
```
service:thomas status:error "ResultSet.HasResultError()"   ← 괄호/따옴표 문제
service:thomas status:error HasResultError                  ← 풀텍스트 매칭 불안정
```

## TPS / 일평균 계산 공식

```
조회_시간_초 = (to_ms - from_ms) / 1000
평균_TPS = 총_요청수 / 조회_시간_초
일_평균_요청수 = 총_요청수 * 86400 / 조회_시간_초
피크_TPS = max_bin_hits / bin_interval_초
```

## p99 Latency 결과 파싱

`get_datadog_metric` 결과가 파일로 저장된 경우 아래 Python으로 파싱:
```python
import json
with open('<file_path>', 'r') as f:
    data = json.loads(f.read())
text = data[0]['text']
json_data = json.loads(text[text.find('[{'):])
sorted_data = sorted(json_data, key=lambda x: x.get('overall_stats',{}).get('avg',0), reverse=True)
for item in sorted_data:
    scope = item['scope'].replace('resource_name:', '')
    avg = item['overall_stats']['avg']
    mx = item['overall_stats']['max']
    print(f'{scope}: p99_avg={avg*1000:.1f}ms  p99_max={mx*1000:.1f}ms')
```

## Common Mistakes

- ToolSearch 없이 바로 Datadog MCP 도구를 호출하면 실패한다. **반드시 ToolSearch를 먼저 실행**
- 시간 변환 시 KST(UTC+9) 기준을 빠뜨리지 않도록 주의. **반드시 Python으로 계산**
- timestamp는 **밀리초(ms)** 단위로 전달해야 한다 (초가 아님)
- 6가지 조회를 순차적으로 하면 느리다. **반드시 병렬 호출**
- 데이터가 없는 섹션도 "해당 기간 내 데이터 없음"으로 표기해야 한다
- **에러 로그를 분류 없이 나열하면 안 된다.** 반드시 카테고리 A/B/C로 분류하여 실제 에러만 부각
- Datadog URL 제공 시 **풀텍스트가 아닌 `@error.message`/`@error.kind` 패싯을 사용**해야 UI에서 정상 동작
- `env` 필터를 빠뜨리면 prod/dev/stage 에러가 혼재되어 잘못된 분석이 된다
- p99 메트릭명은 `p99:trace.servlet.request{...}`이다 (`trace.servlet.request.duration`이 아님)
- 메트릭 결과가 파일로 저장되면 Read가 아닌 **Bash + Python으로 파싱**해야 한다
