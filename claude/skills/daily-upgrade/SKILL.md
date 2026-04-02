---
name: daily-upgrade
description: "Upgrade all development tools via Homebrew, sync Brewfile packages, and verify RTK hooks. Use this skill whenever the user mentions daily upgrade, brew update, package upgrade, claude-code update, 데일리 업그레이드, 브루 업데이트, 패키지 업데이트, 일일 업그레이드, or any request to bring their dev environment up to date — even casual mentions like 'update everything' or '오늘 업데이트 좀'."
---

# Daily Upgrade

Bring the entire dev environment to latest: Homebrew packages, Brewfile sync, and RTK hook health.

## Steps

1. **Update Homebrew metadata** — without fresh metadata, `brew upgrade` won't see newly available versions.
   ```bash
   brew update
   ```

2. **Sync Brewfile** — install any missing packages so the environment stays reproducible.
   ```bash
   brew bundle install --file=~/Desktop/Claude-Skills/homebrew/Brewfile
   ```

3. **Upgrade all packages** — formulae and casks.
   ```bash
   brew upgrade
   ```

4. **Upgrade Claude Code** — 네이티브 설치이므로 brew 대신 자체 업그레이드 사용.
   ```bash
   claude update
   ```

5. **Cleanup** — remove stale versions to free disk space. Only useful after upgrade creates outdated versions.
   ```bash
   brew cleanup
   ```

6. **Verify RTK hooks** — the token-saving proxy can break after upgrades, so always check.
   ```bash
   rtk init --show
   ```
   If broken, repair with `rtk init --global --auto-patch`.

7. **Report results**:

   | Item | Result |
   |------|--------|
   | brew update | OK / failure reason |
   | Brewfile sync | N packages installed / already up to date |
   | brew upgrade | N upgraded / already up to date |
   | claude update | OK / already latest |
   | brew cleanup | N cleaned / nothing to clean |
   | Claude Code version | vX.X.X |
   | rtk version | vX.X.X |
   | rtk hook status | OK / needs repair |
