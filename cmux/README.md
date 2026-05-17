# cmux 설정

cmux 앱 설정과 Ghostty 터미널 테마를 백업한다.

## 백업 대상

| 파일 | 복원 위치 | 설명 |
|------|-----------|------|
| `cmux.json` | `~/.config/cmux/cmux.json` | cmux JSONC 설정. file-managed 값만 명시하고 나머지는 앱 기본값 사용 |
| `config.ghostty` | `~/Library/Application Support/com.cmuxterm.app/config.ghostty` | cmux 내장 Ghostty 터미널 테마 |

## 제외 대상

- `~/Library/Application Support/cmux/session-*.json` — 런타임 세션 상태
- `~/Library/Application Support/cmux/cmux.sock` — 런타임 socket
- `~/Library/Application Support/com.cmuxterm.app/browser_history.json` — 브라우저 히스토리
- `posthog.*`, cache, log, plist — 사용자/런타임 상태

## 수동 복원

```bash
mkdir -p ~/.config/cmux
cp ~/LLM-Dot-files/cmux/cmux.json ~/.config/cmux/cmux.json

mkdir -p ~/Library/Application\ Support/com.cmuxterm.app
cp ~/LLM-Dot-files/cmux/config.ghostty ~/Library/Application\ Support/com.cmuxterm.app/config.ghostty
```

## 현재 테마

```text
theme = dark:Catppuccin Mocha
```
