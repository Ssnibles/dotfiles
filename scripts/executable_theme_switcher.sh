#!/bin/bash

# This script provides a theme switcher for Hyprland and various applications,
# focusing on Rose Pine variants (main, Dawn, Moon).
# It now operates by only managing symlinks, assuming application configs
# are permanently set to import/use these 'active_theme' symlinks.

# --- Configuration ---
# Define your theme options and descriptions.
# The keys of this array will be used for theme selection.
declare -A THEME_CONFIG=(
  ["rose-pine"]="A light, vibrant theme with rosy accents."
  ["rose-pine-moon"]="A darker, more subdued rose-pine variant."
  ["rose-pine-dawn"]="A bright, refreshing rose-pine variant."
)

DEFAULT_WALLPAPERS_DIR="$HOME/wallpapers/themed"

# --- Theme Specific Data (Centralized per application) ---
# Define specific settings for each application, indexed by theme name.
# Ensure all themes in THEME_CONFIG have corresponding entries here.

declare -A GTK_THEMES=(
  ["rose-pine"]="RosePine-Dawn"
  ["rose-pine-moon"]="Dracula" # Example, replace with your actual GTK theme
  ["rose-pine-dawn"]="Adwaita-light"
)

declare -A ICON_THEMES=(
  ["rose-pine"]="Papirus-Dark"
  ["rose-pine-moon"]="Adwaita"
  ["rose-pine-dawn"]="Adwaita"
)

declare -A CURSOR_THEMES=(
  ["rose-pine"]="Bibata-Modern-Rose"
  ["rose-pine-moon"]="Adwaita"
  ["rose-pine-dawn"]="Adwaita"
)

# Define active theme symlinks/files for various applications
# This mapping makes it easier to manage which symlink belongs to which app.
# IMPORTANT: Your application configurations (e.g., alacritty.toml, waybar/style.css, rofi/config.rasi)
# MUST be configured to permanently point to these symlink paths.
declare -A APP_SYMLINKS=(
  ["hyprland"]="$HOME/.config/hypr/themes/active_theme.conf"
  ["alacritty"]="$HOME/.config/alacritty/active_theme.toml"
  ["ghostty"]="$HOME/.config/ghostty/active_theme.conf"
  ["waybar"]="$HOME/.config/waybar/themes/active_theme.css"
  ["nvim"]="$HOME/.config/nvim/lua/active_theme.lua"
  ["rofi"]="$HOME/.config/rofi/themes/active_theme.rasi" # Rofi now also uses a symlink
)

# Define base directories where actual theme files reside for applications using symlinks
declare -A APP_THEME_DIRS=(
  ["hyprland"]="$HOME/.config/hypr/themes"
  ["alacritty"]="$HOME/.config/alacritty/themes"
  ["ghostty"]="$HOME/.config/ghostty/themes"
  ["waybar"]="$HOME/.config/waybar/themes"
  ["nvim"]="$HOME/.config/nvim/lua/themes"
  ["rofi"]="$HOME/.config/rofi/themes" # Rofi theme files are here
)

# Define file extensions for theme files
declare -A APP_THEME_EXTENSIONS=(
  ["hyprland"]="conf"
  ["alacritty"]="toml"
  ["ghostty"]="conf"
  ["waybar"]="css"
  ["nvim"]="lua"
  ["rofi"]="rasi" # Rofi theme file extension
)

# --- Helper Functions ---

# Function to safely create or update a symlink
# Arguments: $1=target_file, $2=symlink_path
create_active_symlink() {
  local target_file="$1"
  local symlink_path="$2"

  if [[ ! -e "$target_file" ]]; then # Use -e to check for existence of file or symlink
    echo "Error: Target file for symlink does not exist: $target_file" >&2
    return 1
  fi

  # Remove existing symlink if it exists
  if [[ -L "$symlink_path" ]]; then
    rm "$symlink_path" || { echo "Warning: Could not remove old symlink $symlink_path" >&2; }
  elif [[ -f "$symlink_path" ]]; then
    echo "Warning: $symlink_path is a regular file, not a symlink. Removing it." >&2
    rm "$symlink_path" || {
      echo "Error: Could not remove regular file $symlink_path" >&2
      return 1
    }
  fi

  ln -s "$target_file" "$symlink_path" || {
    echo "Error: Could not create symlink $symlink_path -> $target_file" >&2
    return 1
  }
  echo "Symlinked $(basename "$target_file") to $(basename "$symlink_path")"
  return 0
}

# Function to apply themes using symlinks for various applications
# Arguments: $1=app_name, $2=theme_name
apply_app_symlink_theme() {
  local app_name="$1"
  local theme_name="$2"
  local theme_dir="${APP_THEME_DIRS[$app_name]}"
  local symlink_path="${APP_SYMLINKS[$app_name]}"
  local theme_ext="${APP_THEME_EXTENSIONS[$app_name]}"

  if [[ -z "$theme_dir" || -z "$symlink_path" || -z "$theme_ext" ]]; then
    echo "Error: Configuration missing for application '$app_name'." >&2
    return 1
  fi

  local target_file="$theme_dir/${theme_name}.${theme_ext}"

  create_active_symlink "$target_file" "$symlink_path"
  if [[ $? -ne 0 ]]; then
    echo "Failed to apply $app_name theme via symlink." >&2
    return 1
  fi
  return 0
}

# --- Functions to apply specific theme parts ---

apply_gtk_theme() {
  local theme_name="$1"
  local gtk_theme="${GTK_THEMES[$theme_name]}"
  local icon_theme="${ICON_THEMES[$theme_name]}"
  local cursor_theme="${CURSOR_THEMES[$theme_name]}"

  if [[ -z "$gtk_theme" || -z "$icon_theme" || -z "$cursor_theme" ]]; then
    echo "Warning: GTK theme settings not fully defined for $theme_name. Using system defaults." >&2
    return 1
  fi

  gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme" || { echo "Error: Failed to set GTK theme." >&2; }
  gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" || { echo "Error: Failed to set icon theme." >&2; }
  gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme" || { echo "Error: Failed to set cursor theme." >&2; }
  echo "GTK theme set to '$gtk_theme', icon theme to '$icon_theme', cursor theme to '$cursor_theme'."
  return 0
}

apply_nvim_theme() {
  local theme_name="$1"
  apply_app_symlink_theme "nvim" "$theme_name"

  # Notify user to restart Neovim
  notify-send "Neovim Theme Changed" "Please restart Neovim for the theme to apply." -t 3000
}

set_wallpaper() {
  local theme_name="$1"
  local wallpaper_path="$DEFAULT_WALLPAPERS_DIR/${theme_name}.jpg"

  if [[ ! -f "$wallpaper_path" ]]; then
    echo "Error: Wallpaper not found at $wallpaper_path. Using fallback." >&2
    # Optionally, set a default fallback wallpaper here
    # wallpaper_path="$HOME/wallpapers/default.jpg"
    # if [[ ! -f "$wallpaper_path" ]]; then
    #     echo "Error: Fallback wallpaper not found either. Skipping wallpaper change." >&2
    #     return 1
    # fi
    return 1 # Indicate failure if theme-specific wallpaper is missing
  fi

  echo "Setting wallpaper: $wallpaper_path"
  swww img "$wallpaper_path" --transition-fps 60 --transition-type grow --transition-duration 0.7 || {
    echo "Error: Failed to set wallpaper with swww." >&2
    return 1
  }
  return 0
}

reload_components() {
  echo "Reloading Waybar..."
  pkill waybar && waybar &
  disown
  sleep 0.5 # Give Waybar a moment to start

  echo "Reloading Hyprland config..."
  hyprctl reload || { echo "Warning: Hyprland reload failed or hyprctl not available." >&2; }

  echo "Reloading Mako..."
  pkill mako && mako &
  disown
  sleep 0.5 # Give Mako a moment to start

  echo "Note: Alacritty, Ghostty, and other applications might require a restart for theme changes to take full effect."
}

# --- Main Logic ---

# Populate THEMES array from THEME_CONFIG keys for wofi
THEMES=("${!THEME_CONFIG[@]}")
# Sort themes for consistent display
IFS=$'\n' sorted_themes=($(sort <<<"${THEMES[*]}"))
unset IFS

SELECTED_THEME=$(printf "%s\n" "${sorted_themes[@]}" | wofi --dmenu -p "Select Theme:")

if [ -z "$SELECTED_THEME" ]; then
  echo "Theme selection cancelled."
  exit 0 # User cancelled
fi

if [[ -z "${THEME_CONFIG[$SELECTED_THEME]}" ]]; then
  echo "Error: Unknown theme selected: $SELECTED_THEME" >&2
  exit 1
fi

echo "Applying theme: $SELECTED_THEME"

# Apply wallpaper
set_wallpaper "$SELECTED_THEME"

# Apply themes using the generic symlink function
apply_app_symlink_theme "hyprland" "$SELECTED_THEME"
apply_app_symlink_theme "alacritty" "$SELECTED_THEME"
apply_app_symlink_theme "ghostty" "$SELECTED_THEME"
apply_app_symlink_theme "waybar" "$SELECTED_THEME"
apply_app_symlink_theme "rofi" "$SELECTED_THEME" # Rofi now uses the symlink approach
apply_gtk_theme "$SELECTED_THEME"
apply_nvim_theme "$SELECTED_THEME"

echo "Reloading components..."
reload_components

echo "Theme applied successfully!"
echo "Remember to restart terminal applications for full theme changes."
