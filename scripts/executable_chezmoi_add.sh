#!/usr/bin/env bash

# Colors and formatting
green='\033[0;32m'
red='\033[0;31m'
yellow='\033[0;33m'
blue='\033[0;34m'
bold='\033[1m'
reset='\033[0m'

# Output functions
info() {
  printf "${blue}ℹ %s${reset}\n" "$1"
}

success() {
  printf "${green}✔ %s${reset}\n" "$1"
}

error() {
  printf "${red}✖ %s${reset}\n" "$1" >&2
}

warning() {
  printf "${yellow}⚠ %s${reset}\n" "$1"
}

# Check required command availability
check_requirements() {
  if ! command -v chezmoi &>/dev/null; then
    error "chezmoi is not installed. Please install it first."
    exit 1
  fi
}

# Main processing function
main() {
  check_requirements

  declare -A dirs=(
    [".config"]="$HOME/.config/nvim $HOME/.config/ghostty $HOME/.config/btop $HOME/.config/fish $HOME/.config/hypr $HOME/.config/waybar $HOME/.config/rio $HOME/.config/yazi $HOME/.config/zed $HOME/.config/zellij"
    ["Scripts"]="$HOME/scripts/"
  )

  # Initial re-add
  info "Performing initial re-add..."
  if chezmoi re-add; then
    success "Initial re-add completed successfully"
  else
    error "Initial re-add failed - continuing with existing state"
  fi

  # Check for locally deleted files
  info "Checking for locally deleted files..."
  local managed_files
  if ! managed_files=$(chezmoi managed); then
    error "Failed to list managed files"
    exit 1
  fi

  while IFS= read -r file; do
    if [[ ! -e "$HOME/$file" ]]; then
      warning "File ${bold}$file${reset} has been deleted locally"
      if chezmoi forget "$HOME/$file"; then
        success "Successfully forgotten ${bold}$file${reset}"
      else
        error "Failed to forget ${bold}$file${reset}"
      fi
    fi
  done <<< "$managed_files"

  # Add specified paths
  info "Processing directories..."
  for dir_name in "${!dirs[@]}"; do
    local patterns="${dirs[$dir_name]}"
    info "Processing ${bold}$dir_name${reset} group..."
    
    for pattern in $patterns; do
      info "  Adding pattern: ${bold}$pattern${reset}"
      if chezmoi add -- "$pattern"; then
        success "  Successfully added pattern: ${bold}$pattern${reset}"
      else
        error "  Failed to add pattern: ${bold}$pattern${reset}"
      fi
    done
  done

  # Check for changes
  info "Verifying managed files..."
  local updated_managed_files
  if ! updated_managed_files=$(chezmoi managed); then
    error "Failed to verify managed files"
    exit 1
  fi

  if [[ "$managed_files" != "$updated_managed_files" ]]; then
    success "Managed files changes detected:"
    diff --color=always \
      <(echo "$managed_files" | sort) \
      <(echo "$updated_managed_files" | sort) || true
  else
    info "No changes detected in managed files"
  fi

  success "Script completed successfully"
}

# Run main function and handle errors
main || {
  error "Script exited with errors"
  exit 1
}
