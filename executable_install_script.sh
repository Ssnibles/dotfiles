#!/usr/bin/env bash
set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Package lists
readonly CRITICAL_PACKAGES=(
  ttf-font-awesome noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd ttf-roboto
  swww bluez bluez-utils blueman curl starship go npm neovim eza zoxide lazygit
  tmux tree-sitter-cli texlive-latex rustup luarocks vicinae-bin
  imagemagick texlive-latexextra hyprlock waybar
  wordnet-common
)

readonly OPTIONAL_PACKAGES=(
  "zed:High-performance multiplayer code editor"
  "neofetch:System information tool"
  "htop:Interactive process viewer"
  "vesktop:Discord client with Linux optimizations"
  "bat:Cat with syntax highlighting"
  "ripgrep:Fast text search"
  "fd:Fast find alternative"
)

# Simple logging
log() {
  local level="$1" && shift
  local color="$NC"
  case "$level" in
  INFO) color="$BLUE" ;;
  SUCCESS) color="$GREEN" ;;
  WARN) color="$YELLOW" ;;
  ERROR) color="$RED" ;;
  esac
  printf "${color}[%s]${NC} %s\n" "$level" "$*"
}

# Simple yes/no prompt
ask() {
  printf "${BLUE}%s${NC} (y/N): " "$1"
  read -r response
  [[ "${response,,}" =~ ^(y|yes)$ ]]
}

# Basic checks
check_system() {
  [[ $EUID -ne 0 ]] || {
    log ERROR "Don't run as root"
    exit 1
  }
  command -v pacman >/dev/null || {
    log ERROR "Requires Arch-based system"
    exit 1
  }
  sudo -v || {
    log ERROR "Sudo required"
    exit 1
  }
}

# Install paru if needed
ensure_paru() {
  if command -v paru >/dev/null; then
    log SUCCESS "paru already installed"
    return
  fi

  log INFO "Installing paru..."
  sudo pacman -S --needed --noconfirm base-devel git

  local tmpdir=$(mktemp -d)
  trap "rm -rf '$tmpdir'" EXIT

  git clone --depth 1 https://aur.archlinux.org/paru.git "$tmpdir/paru"
  (cd "$tmpdir/paru" && makepkg -si --noconfirm)

  log SUCCESS "paru installed"
}

# Install packages - let paru handle everything
install_packages() {
  local packages=("$@")
  [[ ${#packages[@]} -gt 0 ]] || return 0

  log INFO "Installing ${#packages[@]} packages..."

  if paru -S --needed --noconfirm "${packages[@]}"; then
    log SUCCESS "Packages installed"
  else
    log WARN "Some packages may have failed"
    ask "Continue anyway?" || exit 1
  fi
}

# Setup services
setup_services() {
  log INFO "Configuring services..."

  # Bluetooth if hardware present
  if [[ -d /sys/class/bluetooth ]]; then
    sudo systemctl enable --now bluetooth.service &>/dev/null &&
      log SUCCESS "Bluetooth enabled" ||
      log WARN "Bluetooth setup failed"
  fi
}

# Optional packages
install_optional() {
  log INFO "Optional packages:"
  for item in "${OPTIONAL_PACKAGES[@]}"; do
    IFS=':' read -r pkg desc <<<"$item"
    printf "  • %s - %s\n" "$pkg" "$desc"
  done
  echo

  ask "Install optional packages?" || return 0

  local selected=()
  for item in "${OPTIONAL_PACKAGES[@]}"; do
    IFS=':' read -r pkg desc <<<"$item"
    ask "Install $pkg?" && selected+=("$pkg")
  done

  [[ ${#selected[@]} -gt 0 ]] && install_packages "${selected[@]}"
}

# TMux plugin manager
setup_tmux() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"

  [[ -d "$tpm_dir" ]] && {
    log SUCCESS "TPM already installed"
    return
  }
  command -v tmux >/dev/null || {
    log WARN "tmux not found, skipping TPM"
    return
  }

  log INFO "Installing tmux plugin manager..."
  mkdir -p "$(dirname "$tpm_dir")"

  if git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"; then
    log SUCCESS "TPM installed - use prefix+I to install plugins"
  else
    log WARN "TPM installation failed"
  fi
}

# Main
main() {
  log INFO "Starting dotfiles installation..."

  check_system
  ensure_paru

  # Let paru handle updates completely
  log INFO "Updating system with paru..."
  paru -Syu --noconfirm || log WARN "Update had issues, continuing..."

  # Install packages
  install_packages "${CRITICAL_PACKAGES[@]}"
  setup_services
  install_optional
  setup_tmux

  log SUCCESS "Installation complete!"
  log INFO "Restart your session if needed"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
