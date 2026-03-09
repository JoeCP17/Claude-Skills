# .zshrc - Zsh 설정 파일
# 마지막 업데이트: 2026-03-09

# ---------------------------------------------------------------------------
# NVM (Node Version Manager)
# ---------------------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# ---------------------------------------------------------------------------
# PATH 설정
# ---------------------------------------------------------------------------
export PATH="$PATH:/Users/ktown4u/.local/bin"

# ---------------------------------------------------------------------------
# claude-squad: Claude-Skills 디렉토리에서 항상 실행
# ---------------------------------------------------------------------------
function cs() {
  cd ~/Claude-Skills && /opt/homebrew/bin/cs "$@"
}
