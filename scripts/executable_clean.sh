#!/bin/bash

# Exit on error, undefined variable, and pipe failures
set -eo pipefail

# --- Configuration ---
# Colors for output
declare -A colors=(
  [RED]='\033[0;31m'
  [GREEN]='\033[0;32m'
  [YELLOW]='\033[1;33m'
  [BLUE]='\033[0;34m'
  [PURPLE]='\033[0;35m'
  [CYAN]='\033[0;36m'
  [NC]='\033[0m' # No Color
)

# Dependencies required for the script
declare -a script_dependencies=("reflector" "bc") # paccache is part of pacman-contrib, handled specially

# List of common user cache directories to clean.
# Be careful with this list. While generally safe, some applications might
# store important data in their cache. Add or remove directories as needed.
declare -a user_cache_dirs_to_clean=(
  "$HOME/.cache/thumbnails"
  "$HOME/.cache/fontconfig"
  "$HOME/.cache/pip"
  "$HOME/.cache/electron"
  "$HOME/.cache/vscode"        # Example: Visual Studio Code cache
  "$HOME/.cache/mozilla"       # Example: Firefox cache (be cautious with browser caches)
  "$HOME/.cache/google-chrome" # Example: Chrome cache (be cautious with browser caches)
  # Add more specific application caches if you know they grow large and are safe to clear
)

# --- Utility Functions ---

# Function to print colored output
print_color() {
  local message="$1"
  local color_code="${colors[$2]:-${colors[NC]}}"
  printf "${color_code}%s${colors[NC]}\n" "$message"
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to execute a command and handle errors
execute_command() {
  local cmd_description="$1"
  shift # Remove the description, remaining arguments are the actual command
  print_color "Executing: $* ($cmd_description)" "CYAN"
  if "$@"; then
    print_color "$cmd_description completed successfully." "GREEN"
    return 0
  else
    local exit_code=$?
    print_color "Failed to execute $cmd_description. Command: '$*' Error code: $exit_code" "RED"
    return "$exit_code"
  fi
}

# Function to check if script is run as root
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    print_color "This script must be run as root. Attempting to elevate privileges with sudo..." "YELLOW"
    # Preserve arguments when re-executing with sudo
    exec sudo "$0" "$@"
  fi
  print_color "Running as root." "GREEN"
}

# Function to check and install dependencies
check_and_install_dependencies() {
  print_color "Checking for required dependencies..." "BLUE"
  local missing_deps=()

  # Check for core dependencies
  for dep in "${script_dependencies[@]}"; do
    if ! command_exists "$dep"; then
      missing_deps+=("$dep")
    fi
  done

  # Special handling for paccache, which is part of pacman-contrib
  if ! command_exists "paccache"; then
    print_color "paccache not found. It's part of pacman-contrib." "YELLOW"
    # Check if pacman-contrib is installed, if not, add it to missing_deps
    if ! pacman -Qs pacman-contrib >/dev/null 2>&1; then
      missing_deps+=("pacman-contrib")
    fi
  fi

  if [ ${#missing_deps[@]} -ne 0 ]; then
    print_color "Installing missing dependencies: ${missing_deps[*]}" "YELLOW"
    if ! execute_command "Dependency installation" pacman -S --noconfirm "${missing_deps[@]}"; then
      print_color "Failed to install one or more dependencies. Please install them manually and re-run the script." "RED"
      exit 1
    fi
  else
    print_color "All required dependencies are already installed." "GREEN"
  fi
}

# Function to get disk usage in bytes for the root filesystem
get_disk_usage() {
  # df -B1 outputs in 1-byte blocks. --output=used gets only the used space.
  # tail -n 1 gets the last line (the actual value).
  df -B1 --output=used / | tail -n 1
}

# Function to convert bytes to human-readable format
format_bytes() {
  local size=$1
  local units=("B" "KB" "MB" "GB" "TB" "PB") # Added PB for very large sizes
  local i=0
  # Use awk for floating point arithmetic for better precision than bc with small numbers
  while (($(echo "$size >= 1024" | bc -l) && i < ${#units[@]} - 1)); do
    size=$(echo "scale=2; $size / 1024" | bc -l)
    ((i++))
  done
  printf "%.2f %s" "$size" "${units[$i]}"
}

# Function to calculate and display space freed
show_space_freed() {
  local initial_usage=$1
  local final_usage=$2
  local space_freed=$((initial_usage - final_usage))

  local initial_human=$(format_bytes "$initial_usage")
  local final_human=$(format_bytes "$final_usage")
  local freed_human=$(format_bytes "$space_freed")

  print_color "\n--- Disk Space Summary ---" "BLUE"
  print_color "Initial Usage: $initial_human" "YELLOW"
  print_color "Final Usage: $final_human" "YELLOW"

  if ((space_freed > 0)); then
    print_color "Total Space Freed: $freed_human" "GREEN"
    # Calculate percentage of space freed
    local percentage=$(echo "scale=2; ($space_freed / $initial_usage) * 100" | bc -l)
    print_color "Percentage of Space Freed: ${percentage}%" "GREEN"
  else
    print_color "No significant space was freed or usage increased." "YELLOW"
  fi
  print_color "--------------------------" "BLUE"
}

# --- Cleaning Functions ---

# Clean pacman cache
clean_pacman_cache() {
  print_color "Choose pacman cache cleaning level:" "YELLOW"
  echo "1. Keep only installed and latest packages (pacman -Sc)"
  echo "2. Remove all cached packages (pacman -Scc - more aggressive)"
  echo "3. Go back"
  read -rp "Enter choice (1-3): " cache_choice

  case "$cache_choice" in
  1) execute_command "Pacman cache (safe)" pacman -Sc --noconfirm ;;
  2)
    read -rp "Are you sure you want to remove ALL cached packages? This can prevent downgrades and offline installations. (y/N): " confirm_scc
    if [[ "$confirm_scc" =~ ^[Yy]$ ]]; then
      execute_command "Pacman cache (aggressive)" pacman -Scc --noconfirm
    else
      print_color "Pacman -Scc cancelled." "YELLOW"
    fi
    ;;
  *) print_color "Skipping pacman cache cleaning." "YELLOW" ;;
  esac
}

# Remove unused packages (orphans)
remove_orphans() {
  print_color "Checking for orphaned packages..." "YELLOW"
  local orphans=$(pacman -Qtdq)
  if [ -n "$orphans" ]; then
    print_color "Found orphaned packages: $(echo "$orphans" | wc -l) packages." "YELLOW"
    read -rp "Do you want to remove these orphaned packages? (y/N): " confirm_orphans
    if [[ "$confirm_orphans" =~ ^[Yy]$ ]]; then
      execute_command "Removing orphaned packages" pacman -Rns $orphans --noconfirm
    else
      print_color "Skipping removal of orphaned packages." "YELLOW"
    fi
  else
    print_color "No orphaned packages found." "GREEN"
  fi
}

# Clean pacman cache, keeping only the latest version (using paccache)
clean_paccache_old_versions() {
  if command_exists "paccache"; then
    print_color "Cleaning old versions from pacman cache using paccache -rk1..." "YELLOW"
    execute_command "paccache -rk1" paccache -rk1
  else
    print_color "paccache command not found. Skipping old package version cleaning." "RED"
  fi
}

# Clean AUR helper cache (paru or yay)
clean_aur_cache() {
  local aur_helper=""
  for helper in paru yay; do
    if command_exists "$helper"; then
      aur_helper="$helper"
      break
    fi
  done

  if [ -n "$aur_helper" ]; then
    print_color "Cleaning $aur_helper cache and build files..." "YELLOW"
    # Rely on the AUR helper's built-in cache cleaning command
    execute_command "$aur_helper cache" "$aur_helper" -Cc --noconfirm
  else
    print_color "No supported AUR helper (paru or yay) found. Skipping AUR cache cleaning." "YELLOW"
  fi
}

# Clean journal logs
clean_journal_logs() {
  print_color "Cleaning journal logs to keep only last 7 days..." "YELLOW"
  execute_command "Journal logs cleanup" journalctl --vacuum-time=7d
}

# Clean user cache directories
clean_user_caches() {
  print_color "Cleaning selected user cache directories..." "YELLOW"
  if [ ${#user_cache_dirs_to_clean[@]} -eq 0 ]; then
    print_color "No specific user cache directories configured for cleaning." "YELLOW"
    return
  fi

  read -rp "This will remove files from the following directories: ${user_cache_dirs_to_clean[*]}. Are you sure? (y/N): " confirm_cache
  if [[ "$confirm_cache" =~ ^[Yy]$ ]]; then
    for dir in "${user_cache_dirs_to_clean[@]}"; do
      if [ -d "$dir" ]; then
        print_color "Cleaning $dir..." "CYAN"
        # The :? ensures the variable is set and prevents accidental `rm -rf /`
        # This removes contents *inside* the directory, not the directory itself
        execute_command "Cleaning $dir" rm -rf "${dir:?}"/*
      else
        print_color "$dir does not exist. Skipping." "YELLOW"
      fi
    done
    print_color "Selected user cache directories cleaning attempt complete." "GREEN"
  else
    print_color "Skipping user cache cleaning." "YELLOW"
  fi
}

# Clean temporary files using systemd-tmpfiles
clean_temp_files() {
  print_color "Cleaning temporary files and directories using systemd-tmpfiles --clean..." "YELLOW"
  # This command respects systemd-tmpfiles configuration, which is safer
  execute_command "Temporary files cleanup" systemd-tmpfiles --clean
}

# Remove old kernels
remove_old_kernels() {
  print_color "Checking for old kernels..." "YELLOW"
  local current_kernel_pkg=$(uname -r | sed 's/-.*//g' | sed 's/^/linux/')               # e.g., linux-zen, linux-lts
  local installed_kernels=$(pacman -Qoq linux | grep -E "^linux(-lts|-zen|-hardened)?$") # Get package names like 'linux', 'linux-lts'

  local old_kernels_to_remove=""
  for pkg in $installed_kernels; do
    if [[ "$pkg" != "$current_kernel_pkg" ]]; then
      old_kernels_to_remove+=" $pkg"
    fi
  done

  if [ -n "$old_kernels_to_remove" ]; then
    print_color "Found old kernels to remove: $old_kernels_to_remove" "YELLOW"
    read -rp "Do you want to remove these old kernel packages? (y/N): " confirm_old_kernels
    if [[ "$confirm_old_kernels" =~ ^[Yy]$ ]]; then
      execute_command "Removing old kernels" pacman -Rns $old_kernels_to_remove --noconfirm
    else
      print_color "Skipping removal of old kernels." "YELLOW"
    fi
  else
    print_color "No old kernels found to remove (or only the current one is installed)." "GREEN"
  fi
}

# Run fstrim for SSDs
run_fstrim() {
  print_color "Running fstrim -va for SSDs (this may take a moment)..." "YELLOW"
  # -v: verbose, -a: all mounted filesystems supporting TRIM
  execute_command "fstrim" fstrim -va
}

# Update mirror list with rating option
update_mirrors() {
  print_color "Updating mirror list by rating the fastest 20 HTTPS mirrors..." "YELLOW"
  execute_command "Mirror rating" reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
  print_color "Mirror list updated. Remember to run 'sudo pacman -Syy' to sync with new mirrors." "YELLOW"
}

# Hyprland specific (if any)
# Currently, there are no specific Hyprland caches that need regular manual cleaning
# beyond general system and user caches handled by the above functions.
# If you experience issues, you might consider clearing ~/.config/hypr/hyprland.conf.lock
# or similar, but this is rare and usually indicates a different problem.
hyprland_note() {
  print_color "Hyprland-specific cleaning: No typical manual cleaning required beyond general system/user caches." "BLUE"
}

# --- Menu System ---

# Display the main menu
display_menu() {
  print_color "\n--- Arch Linux Maintenance Menu ---" "BLUE"
  print_color "Select actions to perform (enter numbers separated by spaces, or 'all'):" "PURPLE"
  echo "1. Clean Pacman Cache (interactive: safe or aggressive)"
  echo "2. Remove Orphaned Packages"
  echo "3. Clean Old Versions from Pacman Cache (paccache -rk1)"
  echo "4. Clean AUR Helper Cache (paru/yay)"
  echo "5. Clean Journal Logs (last 7 days)"
  echo "6. Clean User Cache (selected directories)"
  echo "7. Clean Temporary Files (/tmp and others via systemd-tmpfiles)"
  echo "8. Remove Old Kernels"
  echo "9. Run fstrim (for SSDs)"
  echo "10. Update Pacman Mirrorlist (reflector)"
  echo "11. Hyprland Specific Note" # Added menu option for the note
  echo "0. Exit"
  print_color "-----------------------------------" "BLUE"
  read -rp "Enter your choice(s): " choices
  echo "$choices"
}

# --- Main Logic ---

main() {
  check_root "$@"                # Ensure script is run as root or elevate
  check_and_install_dependencies # Check and install necessary tools

  print_color "\nWelcome to the Arch Linux Maintenance Script!" "BLUE"

  local initial_usage=$(get_disk_usage)
  print_color "Initial disk usage: $(format_bytes "$initial_usage")" "YELLOW"

  local choices
  while true; do
    choices=$(display_menu)
    if [[ "$choices" =~ ^[Qq0]$ ]]; then
      print_color "Exiting script. Goodbye!" "BLUE"
      break
    fi

    local run_all=false
    if [[ "$choices" =~ ^[Aa][Ll][Ll]$ ]]; then
      run_all=true
      print_color "Running all cleaning operations." "YELLOW"
    fi

    for choice in $choices; do
      case "$choice" in
      1) clean_pacman_cache ;;
      2) remove_orphans ;;
      3) clean_paccache_old_versions ;;
      4) clean_aur_cache ;;
      5) clean_journal_logs ;;
      6) clean_user_caches ;;
      7) clean_temp_files ;;
      8) remove_old_kernels ;;
      9) run_fstrim ;;
      10) update_mirrors ;;
      11) hyprland_note ;; # Call the new function
      "all")               # Handled by run_all flag
        ;;
      *) print_color "Invalid choice: $choice. Please select a number from the menu." "RED" ;;
      esac
    done

    if ! $run_all; then
      read -rp "Press Enter to continue or 'q' to quit..." continue_choice
      if [[ "$continue_choice" =~ ^[Qq]$ ]]; then
        print_color "Exiting script. Goodbye!" "BLUE"
        break
      fi
    fi
  done

  # Final disk space summary
  local final_usage=$(get_disk_usage)
  show_space_freed "$initial_usage" "$final_usage"

  print_color "Maintenance script finished." "GREEN"
}

# Run the main function
main "$@"
