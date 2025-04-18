#!/usr/bin/env bash

set -euo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/chezmoi-manage.conf"
COLOR_SUPPORT=true

# --- Colors ---
if $COLOR_SUPPORT && [[ -t 1 ]] && [[ -n "${TERM:-}" ]] && [[ "${TERM}" != "dumb" ]]; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  GREEN='' RED='' YELLOW='' BLUE='' BOLD='' RESET=''
fi

# --- Output Functions ---
info() { printf "%bℹ %s%b\n" "${BLUE}" "$1" "${RESET}"; }
success() { printf "%b✔ %s%b\n" "${GREEN}" "$1" "${RESET}"; }
error() { printf "%b✖ %s%b\n" "${RED}" "$1" "${RESET}" >&2; }
warning() { printf "%b⚠ %s%b\n" "${YELLOW}" "$1" "${RESET}"; }

# --- Helpers ---
die() {
  error "$1"
  exit 1
}

expand_path() {
  local path="$1"
  path="${path/#\~/$HOME}"
  if [[ "$path" != /* ]] && [[ "$path" != .* ]]; then
    path="${SCRIPT_DIR}/${path}"
  fi
  realpath -m "$path"
}

# --- Config Handling ---
load_config() {
  declare -gA config_groups
  local current_group=""

  [[ -f "$CONFIG_FILE" ]] || die "Config file not found: ${CONFIG_FILE}"

  while IFS= read -r line; do
    line="${line%%#*}"
    line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    [[ -z "$line" ]] && continue

    if [[ "$line" =~ ^\[(.*)\]$ ]]; then
      current_group="${BASH_REMATCH[1]}"
      config_groups["$current_group"]=""
    elif [[ -n "$current_group" ]]; then
      expanded_path=$(expand_path "$line")
      config_groups["$current_group"]+="${expanded_path}"$'\n'
    fi
  done <"$CONFIG_FILE"
}

# --- Main Logic ---
manage_group() {
  local group="$1"
  local dry_run="${2:-false}"
  local patterns=()

  while IFS= read -r path; do
    [[ -n "$path" ]] && patterns+=("$path")
  done <<<"${config_groups[$group]}"

  if [[ "${#patterns[@]}" -eq 0 ]]; then
    error "Empty group: ${group}"
    return 1
  fi

  if "$dry_run"; then
    info "Dry-run would process group: ${BOLD}${group}"
    printf "  %s\n" "${patterns[@]/#$HOME/\~}"
    return 0
  fi

  info "Processing group: ${BOLD}${group}"
  for path in "${patterns[@]}"; do
    local display_path="${path/#$HOME/\~}"

    if [[ "$path" == *"/.git"* ]]; then
      warning "Skipping .git path: ${BOLD}${display_path}${RESET}"
      continue
    fi

    if [[ ! -e "$path" ]]; then
      warning "Removing missing file: ${BOLD}${display_path}${RESET}"
      chezmoi forget "$path" && success "Forgot: ${display_path}" || error "Failed to forget: ${display_path}"
      continue
    fi

    chezmoi add "$path" && success "Added: ${display_path}" || error "Failed: ${display_path}"
  done
}

main() {
  local dry_run=false show_config=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
    -n | --dry-run)
      dry_run=true
      shift
      ;;
    -l | --list)
      show_config=true
      shift
      ;;
    -h | --help)
      cat <<EOF
Usage: ${0##*/} [OPTIONS]
Manage dotfiles with Chezmoi using ${CONFIG_FILE}

Options:
  -n, --dry-run  Simulate changes
  -l, --list     Show configuration
  -h, --help     Show this help
EOF
      exit 0
      ;;
    *) die "Invalid option: $1" ;;
    esac
  done

  command -v chezmoi >/dev/null || die "Chezmoi not installed"
  load_config

  if "$show_config"; then
    info "Configuration groups from ${CONFIG_FILE}:"
    for group in "${!config_groups[@]}"; do
      printf "%b%s%b\n" "${BOLD}" "$group" "${RESET}"
      while IFS= read -r path; do
        [[ -n "$path" ]] && echo "  ${path/#$HOME/\~}"
      done <<<"${config_groups[$group]}"
    done
    exit 0
  fi

  "$dry_run" && info "Starting dry run"

  for group in "${!config_groups[@]}"; do
    manage_group "$group" "$dry_run" || continue
  done

  success "Operation completed"
}

main "$@"
