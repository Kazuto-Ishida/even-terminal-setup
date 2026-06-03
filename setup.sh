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
  warn "Run 'claude' to complete browser authentication on first launch."
}

# ─── 4. Tailscale ──────────────────────────────────────────────────────────────
install_tailscale() {
  info "Installing Tailscale..."
  curl -fsSL https://tailscale.com/install.sh | sh
  success "Tailscale installed."
  warn "Run 'sudo tailscale up' and open the printed URL to authenticate."
  warn "After auth, run 'tailscale ip' — a 100.x.x.x address means success."
}

# ─── 5. even-terminal ──────────────────────────────────────────────────────────
install_even_terminal() {
  info "Installing even-terminal..."
  npm install -g @evenrealities/even-terminal
  success "even-terminal $(even-terminal --version) ready."
}

# ─── main ──────────────────────────────────────────────────────────────────────
main() {
  require_ubuntu

  echo ""
  echo -e "${CYAN}========================================${NC}"
  echo -e "${CYAN}  Ubuntu setup: nvm / Node / Claude Code${NC}"
  echo -e "${CYAN}  Tailscale / even-terminal             ${NC}"
  echo -e "${CYAN}========================================${NC}"
  echo ""

  install_nvm
  install_node
  install_claude_code
  install_tailscale
  install_even_terminal

  echo ""
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}  All done!                             ${NC}"
  echo -e "${GREEN}========================================${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. source ~/.bashrc          # reload shell"
  echo "  2. claude                    # authenticate Claude Code"
  echo "  3. sudo tailscale up         # authenticate Tailscale"
  echo "  4. even-terminal --tailscale # start even-terminal"
}

main "$@"
