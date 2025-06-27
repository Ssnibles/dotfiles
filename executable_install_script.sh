#!/usr/bin/env bash
set -euo pipefail

# Colors for output
declare -A colors=(
  [RED]='\033[0;31m'
  [GREEN]='\033[0;32m'
  [YELLOW]='\033[1;33m'
  [BLUE]='\033[0;34m'
  [NC]='\033[0m' # No Color
)

# Function to print colored output
print_color() {
  printf "${colors[$2]:-${colors[NC]}}%s${colors[NC]}\n" "$1"
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to install a package
install_package() {
  if paru -S --needed --noconfirm "$1"; then
    print_color "$1 installed successfully." "GREEN"
    return 0
  else
    print_color "Failed to install $1." "RED"
    return 1
  fi
}

# Function for cleanup
cleanup() {
  print_color "Cleaning up..." "YELLOW"
  [ -d "paru" ] && rm -rf paru
  [ -f "install_spicetify.sh" ] && rm -f install_spicetify.sh
  print_color "Cleanup completed." "GREEN"
}

# Set trap for cleanup
trap cleanup EXIT

# Main script
print_color "This script will install packages used in your dotfiles. Critical components will be installed first, followed by optional programs." "BLUE"

# Check if script is run with sudo
if [[ $EUID -eq 0 ]]; then
  print_color "This script should not be run as root. Please run without sudo." "RED"
  exit 1
fi

# Check and maintain sudo privileges
print_color "Checking sudo privileges..." "YELLOW"
if ! sudo -v; then
  print_color "This script requires sudo privileges. Please run with a user that has sudo access." "RED"
  exit 1
fi

# Keep sudo alive in background
(
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" 2>/dev/null || exit
  done
) &

# Install paru if not available
if ! command_exists paru; then
  print_color "Installing paru..." "YELLOW"
  sudo pacman -S --needed --noconfirm base-devel git || {
    print_color "Failed to install base-devel. Exiting." "RED"
    exit 1
  }

  [ -d "paru" ] && rm -rf paru
  git clone https://aur.archlinux.org/paru.git || {
    print_color "Failed to clone paru repository. Exiting." "RED"
    exit 1
  }

  (cd paru && makepkg -si --noconfirm) || {
    print_color "Failed to install paru. Exiting." "RED"
    exit 1
  }
fi

# Update system packages
print_color "Updating system packages..." "YELLOW"
paru -Syu --noconfirm || {
  print_color "Failed to update system packages. Continuing installation..." "YELLOW"
}

# Install critical components
print_color "Installing critical components..." "YELLOW"
critical_packages=(
  ttf-font-awesome noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd ttf-roboto
  swww bluez bluez-utils blueman curl starship go npm neovim eza zoxide lazygit tmux
  ghostty tree-sitter-cli texlive-latex rust luarocks imagemagick pet-bin rose-pine-hyprcursor texlive-latexextra
  hyprlock waybar
)

if ! paru -S --needed --noconfirm --sudoloop "${critical_packages[@]}"; then
  print_color "Failed to install critical packages. Exiting." "RED"
  exit 1
fi

# Initialize services
print_color "Initializing system services..." "BLUE"

# Bluetooth setup
if ! lsmod | grep -q btusb; then
  print_color "Loading btusb module..." "YELLOW"
  sudo modprobe btusb || print_color "Failed to load btusb module." "RED"
fi

print_color "Starting bluetooth service..." "YELLOW"
sudo systemctl enable --now bluetooth.service || print_color "Failed to enable bluetooth service." "RED"

# swww service
print_color "Starting wallpaper daemon..." "YELLOW"
systemctl --user enable --now swww.service || print_color "Failed to enable swww service." "RED"

# Optional programs
declare -a programs=(
  "zed:A high-performance, multiplayer code editor from the creators of Atom and Tree-sitter"
  "neofetch:Command-line system information tool"
  "htop:Interactive process viewer"
  "vesktop:Customizable Discord client with Linux optimizations"
)

for program_entry in "${programs[@]}"; do
  IFS=':' read -r program description <<<"$program_entry"
  print_color "Install $program? $description (y/N): " "YELLOW"
  read -r -n 1 response
  echo
  if [[ "$response" =~ ^[Yy]$ ]]; then
    install_package "$program" || true
  else
    print_color "Skipping $program installation." "BLUE"
  fi
done

# Spicetify installation
print_color "Install spicetify for Spotify customization? (Requires Spotify) (y/N): " "YELLOW"
read -r -n 1 response
echo
if [[ "$response" =~ ^[Yy]$ ]]; then
  if ! command_exists spotify; then
    if install_package "spotify"; then
      print_color "Adjusting Spotify permissions for Spicetify..." "YELLOW"
      sudo chmod 777 /opt/spotify -R
    else
      print_color "Spotify installation failed. Skipping spicetify." "RED"
      exit 1
    fi
  fi

  print_color "Installing spicetify..." "BLUE"
  curl -fsSL -o install_spicetify.sh https://raw.githubusercontent.com/spicetify/cli/main/install.sh || {
    print_color "Failed to download spicetify installer." "RED"
    exit 1
  }
  sh install_spicetify.sh || {
    print_color "Failed to install spicetify." "RED"
    exit 1
  }

  # Apply spicetify configuration
  print_color "Applying spicetify configuration..." "YELLOW"
  spicetify backup apply || print_color "Failed to apply spicetify backup." "RED"
  spicetify apply || print_color "Failed to apply spicetify configuration." "RED"

  # Install marketplace
  print_color "Installing spicetify marketplace..." "YELLOW"
  spicetify config extensions marketplace-v2@latest
  spicetify config custom_apps marketplace
  spicetify apply || print_color "Failed to apply marketplace configuration." "RED"
fi

# Install tmux plugin manager
print_color "Installing tmux plugin manager..." "YELLOW"
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || {
    print_color "Failed to clone tmux plugin manager." "RED"
  }
else
  print_color "tmux plugin manager already installed." "GREEN"
fi

print_color "Installation process completed successfully!" "GREEN"
