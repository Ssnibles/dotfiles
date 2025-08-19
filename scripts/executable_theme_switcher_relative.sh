#!/usr/bin/env bash

# This script provides a simple and efficient theme switcher for Hyprland and various applications.
# It works by creating symlinks to a desired theme's configuration files.

# --- Script Configuration and Error Handling ---
# Exit immediately if a command exits with a non-zero status.
set -e
# Exit if an undeclared variable is used.
set -u
# Exit if any command in a pipeline fails.
set -o pipefail

# --- Global Variables ---
LAST_APPLIED_THEME_FILE="$HOME/.cache/current_theme"
DEFAULT_WALLPAPERS_DIR="$HOME/wallpapers/themed"
DYNAMIC_WALLPAPERS_DIR="$HOME/wallpapers/dynamic"

# --- Configuration: Themes and Application Settings ---
# Define your theme options. The keys are used for theme selection and file names.
declare -A THEME_CONFIG=(
  ["rose-pine"]="A dark, vibrant theme with rosy accents."
  ["rose-pine-moon"]="A darker, more subdued rose-pine variant."
  ["rose-pine-dawn"]="A bright, refreshing rose-pine variant."
  ["matugen"]="Generate theme from wallpaper using Matugen."
)

# Define specific settings for applications that are NOT managed via symlinks.
declare -A GTK_THEMES=(
  ["rose-pine"]="Default"
  ["rose-pine-moon"]="Dracula"
  ["rose-pine-dawn"]="Adwaita-light"
  ["matugen"]="Adwaita"
)

declare -A ICON_THEMES=(
  ["rose-pine"]="Papirus-Dark"
  ["rose-pine-moon"]="Adwaita"
  ["rose-pine-dawn"]="Adwaita"
  ["matugen"]="Adwaita"
)

declare -A CURSOR_THEMES=(
  ["rose-pine"]="Bibata-Modern-Rose"
  ["rose-pine-moon"]="Adwaita"
  ["rose-pine-dawn"]="Adwaita"
  ["matugen"]="Bibata-Modern-Rose"
)

# Define whether a theme is 'light' or 'dark' for system-wide color-scheme preference.
declare -A THEME_MODE=(
  ["rose-pine"]="dark"
  ["rose-pine-moon"]="dark"
  ["rose-pine-dawn"]="light"
  ["matugen"]="dark"
)

# Consolidated Symlink Configuration for applications.
# Format: "app_name"="active_symlink_path:base_theme_dir:theme_file_extension"
declare -A SYMLINKED_APPS=(
  ["hyprland"]="$HOME/.config/hypr/active_theme.conf:$HOME/.config/hypr/themes:conf"
  ["ghostty"]="$HOME/.config/ghostty/active_theme.conf:$HOME/.config/ghostty/themes:conf"
  ["waybar"]="$HOME/.config/waybar/active_theme.css:$HOME/.config/waybar/themes:css"
  ["nvim"]="$HOME/.config/nvim/lua/active_theme.lua:$HOME/.config/nvim/lua/themes:lua"
  ["rofi"]="$HOME/.config/rofi/active_theme.rasi:$HOME/.config/rofi/themes:rasi"
  ["btop"]="$HOME/.config/btop/active_theme.theme:$HOME/.config/btop/themes:theme"
  ["mako"]="$HOME/.config/mako/active_theme:$HOME/.config/mako/themes:"
  ["fzf"]="$HOME/.config/fish/active_fzf_theme.fish:$HOME/.config/fish/fzf-themes:fish"
  ["fish"]="$HOME/.config/fish/themes/active_theme.theme:$HOME/.config/fish/themes:theme"
  ["yazi"]="$HOME/.config/yazi/active_theme.toml:$HOME/.config/yazi/themes:toml"
)

# --- Helper Functions ---

# Function to print error messages and exit
die() {
  echo "Error: $1" >&2
  exit 1
}

# Function to check for required commands
check_command() {
  local cmd="$1"
  command -v "$cmd" &>/dev/null || die "Required command '$cmd' not found. Please install it."
}

# Safely creates or updates a symlink
create_active_symlink() {
  local target_file_abs="$1"
  local symlink_path_abs="$2"
  local symlink_dir

  symlink_dir=$(dirname "$symlink_path_abs")

  mkdir -p "$symlink_dir" || die "Could not create directory for symlink: $symlink_dir"

  # Check if target file exists.
  if [[ ! -e "$target_file_abs" ]]; then
    echo "Warning: Target file for symlink does not exist: $target_file_abs. Skipping symlink creation." >&2
    return 1
  fi

  # Remove existing symlink or regular file.
  if [[ -e "$symlink_path_abs" ]]; then
    rm -rf "$symlink_path_abs" || echo "Warning: Could not remove old symlink/file $symlink_path_abs" >&2
  fi

  # Create the new symlink. Use a subshell to manage directories.
  (
    cd "$symlink_dir" || die "Could not change directory to $symlink_dir."
    ln -s "$(realpath --relative-to="$symlink_dir" "$target_file_abs")" "$(basename "$symlink_path_abs")"
  ) || die "Could not create symlink."

  echo "Symlinked '$symlink_path_abs' to '$target_file_abs'."
  return 0
}

# --- Functions to Apply Theme Components ---

# Applies GTK, Icon, Cursor themes, and system color scheme.
apply_gtk_theme_settings() {
  local theme_name="$1"
  local gtk_theme="${GTK_THEMES[$theme_name]}"
  local icon_theme="${ICON_THEMES[$theme_name]}"
  local cursor_theme="${CURSOR_THEMES[$theme_name]}"
  local theme_mode="${THEME_MODE[$theme_name]}"

  echo "Applying GTK, Icon, Cursor themes and system color scheme..."

  # Set GTK theme
  if [[ -n "$gtk_theme" ]]; then
    gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme" || echo "Warning: Failed to set GTK theme." >&2
  fi
  # Set Icon theme
  if [[ -n "$icon_theme" ]]; then
    gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" || echo "Warning: Failed to set icon theme." >&2
  fi
  # Set Cursor theme
  if [[ -n "$cursor_theme" ]]; then
    gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme" || echo "Warning: Failed to set cursor theme." >&2
  fi
  # Set system-wide color scheme
  if [[ -n "$theme_mode" ]]; then
    local color_scheme_value
    case "$theme_mode" in
    "dark") color_scheme_value="prefer-dark" ;;
    "light") color_scheme_value="prefer-light" ;;
    *) die "Unknown theme mode '$theme_mode'." ;;
    esac
    gsettings set org.gnome.desktop.interface color-scheme "$color_scheme_value" || echo "Warning: Failed to set system color scheme." >&2
    echo "System color scheme set to '$color_scheme_value'."
  fi
}

# Sets the wallpaper for static themes
set_static_wallpaper() {
  local theme_name="$1"
  local wallpaper_path="${DEFAULT_WALLPAPERS_DIR}/${theme_name}.jpg"

  if [[ ! -f "$wallpaper_path" ]]; then
    echo "Warning: Wallpaper not found at '$wallpaper_path'. Skipping wallpaper change." >&2
    return 1
  fi

  echo "Setting wallpaper: '$wallpaper_path'"
  swww img "$wallpaper_path" --transition-fps 62 --transition-type grow --transition-duration 0.7 || die "Failed to set wallpaper with swww."
  return 0
}

# Applies themes using symlinks for various applications
apply_symlinked_app_themes() {
  local theme_name="$1"
  echo "Applying symlinked application themes for '$theme_name'..."
  local overall_success=0

  for app_name in "${!SYMLINKED_APPS[@]}"; do
    echo "  - Applying theme for $app_name..."
    local config_string="${SYMLINKED_APPS[$app_name]}"
    IFS=':' read -r symlink_path theme_dir theme_ext <<<"$config_string"

    local target_file
    if [[ -n "$theme_ext" ]]; then
      target_file="$theme_dir/${theme_name}.${theme_ext}"
    else
      target_file="$theme_dir/${theme_name}"
    fi

    if ! create_active_symlink "$target_file" "$symlink_path"; then
      echo "  - Failed to apply theme for $app_name. See previous warnings." >&2
      overall_success=1
    fi
  done
  return "$overall_success"
}

# Handles Matugen wallpaper selection and theme generation
run_matugen_generation() {
  echo "Matugen theme selected. Please choose a wallpaper to generate colors from."

  mkdir -p "$DYNAMIC_WALLPAPERS_DIR" || die "Could not create dynamic wallpapers directory."

  mapfile -t DYNAMIC_WALLPAPERS < <(find "$DYNAMIC_WALLPAPERS_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -printf "%f\n" | sort)

  [[ ${#DYNAMIC_WALLPAPERS[@]} -eq 0 ]] && die "No wallpapers found in '$DYNAMIC_WALLPAPERS_DIR'."

  local SELECTED_WALLPAPER_FILE
  SELECTED_WALLPAPER_FILE=$(printf "%s\n" "${DYNAMIC_WALLPAPERS[@]}" | rofi -dmenu -p "Select Matugen Wallpaper:")

  [[ -z "$SELECTED_WALLPAPER_FILE" ]] && {
    echo "Wallpaper selection cancelled."
    return 1
  }

  local FULL_WALLPAPER_PATH="$DYNAMIC_WALLPAPERS_DIR/$SELECTED_WALLPAPER_FILE"
  echo "Generating theme with Matugen from: '$FULL_WALLPAPER_PATH'"
  matugen image "$FULL_WALLPAPER_PATH" --show-colors --type scheme-expressive || die "Matugen theme generation failed."
  echo "Matugen theme generation complete."
  return 0
}

# Reloads various desktop components
reload_components() {
  echo "Reloading desktop components..."

  echo "  - Reloading Waybar..."
  pkill -f waybar && sleep 1
  waybar -c "$HOME/.config/waybar/config.jsonc" -s "$HOME/.config/waybar/active_theme.css" &
  disown || echo "Warning: Waybar reload failed or not running." >&2
  sleep 2.5

  echo "  - Reloading Hyprland config..."
  hyprctl reload &>/dev/null || echo "Warning: Hyprland reload failed or hyprctl not available." >&2

  echo "  - Reloading Mako..."
  pkill -f mako && mako --config "$HOME/.config/mako/active_theme" &
  disown || echo "Warning: Mako reload failed or not running." >&2
  sleep 2.5
}

# --- Main Logic ---

# 1. Check for all required commands
check_command "rofi"
check_command "gsettings"
check_command "swww"
check_command "hyprctl"
check_command "notify-send"
check_command "matugen"
check_command "realpath"

# 2. Populate and sort theme list for Rofi selection
THEMES=("${!THEME_CONFIG[@]}")
IFS=$'\n' sorted_themes=($(sort <<<"${THEMES[*]}"))
unset IFS

# 3. Read the last applied theme for Rofi pre-selection
LAST_THEME=""
if [[ -f "$LAST_APPLIED_THEME_FILE" ]]; then
  LAST_THEME=$(cat "$LAST_APPLIED_THEME_FILE")
fi

# Prepare Rofi arguments, including pre-selecting the last theme
ROFI_ARGS=("-dmenu" "-p" "Select Theme:")
if [[ -n "$LAST_THEME" && " ${sorted_themes[*]} " =~ " $LAST_THEME " ]]; then
  ROFI_ARGS+=("-selected-row" "$(
    for i in "${!sorted_themes[@]}"; do
      if [[ "${sorted_themes[$i]}" == "$LAST_THEME" ]]; then
        echo "$i"
        break
      fi
    done
  )")
fi

# 4. Use Rofi to get user's theme selection
SELECTED_THEME=$(printf "%s\n" "${sorted_themes[@]}" | rofi "${ROFI_ARGS[@]}")

# 5. Handle user cancellation
if [ -z "$SELECTED_THEME" ]; then
  echo "Theme selection cancelled. Exiting."
  exit 0
fi

# 6. Validate the selected theme
[[ -z "${THEME_CONFIG[$SELECTED_THEME]}" ]] && die "Unknown theme selected: '$SELECTED_THEME'."

echo "--- Applying theme: '$SELECTED_THEME' ---"

# 7. Apply theme components
if [[ "$SELECTED_THEME" == "matugen" ]]; then
  run_matugen_generation || exit 1
  apply_gtk_theme_settings "$SELECTED_THEME"
else
  set_static_wallpaper "$SELECTED_THEME"
  apply_gtk_theme_settings "$SELECTED_THEME"
fi

# 8. Apply symlinked application themes
apply_symlinked_app_themes "$SELECTED_THEME" || echo "Some symlinked application themes failed to apply. Continuing..."

# 9. Reload relevant desktop components
reload_components

# 10. Store the successfully applied theme
echo "$SELECTED_THEME" >"$LAST_APPLIED_THEME_FILE" || echo "Warning: Could not save last applied theme." >&2

echo "Theme application process completed!"
notify-send "Hyprland Theme Switcher" "Successfully changed system theme to '$SELECTED_THEME'."
