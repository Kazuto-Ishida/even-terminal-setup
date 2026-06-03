#!/usr/bin/env bash
# Ubuntu setup: nvm / Node.js LTS / Claude Code / Tailscale / even-terminal
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC}   $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()     { echo -e "${RED}[ERR]${NC}  $*" >&2; exit 1; }

require_ubuntu() {
  [[ -f /etc/os-release ]] || die "Cannot detect OS."
  # shellcheck source=/dev/null
  source /etc/os-release
  case "$ID" in ubuntu|debian) ;; *) die "This script targets Ubuntu/Debian (detected: $ID)." ;; esac
}

# ─── 1. nvm ────────────────────────────────────────────────────────────────────
install_nvm() {
  info "Installing nvm v0.39.7..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

  export NVM_DIR="$HOME/.nvm"
  # shellcheck source=/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  if ! grep -q 'NVM_DIR' "$HOME/.bashrc" 2>/dev/null; then
    warn ".bashrc does not contain NVM_DIR export — adding manually."
    {
      echo ''
      echo 'export NVM_DIR="$HOME/.nvm"'
      echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
      echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
    } >> "$HOME/.bashrc"
  fi

  success "nvm $(nvm --version) ready."
}

# ─── 2. Node.js LTS ────────────────────────────────────────────────────────────
install_node() {
  info "Installing Node.js LTS..."
  nvm install --lts
  nvm use --lts
  nvm alias default 'lts/*'
  success "node $(node -v) / npm $(npm -v) ready."
}

# ─── 3. Claude Code ────────────────────────────────────────────────────────────
install_claude_code() {
  info "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | sh
  success "Claude Code installed."
}

auth_claude() {
  echo ""
  warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  warn "  Claude Code の認証を行います。"
  warn "  ブラウザで表示される URL を開いてログインしてください。"
  warn "  完了したら Ctrl+C で抜けて次のステップに進みます。"
  warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  claude || true
}

# ─── 4. Tailscale ──────────────────────────────────────────────────────────────
install_tailscale() {
  info "Installing Tailscale..."
  curl -fsSL https://tailscale.com/install.sh | sh
  success "Tailscale installed."
}

auth_tailscale() {
  echo ""
  warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  warn "  Tailscale の認証を行います。"
  warn "  表示される URL をブラウザで開いてログインしてください。"
  warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  sudo tailscale up

  local ip
  ip=$(tailscale ip 2>/dev/null | head -1 || true)
  if [[ "$ip" == 100.* ]]; then
    success "Tailscale connected: $ip"
  else
    warn "Tailscale IP が取得できませんでした。後で 'tailscale ip' で確認してください。"
  fi
}

# ─── 5. even-terminal ──────────────────────────────────────────────────────────
install_even_terminal() {
  info "Installing even-terminal..."
  npm install -g @evenrealities/even-terminal
  success "even-terminal $(even-terminal --version) ready."
}

start_even_terminal() {
  echo ""
  warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  warn "  even-terminal を起動します (--tailscale モード)。"
  warn "  iPhone の Even App から接続できます。"
  warn "  終了するには Ctrl+C を押してください。"
  warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  even-terminal --tailscale
}

# ─── main ──────────────────────────────────────────────────────────────────────
main() {
  require_ubuntu

  echo ""
  echo -e "${CYAN}========================================${NC}"
  echo -e "${CYAN}  even-terminal setup                   ${NC}"
  echo -e "${CYAN}  nvm / Node / Claude Code / Tailscale  ${NC}"
  echo -e "${CYAN}========================================${NC}"
  echo ""

  install_nvm
  install_node
  install_claude_code
  auth_claude
  install_tailscale
  auth_tailscale
  install_even_terminal
  start_even_terminal
}

main "$@"
