#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

declare -A scripts=(
  [" Unipicker"]="$HOME/.config/hypr/scripts/command-menu-scripts/unipicker.sh"
  [" Rofimoji"]="$HOME/.config/hypr/scripts/command-menu-scripts/rofimoji.sh"
)

main() {
  local chosen
  chosen=$(printf "%s\n" "${!scripts[@]}" | rofi -dmenu -i -p "Run Script")
  if [[ -n "$chosen" && -n "${scripts[$chosen]}" ]]; then
    local script_path="${scripts[$chosen]}"
    if [[ -x "$script_path" ]]; then
      "$script_path"
    elif [[ -f "$script_path" ]]; then
      bash "$script_path"
    else
      rofi -e "Script not found or not executable: $script_path"
      exit 1
    fi
  fi
}

main "$@"
