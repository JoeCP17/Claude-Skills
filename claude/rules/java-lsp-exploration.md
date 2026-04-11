# Java Code Exploration via LSP

## Purpose

Java 코드 탐색은 **반드시 LSP(Language Server Protocol) 도구**를 사용합니다. `grep`/`find`/`rg` 기반의 텍스트 매칭은 Java의 타입 계층·오버로드·제네릭·import 해석을 놓치기 때문에 비효율적입니다. Claude Code 2.0.74+ 는 `jdtls@claude-code-lsps` 플러그인을 통해 Eclipse JDT Language Server를 직접 호출할 수 있으므로, Java 탐색 요청 시 LSP 도구를 **우선 호출**합니다.

> 참고: [emacs-lsp/lsp-java](https://github.com/emacs-lsp/lsp-java) — Emacs에서 jdtls를 활용한 Java IDE 기능 구현. Claude Code는 동일한 jdtls를 MCP/plugin 경로로 노출합니다.

## 필수 사용 시점 (MUST use LSP)

다음 작업은 **무조건** LSP 도구로 수행합니다:

| 작업 | LSP 도구 | 대체 금지 이유 |
|------|----------|---------------|
| 메서드/클래스 **정의 위치** 찾기 | `goToDefinition` | grep은 동명이인·인터페이스·super 호출 구분 불가 |
| **구현체** 찾기 (interface → impl) | `goToImplementation` | grep으로 `implements X`만 찾으면 추상 클래스 중첩 누락 |
| **사용처(참조)** 찾기 | `findReferences` | grep은 `toString` 같은 공용 메서드명에서 오탐 폭주 |
| 메서드 **호출 계층** | `prepareCallHierarchy` + `incomingCalls` / `outgoingCalls` | grep으로는 간접 호출·람다·메서드 레퍼런스 추적 불가 |
| 파일 내 **심볼 구조** | `documentSymbol` | Read로 전체 훑기보다 토큰 효율 10배+ |
| 워크스페이스 **심볼 검색** | `workspaceSymbol` | 클래스/메서드 명 기반 정확 매칭, 패키지 포함 |
| 타입/Javadoc 정보 | `hover` | 오버로드·제네릭 바인딩 정확 판단 |

## 금지 (Anti-patterns)

```bash
# ❌ BAD — Java 심볼 탐색을 grep/rg로 수행
Grep pattern="class OrderService"
Grep pattern="public .* OrderService"
Grep pattern="implements PaymentGateway"

# ❌ BAD — 파일 전체를 Read로 훑어 구조 파악
Read file_path=".../OrderService.java"  # 수천 줄

# ❌ BAD — 참조처를 문자열로 검색
Grep pattern="orderService.cancel"
```

```
# ✅ GOOD — LSP 도구로 직접 질의
LSP: workspaceSymbol query="OrderService"
LSP: goToDefinition file=X line=Y character=Z
LSP: findReferences symbol="OrderService.cancel"
LSP: documentSymbol file=".../OrderService.java"
LSP: incomingCalls method="OrderService.cancel"
```

## 탐색 순서 (권장 워크플로우)

Java 관련 질문/조사가 들어오면 다음 순서로 수행합니다:

1. **진입점 찾기** → `workspaceSymbol` 로 클래스/메서드 명 검색
2. **구조 파악** → `documentSymbol` 로 해당 파일의 심볼 트리 확인 (Read보다 우선)
3. **정의 확인** → `goToDefinition` / `hover` 로 타입·시그니처·Javadoc 조회
4. **영향 범위** → `findReferences` 로 사용처 나열
5. **호출 흐름** → `incomingCalls` / `outgoingCalls` 로 호출 체인 추적
6. **최후의 수단**: 위 단계로 답이 안 나올 때만 `Grep`/`Read` fallback

## Fallback — grep/Read를 써도 되는 경우

다음에 해당할 때만 LSP 없이 진행합니다:

- `build.gradle(.kts)`, `pom.xml`, `application.yml` 등 **비 Java 파일**
- 주석·문자열 리터럴·로그 메시지 검색 (LSP 범위 밖)
- 심볼이 아닌 파일명 패턴 글롭 (예: `**/*Controller.java` 목록 나열)
- LSP 서버가 인덱싱 준비 중이거나 실패한 경우 (명시적으로 사용자에게 알리고 진행)

## 설치 검증

```bash
# 1. jdtls 바이너리
which jdtls                                # /opt/homebrew/bin/jdtls
jdtls --help                               # argparse 출력 확인

# 2. Claude Code 플러그인
claude plugin list | grep jdtls            # jdtls@claude-code-lsps enabled
cat ~/.claude/plugins/installed_plugins.json | grep jdtls

# 3. Java 버전 (JDK 21+ 필요)
java -version                              # 21 이상
```

문제 발생 시 트러블슈팅:

- `jdtls` 명령이 없으면 → `brew install jdtls`
- 플러그인이 `claude-plugins-official` 스코프로 설치되어 있으면 **동작하지 않음** → `claude plugin uninstall jdtls-lsp` 후 `claude plugin install jdtls@claude-code-lsps` 로 재설치
- 첫 호출 시 인덱싱에 수십 초 소요될 수 있음 (`startupTimeout: 90000ms` 기본값)
- Claude Code 재시작 후 첫 Java 탐색에 시간이 걸리는 것은 정상

## 리포팅 규칙

LSP로 탐색한 결과를 사용자에게 보고할 때:

- 파일 경로는 `file_path:line_number` 형태로 제공 (Claude Code 렌더러가 자동 링크)
- 심볼 이름과 함께 **어떤 LSP 함수로 찾았는지** 명시 (투명성)
  - 예: "`OrderService.cancel` 은 `findReferences` 로 12곳에서 참조됨"
- LSP가 fallback되어 grep을 사용했다면 이유를 명시 ("LSP 인덱싱 미완료로 grep fallback")
