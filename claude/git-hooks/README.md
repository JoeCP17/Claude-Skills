# Global Git Hooks — hedwig-cg Auto-Update

이 디렉토리는 `git config --global core.hooksPath` 로 등록되어 **모든 레포의 git 작업 시 자동으로 hedwig-cg 인덱스를 갱신**합니다.

## 활성화

```bash
git config --global core.hooksPath ~/Documents/GitHub/Claude-Skills/claude/git-hooks
```

## 동작

아래 git 이벤트 발생 시 **기존 DB가 있는 레포에 한해** 백그라운드로 `hedwig-cg-auto update` 실행:

| 훅 | 트리거 |
|----|--------|
| `post-merge` | `git pull`, `git merge` |
| `post-checkout` | `git checkout <branch>`, `git clone` (branch switch 한정, 파일 단위 checkout은 제외) |
| `post-rewrite` | `git rebase`, `git commit --amend` |

## 안전장치

- 기존 DB가 없는 레포는 자동 빌드하지 않음 (의도치 않은 대형 빌드 방지)
- 백그라운드 실행 + `disown` 으로 git 커맨드 지연 없음
- `HEDWIG_CG_DISABLE_HOOK=1` 로 임시 비활성화 가능
- 로그: `~/.hedwig-cg/logs/<repo>.log`
- `hedwig-cg-auto` 가 PATH에 없으면 no-op (설치 안 된 환경에서도 안전)

## 기존 hook과의 충돌

`core.hooksPath` 는 전역이므로 레포별 `.git/hooks/` 는 무시됩니다. 단 **husky 쓰는 레포는 husky가 자체적으로 `core.hooksPath` 를 `.husky/` 로 재지정**하므로 정상 동작합니다 (husky > 전역 hooksPath).

husky 없는데 레포별 훅이 필요하면 해당 레포 로컬에서 `git config --local core.hooksPath .git/hooks` 로 덮어쓰면 됩니다.

## 비활성화

```bash
git config --global --unset core.hooksPath
```

## 수동 업데이트 (훅 없이)

```bash
hedwig-cg-auto update
```
