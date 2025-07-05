#!/bin/bash

# This script provides a theme switcher for Hyprland and various applications,
# with an emphasis on easy theme management and symlink-based configuration.

# --- Configuration ---
# Define your theme options and descriptions.
# The keys of this array will be used for theme selection.
declare -A THEME_CONFIG=(
  ["rose-pine"]="A light, vibrant theme with rosy accents."
  ["rose-pine-moon"]="A darker, more subdued rose-pine variant."
  ["rose-pine-dawn"]="A bright, refreshing rose-pine variant."

  # Add new themes here following the format:
  # ["new-theme-name"]="A brief description of your new theme."
  # Example: ["nord"]="A cool, arctic-inspired theme."
)

DEFAULT_WALLPAPERS_DIR="$HOME/wallpapers/themed"

# --- Theme Specific Data (Centralized per application - Non-Symlinked) ---
# Define specific settings for applications that are NOT managed via symlinks.
# Ensure all themes defined in THEME_CONFIG have corresponding entries here.

declare -A GTK_THEMES=(
  ["rose-pine"]="RosePine-Dawn"
  ["rose-pine-moon"]="Dracula" # Example, replace with your actual GTK theme
  ["rose-pine-dawn"]="Adwaita-light"

  # Add new theme entries here for GTK
  # ["new-theme-name"]="YourNewGTKTheme"
)

declare -A ICON_THEMES=(
  ["rose-pine"]="Papirus-Dark"
  ["rose-pine-moon"]="Adwaita"
  ["rose-pine-dawn"]="Adwaita"

  # Add new theme entries here for Icons
  # ["new-theme-name"]="YourNewIconTheme"
)

declare -A CURSOR_THEMES=(
  ["rose-pine"]="Bibata-Modern-Rose"
  ["rose-pine-moon"]="Adwaita"
  ["rose-pine-dawn"]="Adwaita"

  # Add new theme entries here for Cursors
  # ["new-theme-name"]="YourNewCursorTheme"
)

# --- Consolidated Symlink Configuration ---
# This is the simplified way to add applications that use symlinks.
# Format: "app_name"="active_symlink_path:base_theme_dir:theme_file_extension"
#
# IMPORTANT: Your application configurations (e.g., alacritty.toml, waybar/style.css, rofi/config.rasi)
# MUST be configured to permanently point to these symlink paths.
# For example, your alacritty.toml should include: 'import = ["~/.config/alacritty/active_theme.toml"]'
# Your waybar/style.css should include: '@import "~/.config/waybar/active_theme.css";'
declare -A SYMLINKED_APPS=(
  ["hyprland"]="$HOME/.config/hypr/active_theme.conf:$HOME/.config/hypr/themes:conf"
  ["alacritty"]="$HOME/.config/alacritty/active_theme.toml:$HOME/.config/alacritty/themes:toml"
  ["ghostty"]="$HOME/.config/ghostty/active_theme.conf:$HOME/.config/ghostty/themes:conf"
  ["waybar"]="$HOME/.config/waybar/active_theme.css:$HOME/.config/waybar/themes:css"
  ["nvim"]="$HOME/.config/nvim/lua/active_theme.lua:$HOME/.config/nvim/lua/themes:lua"
  ["rofi"]="$HOME/.config/rofi/active_theme.rasi:$HOME/.config/rofi/themes:rasi"
  ["btop"]="$HOME/.config/btop/active_theme.theme:$HOME/.config/btop/themes:theme"

  # Add new applications here following the format above:
  # ["new_app"]="$HOME/.config/new_app/active_theme.conf:$HOME/.config/new_app/themes:conf"
  # Example: ["kitty"]="$HOME/.config/kitty/active_theme.conf:$HOME/.config/kitty/themes:conf"
)

# --- Helper Functions ---

# Function to safely create or update a symlink
# Arguments: $1=target_file, $2=symlink_path
# Returns: 0 on success, 1 on failure
create_active_symlink() {
  local target_file="$1"
  local symlink_path="$2"

  # Check if the target file exists
  if [[ ! -e "$target_file" ]]; then
    echo "Error: Target file for symlink does not exist: $target_file" >&2
    return 1 # Indicate failure
  fi

  # Remove existing symlink or regular file if it exists at the symlink path
  if [[ -L "$symlink_path" ]]; then
    # It's an existing symlink, remove it
    rm "$symlink_path" || { echo "Warning: Could not remove old symlink $symlink_path" >&2; }
  elif [[ -f "$symlink_path" ]]; then
    # It's a regular file, warn and remove it
    echo "Warning: $symlink_path is a regular file, not a symlink. Removing it." >&2
    rm "$symlink_path" || {
      echo "Error: Could not remove regular file $symlink_path" >&2
      return 1 # Indicate failure
    }
  fi

  # Create the new symlink
  ln -s "$target_file" "$symlink_path" || {
    echo "Error: Could not create symlink $symlink_path -> $target_file" >&2
    return 1 # Indicate failure
  }
  echo "Symlinked $(basename "$target_file") to $(basename "$symlink_path")"
  return 0 # Indicate success
}

# Function to apply themes using symlinks for various applications
# Arguments: $1=app_name, $2=theme_name
# Returns: 0 on success, 1 on failure
apply_app_symlink_theme() {
  local app_name="$1"
  local theme_name="$2"

  # Get the consolidated configuration string for the app
  local config_string="${SYMLINKED_APPS[$app_name]}"

  if [[ -z "$config_string" ]]; then
    echo "Error: Configuration missing for symlinked application '$app_name'." >&2
    return 1
  fi

  # Parse the config string into individual variables: symlink_path, theme_dir, theme_ext
  IFS=':' read -r symlink_path theme_dir theme_ext <<<"$config_string"

  local target_file="$theme_dir/${theme_name}.${theme_ext}"

  # Create the symlink
  create_active_symlink "$target_file" "$symlink_path"
  if [[ $? -ne 0 ]]; then # Check return code for create_active_symlink
    echo "Failed to apply $app_name theme via symlink." >&2
    return 1
  fi

  # Special notification for Neovim, as it often requires a restart
  if [[ "$app_name" == "nvim" ]]; then
    notify-send "Neovim Theme Changed" "Please restart Neovim for the theme to apply." -t 3001 &
  fi
  return 0
}

# --- Functions to apply specific theme parts (Non-Symlinked) ---

# Applies GTK, Icon, and Cursor themes using gsettings
# Arguments: $1=theme_name
# Returns: 0 on success, 1 on failure
apply_gtk_theme() {
  local theme_name="$1"
  local gtk_theme="${GTK_THEMES[$theme_name]}"
  local icon_theme="${ICON_THEMES[$theme_name]}"
  local cursor_theme="${CURSOR_THEMES[$theme_name]}"

  # Check if all GTK settings are defined for the selected theme
  if [[ -z "$gtk_theme" || -z "$icon_theme" || -z "$cursor_theme" ]]; then
    echo "Warning: GTK theme settings not fully defined for $theme_name. Using system defaults." >&2
    return 1 # Indicate partial success or warning
  fi

  # Set GTK theme
  gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme" || {
    echo "Error: Failed to set GTK theme." >&2
    return 1
  }
  # Set Icon theme
  gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" || {
    echo "Error: Failed to set icon theme." >&2
    return 1
  }
  # Set Cursor theme
  gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme" || {
    echo "Error: Failed to set cursor theme." >&2
    return 1
  }
  echo "GTK theme set to '$gtk_theme', icon theme to '$icon_theme', cursor theme to '$cursor_theme'."
  return 0
}

# Sets the wallpaper using swww
# Arguments: $1=theme_name
# Returns: 0 on success, 1 on failure
set_wallpaper() {
  local theme_name="$1"
  local wallpaper_path="$DEFAULT_WALLPAPERS_DIR/${theme_name}.jpg"

  # Check if the wallpaper file exists
  if [[ ! -f "$wallpaper_path" ]]; then
    echo "Error: Wallpaper not found at $wallpaper_path. Skipping wallpaper change." >&2
    # You can add logic here to set a default fallback wallpaper if desired
    return 1 # Indicate failure if theme-specific wallpaper is missing
  fi

  echo "Setting wallpaper: $wallpaper_path"
  # Execute swww command to set wallpaper
  swww img "$wallpaper_path" --transition-fps 61 --transition-type grow --transition-duration 0.7 || {
    echo "Error: Failed to set wallpaper with swww. Is swww running?" >&2
    return 1
  }
  return 0
}

# Reloads various desktop components to apply theme changes
reload_components() {
  echo "Reloading Waybar..."
  # Kill existing Waybar instances and restart it in the background
  pkill waybar && $HOME/.config/waybar/waybar.sh &
  disown
  sleep 1.5 # Give Waybar a moment to start

  echo "Reloading Hyprland config..."
  # Reload Hyprland configuration
  hyprctl reload || { echo "Warning: Hyprland reload failed or hyprctl not available." >&2; }

  echo "Reloading Mako..."
  # Kill existing Mako instances and restart it in the background
  pkill mako && mako &
  disown
  sleep 1.5 # Give Mako a moment to start

  echo "Note: Terminal applications like Alacritty, Ghostty, etc., might require a manual restart for theme changes to take full effect."
}

# --- Main Logic ---

# Populate THEMES array from THEME_CONFIG keys for wofi selection
THEMES=("${!THEME_CONFIG[@]}")
# Sort themes alphabetically for consistent display in wofi
IFS=$'\n' sorted_themes=($(sort <<<"${THEMES[*]}"))
unset IFS

# Use wofi (or dmenu) to present theme options to the user
SELECTED_THEME=$(printf "%s\n" "${sorted_themes[@]}" | wofi --dmenu -p "Select Theme:")

# Check if the user cancelled the selection
if [ -z "$SELECTED_THEME" ]; then
  echo "Theme selection cancelled."
  exit 0 # Exit gracefully if user cancels
fi

# Validate the selected theme against the configured themes
if [[ -z "${THEME_CONFIG[$SELECTED_THEME]}" ]]; then
  echo "Error: Unknown theme selected: $SELECTED_THEME" >&2
  exit 1 # Exit with error if an unknown theme is selected
fi

echo "Applying theme: $SELECTED_THEME"

# Apply wallpaper for the selected theme
set_wallpaper "$SELECTED_THEME"

# Loop through all configured symlinked applications and apply their themes
for app_name in "${!SYMLINKED_APPS[@]}"; do
  apply_app_symlink_theme "$app_name" "$SELECTED_THEME"
done

# Apply non-symlink based themes (e.g., GTK)
apply_gtk_theme "$SELECTED_THEME"

echo "Reloading components..."
# Reload relevant desktop components to apply changes
reload_components

echo "Theme applied successfully!"
echo "Remember to restart terminal applications for full theme changes."
