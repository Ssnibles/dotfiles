#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Global Configuration
# ==============================================================================

# Script name for logging
SCRIPT_NAME="DotfilesInstaller"

# Colors for output
declare -A colors=(
  [RED]='\033[0;31m'
  [GREEN]='\033[0;32m'
  [YELLOW]='\033[1;33m'
  [BLUE]='\033[0;34m'
  [NC]='\033[0m' # No Color
)

# Critical packages - these are essential for the dotfiles to function
critical_packages=(
  ttf-font-awesome noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd ttf-roboto
  swww bluez bluez-utils blueman curl starship go npm neovim eza zoxide lazygit tmux python-pywal16
  ghostty tree-sitter-cli texlive-latex rust luarocks imagemagick pet-bin rose-pine-hyprcursor texlive-latexextra
  hyprlock waybar wordnet-common
)

# Optional programs - user will be prompted to install these
declare -a optional_programs=(
  "zed:A high-performance, multiplayer code editor from the creators of Atom and Tree-sitter"
  "neofetch:Command-line system information tool"
  "htop:Interactive process viewer"
  "vesktop:Customizable Discord client with Linux optimizations"
)

# ==============================================================================
# Logging Functions
# ==============================================================================

# Internal logging function
_log() {
  local level="$1"
  local message="$2"
  local color="${colors[$3]:-${colors[NC]}}"
  printf "${color}[%s] %s: %s${colors[NC]}\n" "$level" "$SCRIPT_NAME" "$message"
}

# Public logging functions
log_info() {
  _log "INFO" "$1" "BLUE"
}

log_success() {
  _log "SUCCESS" "$1" "GREEN"
}

log_warn() {
  _log "WARN" "$1" "YELLOW"
}

log_error() {
  _log "ERROR" "$1" "RED"
}

# ==============================================================================
# Utility Functions
# ==============================================================================

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to run a command and log its status
# Args: $1 = command to run, $2 = success message, $3 = failure message (optional)
run_command() {
  local cmd="$1"
  local success_msg="$2"
  local failure_msg="${3:-Failed to execute command: '$cmd'}"

  log_info "Executing: $cmd"
  if eval "$cmd"; then
    log_success "$success_msg"
    return 0
  else
    log_error "$failure_msg"
    return 1
  fi
}

# Function to prompt user for a yes/no response
# Args: $1 = prompt message
# Returns 0 for yes, 1 for no
prompt_yes_no() {
  local prompt_msg="$1"
  while true; do
    log_info "$prompt_msg (y/N): "
    read -r -n 1 response
    echo # Newline after response
    case "$response" in
    [yY]) return 0 ;;
    [nN] | "") return 1 ;; # Default to No if Enter is pressed
    *) log_warn "Invalid response. Please enter 'y' or 'n'." ;;
    esac
  done
}

# ==============================================================================
# Installation Steps Functions
# ==============================================================================

# Checks for necessary prerequisites like root privileges and sudo access.
check_prerequisites() {
  log_info "Checking script prerequisites..."

  if [[ $EUID -eq 0 ]]; then
    log_error "This script should not be run as root. Please run without sudo."
    exit 1
  fi

  if ! sudo -v; then
    log_error "This script requires sudo privileges. Please run with a user that has sudo access."
    exit 1
  fi

  log_success "Prerequisites met."

  # Keep sudo alive in background
  log_info "Keeping sudo session alive in the background..."
  (
    while true; do
      sudo -n true
      sleep 60
      # Check if parent process is still running
      kill -0 "$$" 2>/dev/null || exit
    done
  ) &
  # Store the PID of the sudo loop for later killing in cleanup
  SUDO_LOOP_PID=$!
}

# Installs paru AUR helper if it's not already present.
install_paru_if_needed() {
  if command_exists paru; then
    log_success "paru is already installed."
    return 0
  fi

  log_info "paru not found. Installing paru..."

  run_command "sudo pacman -S --needed --noconfirm base-devel git" \
    "base-devel and git installed successfully." \
    "Failed to install base-devel or git. Exiting." || exit 1

  if [ -d "paru" ]; then
    log_warn "Existing 'paru' directory found. Removing it."
    run_command "rm -rf paru" "Removed existing paru directory." "Failed to remove paru directory."
  fi

  run_command "git clone https://aur.archlinux.org/paru.git" \
    "paru repository cloned." \
    "Failed to clone paru repository. Exiting." || exit 1

  (
    cd paru &&
      run_command "makepkg -si --noconfirm" \
        "paru installed successfully." \
        "Failed to install paru. Exiting."
  ) || exit 1
}

# Updates all system packages using paru.
update_system_packages() {
  log_info "Updating system packages..."
  if ! run_command "paru -Syu --noconfirm" "System packages updated." "Failed to update system packages. Continuing installation..."; then
    log_warn "System update failed, but continuing with installation. Some packages might be outdated."
  fi
}

# Generic function to install a list of packages.
# Args: $1 = array of packages to install (e.g., "${packages[@]}")
#       $2 = description for logging (e.g., "critical components")
install_packages() {
  local packages_array=("$@")
  local description="$2"
  local packages_list="${packages_array[*]}" # Convert array to space-separated string

  if [ ${#packages_array[@]} -eq 0 ]; then
    log_info "No $description to install."
    return 0
  fi

  log_info "Installing $description: $packages_list"
  if run_command "paru -S --needed --noconfirm --sudoloop ${packages_array[*]}" \
    "$description installed successfully." \
    "Failed to install $description."; then
    return 0
  else
    return 1
  fi
}

# Configures Bluetooth service.
configure_bluetooth() {
  log_info "Configuring Bluetooth service..."
  if ! lsmod | grep -q btusb; then
    run_command "sudo modprobe btusb" "btusb module loaded." "Failed to load btusb module." || true # Don't exit on failure
  fi

  run_command "sudo systemctl enable --now bluetooth.service" \
    "Bluetooth service enabled and started." \
    "Failed to enable or start bluetooth service." || true # Don't exit on failure
}

# Configures swww wallpaper daemon.
configure_swww() {
  log_info "Configuring swww wallpaper daemon..."
  run_command "systemctl --user enable --now swww.service" \
    "swww service enabled and started." \
    "Failed to enable or start swww service." || true # Don't exit on failure
}

# Prompts and installs optional programs.
install_optional_programs() {
  log_info "Checking for optional programs installation..."
  for program_entry in "${optional_programs[@]}"; do
    IFS=':' read -r program description <<<"$program_entry"
    if prompt_yes_no "Install $program? $description"; then
      if install_packages "$program" "optional program $program"; then
        log_success "$program installed."
      else
        log_error "Failed to install $program. Continuing..."
      fi
    else
      log_info "Skipping $program installation."
    fi
  done
}

# Handles Spicetify installation and configuration.
install_spicetify() {
  if ! prompt_yes_no "Install spicetify for Spotify customization? (Requires Spotify)"; then
    log_info "Skipping Spicetify installation."
    return 0
  fi

  if ! command_exists spotify; then
    log_info "Spotify not found. Attempting to install Spotify first..."
    if ! install_packages "spotify" "Spotify"; then
      log_error "Spotify installation failed. Skipping Spicetify."
      return 1
    fi
  else
    log_success "Spotify is already installed."
  fi

  log_info "Adjusting Spotify permissions for Spicetify..."
  run_command "sudo chmod 777 /opt/spotify -R" \
    "Spotify permissions adjusted." \
    "Failed to adjust Spotify permissions. Spicetify might not work correctly." || true

  log_info "Installing spicetify..."
  local spicetify_installer="install_spicetify.sh"
  run_command "curl -fsSL -o $spicetify_installer https://raw.githubusercontent.com/spicetify/cli/main/install.sh" \
    "Spicetify installer downloaded." \
    "Failed to download spicetify installer. Skipping spicetify." || return 1

  run_command "sh $spicetify_installer" \
    "Spicetify installed." \
    "Failed to install spicetify. Skipping spicetify configuration." || return 1

  log_info "Applying spicetify configuration..."
  run_command "spicetify backup apply" "Spicetify backup applied." "Failed to apply spicetify backup." || true
  run_command "spicetify apply" "Spicetify configuration applied." "Failed to apply spicetify configuration." || true

  log_info "Installing spicetify marketplace..."
  run_command "spicetify config extensions marketplace-v2@latest" "Marketplace extension configured." "Failed to configure marketplace extension." || true
  run_command "spicetify config custom_apps marketplace" "Marketplace custom app configured." "Failed to configure marketplace custom app." || true
  run_command "spicetify apply" "Marketplace configuration applied." "Failed to apply marketplace configuration." || true
}

# Installs tmux plugin manager (tpm).
install_tmux_tpm() {
  log_info "Installing tmux plugin manager (tpm)..."
  if [ ! -d ~/.tmux/plugins/tpm ]; then
    run_command "git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm" \
      "tmux plugin manager cloned successfully." \
      "Failed to clone tmux plugin manager." || true
  else
    log_success "tmux plugin manager already installed."
  fi
}

# ==============================================================================
# Cleanup Function
# ==============================================================================

# Function for cleanup
cleanup() {
  log_info "Cleaning up temporary files and processes..."
  [ -d "paru" ] && run_command "rm -rf paru" "Removed temporary 'paru' directory." "Failed to remove paru directory."
  [ -f "install_spicetify.sh" ] && run_command "rm -f install_spicetify.sh" "Removed temporary Spicetify installer." "Failed to remove Spicetify installer."

  # Kill the background sudo loop if it was started
  if [ -n "${SUDO_LOOP_PID:-}" ]; then
    if kill -0 "$SUDO_LOOP_PID" 2>/dev/null; then
      log_info "Terminating sudo keep-alive process (PID: $SUDO_LOOP_PID)..."
      kill "$SUDO_LOOP_PID" 2>/dev/null || true
    fi
  fi

  log_success "Cleanup completed."
}

# Set trap for cleanup on script exit (success or failure)
trap cleanup EXIT

# ==============================================================================
# Main Script Execution
# ==============================================================================

main() {
  log_info "Starting dotfiles installation script."
  log_info "This script will install packages used in your dotfiles. Critical components will be installed first, followed by optional programs."

  check_prerequisites
  install_paru_if_needed
  update_system_packages

  log_info "Installing critical components..."
  if ! install_packages "${critical_packages[@]}" "critical components"; then
    log_error "Failed to install critical packages. Exiting."
    exit 1
  fi

  log_info "Initializing system services..."
  configure_bluetooth
  configure_swww

  install_optional_programs
  install_spicetify
  install_tmux_tpm

  log_success "Installation process completed successfully!"
}

# Call the main function
main
