# Fixture — Korean Colon Violation

> 본 fixture는 한국어 문장이 콜론으로 종결됩니다. `korean-colon` 경고가 나야 함.

## Tradeoff

다음과 같은 케이스를 검증합니다:

## 본문

이 문장도 콜론으로 끝납니다:

```bash
# 코드블록 안의 콜론은 면제되어야 함:
echo "OK"
```

영문은 면제: When creating PRs:

## 안티패턴

- ❌ 한국어 콜론 종결
