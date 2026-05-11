# Fixture — Good Rule

> 모든 골격을 만족하는 통과 케이스. check-md-rule.sh가 경고 0건을 내야 함.

## Tradeoff

이 fixture는 정상 룰 모범 사례. 검증기가 false-positive를 내는지 확인하는 용도.

## 예시 원칙

**한국어 문장은 마침표로 끝나야 합니다.**

코드블록 안의 콜론은 OK.

```bash
echo "다음을 실행:"   # 코드 안이라 면제
```

## 안티패턴

- ❌ 콜론 종결 문장
- ❌ Tradeoff 누락
- ❌ 안티패턴 섹션 없음
