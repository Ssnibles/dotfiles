#!/usr/bin/env bash

# This script provides a robust and flexible theme switcher for Hyprland and various applications,
# leveraging symlinks for configuration and integrating Pywal for dynamic theme generation
# from wallpapers. It aims for clear separation of concerns and improved error handling.

# --- Script Configuration and Error Handling ---
# Exit immediately if a command exits with a non-zero status.
set -e
# Exit if an undeclared variable is used.
set -u
# Exit if any command in a pipeline fails.
set -o pipefail
# Enable extended pattern matching features.
shopt -s extglob

# --- Global Variables ---
DEFAULT_WALLPAPERS_DIR="$HOME/wallpapers/themed"
PYWAL_WALLPAPERS_DIR="$HOME/wallpapers/pywal"
LAST_APPLIED_THEME_FILE="$HOME/.cache/current_theme"
PYWAL_CACHE_DIR="$HOME/.cache/wal" # Standard Pywal cache directory

# --- Configuration: Themes and Application Settings ---

# Define your theme options and descriptions.
# The keys of this array will be used for theme selection.
declare -A THEME_CONFIG=(
  ["rose-pine"]="A light, vibrant theme with rosy accents."
  ["rose-pine-moon"]="A darker, more subdued rose-pine variant."
  ["rose-pine-dawn"]="A bright, refreshing rose-pine variant."
  ["pywal"]="Generate theme from wallpaper using Pywal."
)

# Define specific settings for applications that are NOT managed via symlinks.
# Ensure all themes defined in THEME_CONFIG have corresponding entries here.
# For 'pywal' theme, these values are often overridden by Pywal's output,
# but a fallback or generic theme can be specified if needed.
declare -A GTK_THEMES=(
  ["rose-pine"]="Default"
  ["rose-pine-moon"]="Dracula"
  ["rose-pine-dawn"]="Adwaita-light"
  ["pywal"]="Adwaita" # Pywal often generates GTK themes, but a base GTK theme is still needed
)

declare -A ICON_THEMES=(
  ["rose-pine"]="Papirus-Dark"
  ["rose-pine-moon"]="Adwaita"
  ["rose-pine-dawn"]="Adwaita"
  ["pywal"]="Adwaita" # Pywal doesn't manage icon themes directly
)

declare -A CURSOR_THEMES=(
  ["rose-pine"]="Bibata-Modern-Rose"
  ["rose-pine-moon"]="Adwaita"
  ["rose-pine-dawn"]="Adwaita"
  ["pywal"]="Bibata-Modern-Rose"
)

# Define whether a theme is 'light' or 'dark' for system-wide color-scheme preference.
declare -A THEME_MODE=(
  ["rose-pine"]="dark"
  ["rose-pine-moon"]="dark"
  ["rose-pine-dawn"]="light"
  ["pywal"]="dark" # Default preference for Pywal, can be overridden by wal options
)

# Consolidated Symlink Configuration for applications.
# Format: "app_name"="active_symlink_path:base_theme_dir:theme_file_extension"
#
# IMPORTANT: Your application configurations (e.g., alacritty.toml, waybar/style.css, rofi/config.rasi)
# MUST be configured to permanently point to these symlink paths.
# For Pywal integration, the theme files in `base_theme_dir` (e.g., `pywal.conf`, `pywal.css`)
# should then *source* or *import* Pywal's generated files (e.g., ~/.cache/wal/colors-alacritty.toml).
declare -A SYMLINKED_APPS=(
  ["hyprland"]="$HOME/.config/hypr/active_theme.conf:$HOME/.config/hypr/themes:conf"
  ["ghostty"]="$HOME/.config/ghostty/active_theme.conf:$HOME/.config/ghostty/themes:conf"
  ["waybar"]="$HOME/.config/waybar/active_theme.css:$HOME/.config/waybar/themes:css"
  ["nvim"]="$HOME/.config/nvim/lua/active_theme.lua:$HOME/.config/nvim/lua/themes:lua"
  ["rofi"]="$HOME/.config/rofi/active_theme.rasi:$HOME/.config/rofi/themes:rasi"
  ["btop"]="$HOME/.config/btop/active_theme.theme:$HOME/.config/btop/themes:theme"
  ["mako"]="$HOME/.config/mako/active_theme:$HOME/.config/mako/themes:" # Empty extension handled
  ["fzf"]="$HOME/.config/fish/active_fzf_theme.fish:$HOME/.config/fish/fzf-themes:fish"
  ["fish"]="$HOME/.config/fish/themes/active_theme.theme:$HOME/.config/fish/themes:theme"
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

# Function to safely create or update a symlink
# Arguments: $1=target_file (absolute path), $2=symlink_path (absolute path)
# Returns: 0 on success, 1 on failure
create_active_symlink() {
  local target_file_abs="$1"
  local symlink_path_abs="$2"
  local symlink_dir

  symlink_dir=$(dirname "$symlink_path_abs")

  mkdir -p "$symlink_dir" || die "Could not create directory for symlink: $symlink_dir"

  # Check if target file exists. Warn and skip if not.
  [[ -e "$target_file_abs" ]] || {
    echo "Warning: Target file for symlink does not exist: $target_file_abs. Skipping symlink creation." >&2
    return 1 # Indicate failure
  }

  # Prefer 'realpath --relative-to' for robustness in creating relative symlinks.
  local relative_target
  if command -v realpath &>/dev/null; then
    relative_target=$(realpath --relative-to="$symlink_dir" "$target_file_abs")
  else
    echo "Warning: 'realpath' not found. Creating an absolute symlink for '$symlink_path_abs'." >&2
    relative_target="$target_file_abs" # Fallback to absolute path
  fi

  # Remove existing symlink or regular file at the symlink path
  if [[ -L "$symlink_path_abs" ]]; then
    rm "$symlink_path_abs" || echo "Warning: Could not remove old symlink $symlink_path_abs" >&2
  elif [[ -f "$symlink_path_abs" ]]; then
    echo "Warning: '$symlink_path_abs' is a regular file, not a symlink. Removing it." >&2
    rm "$symlink_path_abs" || die "Could not remove regular file $symlink_path_abs"
  fi

  # Create the new symlink
  if command -v realpath &>/dev/null; then
    # Use a subshell to change directory for relative symlink creation
    (
      cd "$symlink_dir" || die "Could not change directory to $symlink_dir to create symlink."
      ln -s "$relative_target" "$(basename "$symlink_path_abs")" || die "Could not create symlink '$(basename "$symlink_path_abs")' -> '$relative_target'"
    )
  else
    # Create absolute symlink if realpath is not available
    ln -s "$relative_target" "$symlink_path_abs" || die "Could not create symlink '$symlink_path_abs' -> '$relative_target'"
  fi

  echo "Symlinked '$symlink_path_abs' to '$target_file_abs'."
  return 0 # Indicate success
}

# --- Functions to Apply Theme Components ---

# Applies GTK, Icon, Cursor themes, and system color scheme using gsettings
# Arguments: $1=theme_name
# Returns: 0 on success, 1 on failure (if any gsettings command fails)
apply_gtk_theme_settings() {
  local theme_name="$1"
  local gtk_theme="${GTK_THEMES[$theme_name]}"
  local icon_theme="${ICON_THEMES[$theme_name]}"
  local cursor_theme="${CURSOR_THEMES[$theme_name]}"
  local theme_mode="${THEME_MODE[$theme_name]}"

  echo "Applying GTK, Icon, Cursor themes and system color scheme for '$theme_name'..."

  # Set GTK theme if defined
  [[ -n "$gtk_theme" ]] && gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme" ||
    echo "Warning: Failed to set GTK theme to '$gtk_theme' with gsettings (or theme not defined for '$theme_name')." >&2

  # Set Icon theme if defined
  [[ -n "$icon_theme" ]] && gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" ||
    echo "Warning: Failed to set icon theme to '$icon_theme' with gsettings (or theme not defined for '$theme_name')." >&2

  # Set Cursor theme if defined
  [[ -n "$cursor_theme" ]] && gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme" ||
    echo "Warning: Failed to set cursor theme to '$cursor_theme' with gsettings (or theme not defined for '$theme_name')." >&2

  # Set system-wide color scheme (light/dark preference) if defined
  if [[ -n "$theme_mode" ]]; then
    local color_scheme_value
    case "$theme_mode" in
    "dark") color_scheme_value="prefer-dark" ;;
    "light") color_scheme_value="prefer-light" ;;
    *)
      echo "Warning: Unknown theme mode '$theme_mode' for '$theme_name'. Skipping system color scheme setting." >&2
      color_scheme_value="" # Clear value to prevent setting
      ;;
    esac

    if [[ -n "$color_scheme_value" ]]; then
      gsettings set org.gnome.desktop.interface color-scheme "$color_scheme_value" ||
        echo "Warning: Failed to set system color scheme to '$color_scheme_value' with gsettings." >&2
      echo "System color scheme set to '$color_scheme_value'."
    fi
  else
    echo "Warning: Theme mode not defined for '$theme_name'. Skipping system color scheme setting." >&2
  fi
  return 0 # Always return 0 as individual failures are warned
}

# Sets the wallpaper using swww for static themes
# Arguments: $1=theme_name
# Returns: 0 on success, 1 on failure
set_static_wallpaper() {
  local theme_name="$1"
  # Assumes .jpg for static themes. Extend with more formats if needed.
  local wallpaper_path="${DEFAULT_WALLPAPERS_DIR}/${theme_name}.jpg"

  if [[ ! -f "$wallpaper_path" ]]; then
    echo "Warning: Wallpaper not found at '$wallpaper_path' for theme '$theme_name'. Skipping wallpaper change." >&2
    return 1
  fi

  echo "Setting wallpaper: '$wallpaper_path'"
  swww img "$wallpaper_path" --transition-fps 62 --transition-type grow --transition-duration 0.7 ||
    echo "Error: Failed to set wallpaper with swww. Is swww running and configured?" >&2
  return 0
}

# Applies themes using symlinks for various applications
# Arguments: $1=theme_name
# Returns: 0 on success, 1 on failure (if any symlink creation fails)
apply_symlinked_app_themes() {
  local theme_name="$1"
  echo "Applying symlinked application themes for '$theme_name'..."
  local overall_success=0

  for app_name in "${!SYMLINKED_APPS[@]}"; do
    echo "  - Applying theme for $app_name..."
    local config_string="${SYMLINKED_APPS[$app_name]}"
    IFS=':' read -r symlink_path theme_dir theme_ext <<<"$config_string"

    local target_file
    # Construct target_file based on whether theme_ext is provided
    if [[ -n "$theme_ext" ]]; then
      target_file="$theme_dir/${theme_name}.${theme_ext}"
    else
      target_file="$theme_dir/${theme_name}"
    fi

    # Attempt to create the symlink; log failure but continue
    if ! create_active_symlink "$target_file" "$symlink_path"; then
      echo "  - Failed to apply theme for $app_name. See previous warnings." >&2
      overall_success=1
    fi
  done
  return "$overall_success"
}

# Handles Pywal wallpaper selection and theme generation
# Returns: 0 on success (with wallpaper path echoed), 1 on cancellation/failure
run_pywal_generation() {
  echo "Pywal theme selected. Please choose a wallpaper to generate colors from."

  mkdir -p "$PYWAL_WALLPAPERS_DIR" || die "Could not create Pywal wallpapers directory: $PYWAL_WALLPAPERS_DIR"

  # Find supported image files in the Pywal wallpapers directory
  mapfile -t PYWAL_WALLPAPERS < <(find "$PYWAL_WALLPAPERS_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -printf "%f\n" | sort)

  [[ ${#PYWAL_WALLPAPERS[@]} -eq 0 ]] && die "No wallpapers found in '$PYWAL_WALLPAPERS_DIR'. Please add some images."

  # Use rofi to select a wallpaper for Pywal
  local SELECTED_WALLPAPER_FILE
  SELECTED_WALLPAPER_FILE=$(printf "%s\n" "${PYWAL_WALLPAPERS[@]}" | rofi -dmenu -p "Select Pywal Wallpaper:")

  # Exit gracefully if user cancels wallpaper selection
  [[ -z "$SELECTED_WALLPAPER_FILE" ]] && {
    echo "Wallpaper selection cancelled."
    return 1
  }

  local FULL_WALLPAPER_PATH="$PYWAL_WALLPAPERS_DIR/$SELECTED_WALLPAPER_FILE"

  echo "Generating theme with Pywal from: '$FULL_WALLPAPER_PATH'"
  # Execute wal to generate colors and set wallpaper. --saturate 0.8 is a good default.
  wal -i "$FULL_WALLPAPER_PATH" --saturate 0.8 || die "Pywal theme generation failed."
  echo "Pywal theme generation complete."

  # Pywal sets the wallpaper, so no need for a separate swww call.
  # The generated colors are in ~/.cache/wal/colors-*.
  # Applications must be configured to source/import these files.
  return 0
}

# Reloads various desktop components to apply theme changes
# Arguments: $1=theme_name (optional, for logging/specific reloads like sourcing colors.sh)
reload_components() {
  local theme_name="$1"
  echo "Reloading desktop components..."

  echo "  - Reloading Waybar..."
  # Waybar should always be restarted using its active symlink, which points to the correct theme file.
  pkill -f waybar && sleep 1
  waybar -c "$HOME/.config/waybar/config.jsonc" -s "$HOME/.config/waybar/active_theme.css" &
  disown ||
    echo "Warning: Waybar reload failed or Waybar not running." >&2
  sleep 2.5 # Give Waybar a moment to start

  echo "  - Reloading Hyprland config..."
  hyprctl reload &>/dev/null ||
    echo "Warning: Hyprland reload failed or hyprctl not available/running." >&2

  echo "  - Reloading Mako..."
  # Mako explicitly loads the symlinked config
  pkill -f mako && mako --config "$HOME/.config/mako/active_theme" &
  disown ||
    echo "Warning: Mako reload failed or Mako not running." >&2
  sleep 2.5 # Give Mako a moment to start

  # For Pywal, source the colors.sh for the current shell session (if it exists)
  # This helps apply terminal colors for the current script's environment.
  if [[ "$theme_name" == "pywal" && -f "$PYWAL_CACHE_DIR/colors.sh" ]]; then
    echo "  - Sourcing Pywal colors for current shell session..."
    . "$PYWAL_CACHE_DIR/colors.sh"
  fi
}

# --- Main Logic ---

# 1. Check for all required commands
check_command "rofi"
check_command "gsettings"
check_command "swww"
check_command "hyprctl"
check_command "notify-send"
check_command "wal" # Check for Pywal

# Warn if realpath is not found, as symlinks will be absolute instead of relative
if ! command -v realpath &>/dev/null; then
  echo "Warning: 'realpath' command not found. Symlinks will be created as absolute paths." >&2
fi

# 2. Populate and sort theme list for Rofi selection
THEMES=("${!THEME_CONFIG[@]}")
IFS=$'\n' sorted_themes=($(sort <<<"${THEMES[*]}"))
unset IFS

# 3. Read the last applied theme for Rofi pre-selection
LAST_THEME=""
if [[ -f "$LAST_APPLIED_THEME_FILE" ]]; then
  LAST_THEME=$(cat "$LAST_APPLIED_THEME_FILE")
fi

# Prepare Rofi arguments, including pre-selecting the last theme if it exists
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

# 5. Handle user cancellation of theme selection
if [ -z "$SELECTED_THEME" ]; then
  echo "Theme selection cancelled. Exiting."
  exit 0
fi

# 6. Validate the selected theme against configured themes
[[ -z "${THEME_CONFIG[$SELECTED_THEME]}" ]] && die "Unknown theme selected: '$SELECTED_THEME'. Please choose from the defined themes."

echo "--- Applying theme: '$SELECTED_THEME' ---"

# 7. Apply theme components based on theme type (Pywal vs. Static)
if [[ "$SELECTED_THEME" == "pywal" ]]; then
  # Run Pywal generation; exit if cancelled or fails
  run_pywal_generation || exit 1
  # For Pywal, GTK theme settings are applied here as a base;
  # Pywal's generated colors will override where applications support it.
  apply_gtk_theme_settings "$SELECTED_THEME" || echo "GTK theme application failed or skipped parts for Pywal. Continuing..."
else
  # For static themes, set wallpaper and then GTK settings
  set_static_wallpaper "$SELECTED_THEME" || echo "Wallpaper application failed or skipped."
  apply_gtk_theme_settings "$SELECTED_THEME" || echo "GTK theme application failed or skipped parts. Continuing..."
fi

# 8. Apply symlinked application themes (common to both static and Pywal)
apply_symlinked_app_themes "$SELECTED_THEME" || echo "Some symlinked application themes failed to apply. Continuing..."

# 9. Reload relevant desktop components to apply changes
reload_components "$SELECTED_THEME"

# 10. Store the successfully applied theme for next run
echo "$SELECTED_THEME" >"$LAST_APPLIED_THEME_FILE" || echo "Warning: Could not save last applied theme to $LAST_APPLIED_THEME_FILE" >&2

echo "Theme application process completed!"

# 11. Final notifications to the user
notify-send "Hyprland Theme Switcher" "Successfully changed system theme to '$SELECTED_THEME'."
notify-send --urgency critical "Hyprland Theme Switcher" "Remember to relaunch your terminal emulator for changes to take full effect."
echo "Note: Terminal applications like Alacritty, Ghostty, Neovim, etc., might require a manual restart for theme changes to take full effect."
echo "Note: For browsers like Zen to fully respect the light/dark mode, they might need to be restarted or configured to follow system preferences."
