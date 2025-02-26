#!/bin/bash

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
  else
    print_color "Failed to install $1." "RED"
    return 1
  fi
}

# Function to show progress
show_progress() {
  local duration=$1
  local sleep_interval=0.1
  local progress=0
  local bar_length=40

  while [ $progress -lt 100 ]; do
    local filled=$((progress * bar_length / 100))
    local empty=$((bar_length - filled))
    printf "\rProgress: [%s%s] %d%%" "$(printf '#%.0s' $(seq 1 $filled))" "$(printf ' %.0s' $(seq 1 $empty))" "$progress"
    sleep $sleep_interval
    progress=$((progress + 1))
    [ $progress -eq 100 ] && break
  done
  echo
}

# Function for cleanup
cleanup() {
  print_color "Cleaning up..." "YELLOW"
  # Add cleanup tasks here
  print_color "Cleanup completed." "GREEN"
}

# Set trap for cleanup
trap cleanup EXIT

# Main script
print_color "This script will install packages used in your dotfiles. It will install critical components first, and then you will be able to choose additional, non-critical programs." "BLUE"

# Check if script is run with sudo
if [[ $EUID -eq 0 ]]; then
   print_color "This script should not be run as root. Please run without sudo." "RED"
   exit 1
fi

# Check if user has sudo privileges
if ! sudo -v; then
  print_color "This script requires sudo privileges. Please run with a user that has sudo access." "RED"
  exit 1
fi

# Check if paru is installed
if ! command_exists paru; then
  print_color "Installing paru..." "YELLOW"
  if ! sudo pacman -S --needed --noconfirm base-devel; then
    print_color "Failed to install base-devel. Exiting." "RED"
    exit 1
  fi
  git clone https://aur.archlinux.org/paru.git
  cd paru || exit
  if ! makepkg -si --noconfirm; then
    print_color "Failed to install paru. Exiting." "RED"
    exit 1
  fi
  cd .. || exit
  rm -rf paru
else
  print_color "paru is already installed." "GREEN"
fi

print_color "Installing critical components..." "YELLOW"
critical_packages=(
  ttf-font-awesome noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd
  swww bluez bluez-utils blueman curl starship superfile texlive go npm neovim eza zoxide
)
if ! paru -S --needed --noconfirm "${critical_packages[@]}"; then
  print_color "Failed to install critical packages. Exiting." "RED"
  exit 1
fi

print_color "Finished installing critical components." "GREEN"
print_color "Initializing system services of newly installed packages." "BLUE"

# Load btusb module if not already loaded
if ! lsmod | grep -q btusb; then
  print_color "Loading btusb module..." "YELLOW"
  if ! sudo modprobe btusb; then
    print_color "Failed to load btusb module." "RED"
  fi
fi

print_color "Starting and enabling bluetooth service..." "YELLOW"
if ! sudo systemctl enable --now bluetooth.service; then
  print_color "Failed to enable bluetooth service." "RED"
fi

print_color "Enabling swww wallpaper daemon..." "YELLOW"
if ! systemctl --user enable --now swww.service; then
  print_color "Failed to enable swww service." "RED"
fi

declare -A programs=(
  ["zed"]="A high-performance, multiplayer code editor from the creators of Atom and Tree-sitter"
  ["neofetch"]="A command-line system information tool"
  ["htop"]="An interactive process viewer"
  ["vesktop"]="A discord client with deep customisation through plugins, and offering better performance on linux"
  # Add more programs here
)

for program in "${!programs[@]}"; do
  description="${programs[$program]}"
  print_color "Would you like to install $program? $description (y/n): " "YELLOW"
  read -r response
  case $response in
    [Yy]*)
      if ! install_package "$program"; then
        print_color "Failed to install $program. Continuing with next package." "RED"
      fi
      ;;
    [Nn]*)
      print_color "Skipping $program installation." "RED"
      ;;
    *)
      print_color "Invalid response. Skipping $program installation." "RED"
      ;;
  esac
  echo
done

print_color "Would you like to install spicetify? A tool which adds plugin support for Spotify (requires Spotify to be installed) (y/n)" "YELLOW"
read -r response
case $response in
  [Yy]*)
    print_color "Installing Spotify and spicetify..." "BLUE"
    if ! install_package "spotify"; then
      print_color "Failed to install Spotify. Skipping spicetify installation." "RED"
    else
      curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
      sudo chmod a+wr /opt/spotify
      sudo chmod a+wr /opt/spotify/Apps -R
      spicetify backup apply
    fi
    ;;
  [Nn]*)
    print_color "Skipping spicetify installation." "RED"
    ;;
  *)
    print_color "Invalid response. Skipping spicetify installation." "RED"
    ;;
esac

print_color "Installation process completed." "GREEN"
show_progress 5

