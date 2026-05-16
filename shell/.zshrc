# .zshrc - Zsh 설정 파일
# 마지막 업데이트: 2026-04-02

path=(/opt/homebrew/bin /opt/homebrew/opt/node@20/bin $path)
typeset -U path PATH

# ---------------------------------------------------------------------------
# NVM (Node Version Manager)
# ---------------------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# ---------------------------------------------------------------------------
# PATH 설정 (Claude Code 네이티브 설치 경로 포함)
# ---------------------------------------------------------------------------
export PATH="$PATH:$HOME/.local/bin"

# ---------------------------------------------------------------------------
# claude-squad: Claude-Skills 디렉토리에서 항상 실행
# ---------------------------------------------------------------------------
function cs() {
  cd ~/Claude-Skills && /opt/homebrew/bin/cs "$@"
}

# ---------------------------------------------------------------------------
# codex: Claude-Skills 디렉토리에서 항상 실행
# ---------------------------------------------------------------------------
function cx() {
  cd ~/Claude-Skills && /opt/homebrew/bin/codex "$@"
}
