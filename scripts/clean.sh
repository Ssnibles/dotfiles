#!/bin/bash

set -eo pipefail  # Exit on error, undefined var, and pipe failures

# Colors for output
declare -A colors=(
    [RED]='\033[0;31m'
    [GREEN]='\033[0;32m'
    [YELLOW]='\033[1;33m'
    [BLUE]='\033[0;34m'
    [NC]='\033[0m'  # No Color
)

# Function to print colored output
print_color() {
    printf "${colors[$2]:-${colors[NC]}}%s${colors[NC]}\n" "$1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to execute a command and handle errors
execute_command() {
    if "$@"; then
        print_color "$1 completed successfully." "GREEN"
    else
        print_color "Failed to execute $1. Error code: $?" "RED"
        return 1
    fi
}

# Function to check if script is run as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        print_color "This script must be run as root. Requesting sudo privileges..." "YELLOW"
        exec sudo "$0" "$@"
    fi
}

# Function to check and install dependencies
check_and_install_dependencies() {
    local dependencies=("reflector" "paccache" "bc")
    local missing_deps=()

    for dep in "${dependencies[@]}"; do
        if ! command_exists "$dep"; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_color "Installing missing dependencies: ${missing_deps[*]}" "YELLOW"
        for dep in "${missing_deps[@]}"; do
            case "$dep" in
                "paccache")
                    execute_command pacman -S --noconfirm pacman-contrib
                    ;;
                *)
                    execute_command pacman -S --noconfirm "$dep"
                    ;;
            esac
        done
    else
        print_color "All dependencies are already installed." "GREEN"
    fi
}

# Function to get disk usage in bytes
get_disk_usage() {
    df --output=used / | tail -n 1
}

# Function to convert bytes to human-readable format
format_bytes() {
    local size=$1
    local units=("B" "KB" "MB" "GB" "TB")
    local i=0
    while (( size >= 1024 && i < ${#units[@]} - 1 )); do
        size=$(echo "scale=2; $size / 1024" | bc)
        ((i++))
    done
    printf "%.2f %s" $size "${units[$i]}"
}

# Function to calculate and display space freed
show_space_freed() {
    local initial_usage=$1
    local final_usage=$2
    local space_freed=$((initial_usage - final_usage))

    local initial_human=$(format_bytes $initial_usage)
    local final_human=$(format_bytes $final_usage)
    local freed_human=$(format_bytes $space_freed)

    print_color "Disk Space Summary:" "BLUE"
    print_color "Initial Usage: $initial_human" "YELLOW"
    print_color "Final Usage: $final_human" "YELLOW"
    print_color "Total Space Freed: $freed_human" "GREEN"

    # Calculate percentage of space freed
    local percentage=$(echo "scale=2; ($space_freed / $initial_usage) * 100" | bc)
    print_color "Percentage of Space Freed: ${percentage}%" "GREEN"

    # Estimate time saved (assuming 1GB takes 1 minute to accumulate)
    local time_saved=$(echo "scale=2; $space_freed / (1024 * 1024 * 1024)" | bc)
    print_color "Estimated Time Saved: ${time_saved} minutes" "GREEN"
}

# Function to clean the system
clean_system() {
    # Clean pacman cache
    print_color "Cleaning pacman cache..." "YELLOW"
    execute_command pacman -Sc --noconfirm

    # Remove unused packages (orphans)
    print_color "Removing orphaned packages..." "YELLOW"
    local orphans=$(pacman -Qtdq)
    if [ -n "$orphans" ]; then
        execute_command pacman -Rns $orphans --noconfirm
    else
        print_color "No orphaned packages found." "GREEN"
    fi

    # Clean pacman cache, keeping only the latest version
    print_color "Cleaning old versions from pacman cache..." "YELLOW"
    execute_command paccache -rk1

    # Clean AUR helper cache (paru or yay)
    local aur_helper=""
    for helper in paru yay; do
        if command_exists "$helper"; then
            aur_helper="$helper"
            break
        fi
    done

    if [ -n "$aur_helper" ]; then
        print_color "Cleaning $aur_helper cache..." "YELLOW"
        execute_command $aur_helper -Sc --noconfirm

        print_color "Cleaning $aur_helper build files..." "YELLOW"
        execute_command rm -rf ~/.cache/$aur_helper/
    else
        print_color "No supported AUR helper (paru or yay) found. Skipping AUR cache cleaning." "YELLOW"
    fi

    # Clean journal logs
    print_color "Cleaning journal logs..." "YELLOW"
    execute_command journalctl --vacuum-time=7d

    # Clean user cache
    print_color "Cleaning user cache..." "YELLOW"
    execute_command find /home -type d -name ".cache" -exec rm -rf {}/* \;

    # Clean thumbnail cache
    print_color "Cleaning thumbnail cache..." "YELLOW"
    execute_command find /home -type d -name ".thumbnails" -exec rm -rf {}/* \;

    # Clean temporary files
    print_color "Cleaning temporary files..." "YELLOW"
    execute_command find /tmp -type f -atime +10 -delete

    # Clean old kernels
    print_color "Cleaning old kernels..." "YELLOW"
    local current_kernel=$(uname -r | sed 's/-.*//g')
    local old_kernels=$(pacman -Q linux | grep -v "$current_kernel" | awk '{print $1}')
    if [ -n "$old_kernels" ]; then
        execute_command pacman -Rns $old_kernels --noconfirm
    else
        print_color "No old kernels found." "GREEN"
    fi
}

# Function to update mirror list with rating option
update_mirrors() {
    print_color "Rating mirrors..." "YELLOW"
    execute_command reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
}

# Main function
main() {
    check_root "$@"

    print_color "Welcome to the Arch Linux Maintenance Script" "BLUE"

    check_and_install_dependencies

    local initial_usage=$(get_disk_usage)

    read -p "Would you like to rate your mirrors? (y/n): " rate_choice

    if [[ "$rate_choice" =~ ^[Yy]$ ]]; then
        update_mirrors
    else
        print_color "Skipping mirror rating." "GREEN"
    fi

    clean_system

    # Final message
    print_color "Operation complete!" "GREEN"
    print_color "Your system has been maintained." "YELLOW"

    # Display disk space saved
    local final_usage=$(get_disk_usage)
    show_space_freed $initial_usage $final_usage
}

# Run the main function
main "$@"
