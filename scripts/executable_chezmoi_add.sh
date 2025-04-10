#!/usr/bin/env bash

# Version 3.4 - Safer path handling and improved whitespace processing

set -euo pipefail

# --- Configuration ---
CONFIG_FILE="${HOME}/.config/chezmoi-script.conf"
COLOR_SUPPORT=true # Detect terminal color support (can be disabled)
NUM_THREADS=4      # Number of threads for parallel processing
INTERACTIVE=true   # Enable/Disable interactive prompts

# --- Colors ---
if $COLOR_SUPPORT && [[ -t 1 ]] && [[ -n "${TERM:-}" ]] && [[ "${TERM}" != "dumb" ]]; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  GREEN=''
  RED=''
  YELLOW=''
  BLUE=''
  BOLD=''
  RESET=''
fi

# --- Output Functions ---
info() { printf "%bℹ %s%b\n" "${BLUE}" "$1" "${RESET}"; }
success() { printf "%b✔ %s%b\n" "${GREEN}" "$1" "${RESET}"; }
error() { printf "%b✖ %s%b\n" "${RED}" "$1" "${RESET}" >&2; }
warning() { printf "%b⚠ %s%b\n" "${YELLOW}" "$1" "${RESET}"; }

# --- Usage ---
usage() {
  cat <<EOF
Usage: ${0##*/} [OPTIONS]
Manage dotfiles with Chezmoi automation

Options:
  -n, --dry-run    Show what would happen without making changes
  -h, --help       Show this help message
  -c, --config     Use alternate config file
  -l, --list       Show current configuration
  -y, --yes        Automatically answer yes to forget prompts
  -i, --no-interactive  Disable interactive prompts
EOF
}

# --- Dependency Check ---
check_requirements() {
  if ! command -v chezmoi &>/dev/null; then
    error "Chezmoi is required but not installed."
    exit 1
  fi
}

# --- Path Expansion ---
expand_path() {
  local path="$1"
  # Expand leading ~ to $HOME
  path="${path/#\~/$HOME}"
  # Replace ${VAR} with their values
  while [[ "$path" =~ (\$\{([a-zA-Z_][a-zA-Z_0-9]*)\}) ]]; do
    local var_name="${BASH_REMATCH[2]}"
    local var_value="${!var_name:-}"
    path="${path//${BASH_REMATCH[1]}/$var_value}"
  done
  echo "$path"
}

# --- Configuration Loading ---
load_config() {
  declare -gA config_groups

  if [[ ! -f "$CONFIG_FILE" ]]; then
    warning "Config file not found: ${CONFIG_FILE}. Creating default."
    cat <<EOF >"$CONFIG_FILE"
# Chezmoi Manager Configuration
# Add groups using the format:
# [group-name]
# /path/to/item1
# /path/to/item2

[dot-files]
\${HOME}/.bashrc
\${HOME}/.zshrc
\${HOME}/.gitconfig

[scripts]
\${HOME}/scripts

[config-dirs]
\${HOME}/.config/nvim
\${HOME}/.config/fish
\${HOME}/.config/btop
EOF
  fi

  # Parse config
  local current_group=""
  while IFS= read -r line; do
    # Remove comments and trim whitespace
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}" # Trim leading
    line="${line%"${line##*[![:space:]]}"}" # Trim trailing

    if [[ -z "$line" ]]; then continue; fi
    if [[ "$line" =~ ^\[(.*)\]$ ]]; then
      current_group="${BASH_REMATCH[1]}"
      config_groups["$current_group"]=""
    else
      config_groups["$current_group"]+="$line"$'\n'
    fi
  done <"$CONFIG_FILE"
}

# --- Display Configuration ---
show_config() {
  info "Current Configuration:"
  for group in "${!config_groups[@]}"; do
    printf "%b${BOLD}%s${RESET}:\n" "${BLUE}" "$group"
    while IFS= read -r path; do
      if [[ -n "$path" ]]; then
        expanded_path=$(expand_path "$path")
        printf "  %s\n" "$expanded_path"
      fi
    done <<<"${config_groups[$group]}"
  done
}

# --- Parallel Add ---
parallel_add() {
  local patterns=("$@")
  local add_flags=()
  [[ -n "$DRYRUN_FLAG" ]] && add_flags+=("$DRYRUN_FLAG")

  printf "%s\n" "${patterns[@]}" | xargs -P "$NUM_THREADS" -I{} bash -c '
    expanded_pattern="{}"
    cmd_args=("chezmoi" "add")
    [[ ${#add_flags[@]} -gt 0 ]] && cmd_args+=("${add_flags[@]}")
    cmd_args+=("$expanded_pattern")
    
    if "${cmd_args[@]}"; then
      printf "%b  Added: %s%b\n" "'${GREEN}'" "$expanded_pattern" "'${RESET}'"
    else
      printf "%b  Failed: %s%b\n" "'${RED}'" "$expanded_pattern" "'${RESET}'" >&2
      exit 1
    fi
  ' _
}

# --- Handle Deleted Files ---
handle_deleted_files() {
  info "Checking for Locally Deleted Files..."
  local managed_files
  managed_files=$(chezmoi managed 2>/dev/null) || {
    error "Failed to get managed files list."
    return 1
  }

  local forget_list=()
  while IFS= read -r file; do
    expanded_file=$(expand_path "$file")

    if [[ ! -e "${expanded_file}" ]]; then
      if [[ -n "$AUTO_CONFIRM" ]] || ! $INTERACTIVE; then
        forget_list+=("$expanded_file")
        warning "File missing: ${BOLD}${file}${RESET} - Auto-forgetting."
      else
        read -r -p "Forget ${BOLD}${file}${RESET}? [y/N] " yn
        case "$yn" in
        [Yy]*) forget_list+=("$expanded_file") ;;
        *) info "Skipping ${file}." ;;
        esac
      fi
    fi
  done <<<"$managed_files"

  if [[ ${#forget_list[@]} -gt 0 ]]; then
    if [[ -n "$DRYRUN_FLAG" ]]; then
      success "Would forget ${#forget_list[@]} files:"
      printf "  %s\n" "${forget_list[@]}"
    else
      chezmoi forget "${forget_list[@]}" && success "Forgot ${#forget_list[@]} files." || error "Failed to forget files."
    fi
  else
    success "No files to forget."
  fi
}

# --- Main Function ---
main() {
  local DRYRUN_FLAG=""
  local SHOW_CONFIG=false
  local AUTO_CONFIRM=""

  # --- Option Parsing ---
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -n | --dry-run)
      DRYRUN_FLAG="--dry-run"
      shift
      ;;
    -c | --config)
      CONFIG_FILE="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    -l | --list)
      SHOW_CONFIG=true
      shift
      ;;
    -y | --yes)
      AUTO_CONFIRM=true
      shift
      ;;
    -i | --no-interactive)
      INTERACTIVE=false
      shift
      ;;
    *)
      error "Invalid option: $1"
      usage
      exit 1
      ;;
    esac
  done

  # --- Initialization ---
  check_requirements
  load_config

  if $SHOW_CONFIG; then
    show_config
    exit 0
  fi

  info "Starting Chezmoi management (Dry Run: ${DRYRUN_FLAG:--})"
  info "Processing ${BOLD}${#config_groups[@]}${RESET} groups"

  # --- Initial Re-add ---
  if [[ -z "$DRYRUN_FLAG" ]]; then
    chezmoi re-add && success "Initial re-add completed." || error "Initial re-add failed."
  fi

  # --- Handle Deleted Files ---
  handle_deleted_files || error "Failed to handle deleted files."

  # --- Process Groups ---
  for group_name in "${!config_groups[@]}"; do
    info "Processing ${BOLD}${group_name}${RESET} group..."
    local patterns=()
    while IFS= read -r path; do
      if [[ -n "$path" ]]; then
        expanded_path=$(expand_path "$path")
        patterns+=("$expanded_path")
      fi
    done <<<"${config_groups[$group_name]}"

    if ((${#patterns[@]} == 0)); then
      warning "Empty group: ${group_name}."
      continue
    fi

    if [[ -n "$DRYRUN_FLAG" ]]; then
      success "Dry-run would add:"
      printf "  %s\n" "${patterns[@]}"
      continue
    fi

    parallel_add "${patterns[@]}" || error "Failed to process some items in ${group_name}."
    success "Group ${group_name} processed successfully."
  done

  # --- Final Verification ---
  info "Final State Verification..."
  if [[ -n "$DRYRUN_FLAG" ]]; then
    success "Dry-run complete - no changes made."
    exit 0
  fi

  local updated_files
  updated_files=$(chezmoi managed 2>/dev/null) || {
    error "Failed to verify final state."
    exit 1
  }

  diff --color=always <(echo "$managed_files" | sort) <(echo "$updated_files" | sort) || true

  success "Operation completed. Managed files: $(wc -l <<<"$updated_files")"
}

main "$@"
