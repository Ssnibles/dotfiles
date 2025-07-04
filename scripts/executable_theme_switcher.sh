#!/bin/bash

# This script provides a theme switcher for Hyprland and various applications,
# focusing on Rose Pine variants (main, Dawn, Moon).

# --- Configuration ---
# Define your theme options
# THEMES will be dynamically populated from the THEM_CONFIG keys.
declare -A THEME_CONFIG=(
  ["rose-pine"]="A light, vibrant theme with rosy accents."
  ["rose-pine-moon"]="A darker, more subdued rose-pine variant."
  ["rose-pine-dawn"]="A bright, refreshing rose-pine variant."
)

DEFAULT_WALLPAPERS_DIR="$HOME/wallpapers/themed"

# Common active theme symlinks/files for various applications
ACTIVE_HYPRLAND_THEME_SYMLINK="$HOME/.config/hypr/themes/active_theme.conf"
ACTIVE_ALACRITTY_THEME_SYMLINK="$HOME/.config/alacritty/themes/active_theme.toml"
ACTIVE_GHOSTTY_THEME_SYMLINK="$HOME/.config/ghostty/ghostty_active_theme.conf"
ACTIVE_WAYBAR_THEME_SYMLINK="$HOME/.config/waybar/themes/active_theme.css"
ACTIVE_NVIM_THEME_FILE="$HOME/.config/nvim/lua/active_theme.lua" # This will be a symlink

# --- Theme Data (Centralized) ---
# Define specific settings for each static theme.
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

# --- Helper Functions ---

# Function to safely create or update a symlink
create_active_symlink() {
  local target_file="$1"
  local symlink_path="$2"
  echo "Attempting to create symlink:" # Added for debugging
  echo "  Target: $target_file"        # Added for debugging
  echo "  Symlink: $symlink_path"      # Added for debugging

  if [[ ! -f "$target_file" && ! -L "$target_file" ]]; then
    echo "Error: Target file for symlink does not exist: $target_file"
    return 1
  fi
  rm -f "$symlink_path" || { echo "Warning: Could not remove old symlink $symlink_path"; }
  ln -s "$target_file" "$symlink_path" || {
    echo "Error: Could not create symlink $symlink_path -> $target_file"
    return 1
  }
  echo "Symlinked $target_file to $symlink_path"
  return 0
}

# --- Functions to apply specific theme parts ---

apply_hyprland_theme() {
  local theme_name="$1"
  local theme_path="$HOME/.config/hypr/themes/${theme_name}.conf"

  create_active_symlink "$theme_path" "$ACTIVE_HYPRLAND_THEME_SYMLINK"

  if [[ $? -ne 0 ]]; then
    echo "Failed to apply Hyprland theme."
  fi
}

apply_alacritty_theme() {
  local theme_name="$1"
  local alacritty_config="$HOME/.config/alacritty/alacritty.toml"
  local theme_import_path="$HOME/.config/alacritty/themes/${theme_name}.toml"

  create_active_symlink "$theme_import_path" "$ACTIVE_ALACRITTY_THEME_SYMLINK"

  # Ensure alacritty.toml imports the active_theme.toml symlink
  if ! grep -q "import = \[\"$ACTIVE_ALACRITTY_THEME_SYMLINK\"\]" "$alacritty_config"; then
    sed -i "s|^import = \[.*\]$|import = [\"$ACTIVE_ALACRITTY_THEME_SYMLINK\"]|" "$alacritty_config"
    if [[ $? -ne 0 ]]; then
      echo "Warning: Could not update Alacritty import line. Please ensure '$alacritty_config' has 'import = [\"$ACTIVE_ALACRITTY_THEME_SYMLINK\"]'."
    fi
  fi
}

apply_ghostty_theme() {
  local theme_name="$1"
  local ghostty_themes_dir="$HOME/.config/ghostty/themes"
  local target_file="$ghostty_themes_dir/${theme_name}.conf"

  # Check if the target theme file exists
  if [[ ! -f "$target_file" ]]; then
    echo "Error: Ghostty theme file not found: $target_file"
    return 1
  fi

  # Create or update the symlink
  create_active_symlink "$target_file" "$ACTIVE_GHOSTTY_THEME_SYMLINK"
}

apply_waybar_theme() {
  local theme_name="$1"
  local waybar_style="$HOME/.config/waybar/style.css"
  local theme_css="$HOME/.config/waybar/themes/${theme_name}.css"

  create_active_symlink "$theme_css" "$ACTIVE_WAYBAR_THEME_SYMLINK"

  # Ensure waybar style.css imports the symlinked active theme
  if ! grep -q "@import \"$ACTIVE_WAYBAR_THEME_SYMLINK\";" "$waybar_style"; then
    sed -i "s|@import \".*\"|@import \"$ACTIVE_WAYBAR_THEME_SYMLINK\";|" "$waybar_style"
    if [[ $? -ne 0 ]]; then
      echo "Warning: Could not update Waybar import line. Please ensure '$waybar_style' has '@import \"$ACTIVE_WAYBAR_THEME_SYMLINK\";'."
    fi
  fi
}

apply_rofi_theme() {
  local theme_name="$1"
  local rofi_config="$HOME/.config/rofi/config.rasi"
  local theme_rasi="$HOME/.config/rofi/themes/${theme_name}.rasi"

  # Ensure the theme path is correctly set in rofi's config.rasi
  if grep -q "^theme:" "$rofi_config"; then
    sed -i "s|^theme: \".*\";$|theme: \"$theme_rasi\";|" "$rofi_config"
  else
    echo "Warning: 'theme:' line not found in $rofi_config. Please add 'theme: \"$theme_rasi\";' manually."
  fi
}

apply_gtk_theme() {
  local theme_name="$1"
  local gtk_theme="${GTK_THEMES[$theme_name]}"
  local icon_theme="${ICON_THEMES[$theme_name]}"
  local cursor_theme="${CURSOR_THEMES[$theme_name]}"

  if [[ -z "$gtk_theme" || -z "$icon_theme" || -z "$cursor_theme" ]]; then
    echo "Warning: GTK theme settings not fully defined for $theme_name. Using system defaults."
    return 1
  fi

  gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
  gsettings set org.gnome.desktop.interface icon-theme "$icon_theme"
  gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme"
  echo "GTK theme set to '$gtk_theme', icon theme to '$icon_theme', cursor theme to '$cursor_theme'."

  # For Qt, you'd integrate qt5ct/qt6ct or Kvantum here.
  # Example for Kvantum:
  # if [[ "$theme_name" == "rose-pine-dawn" ]]; then
  #         kvantummanager --set "KvRosePineDawn"
  # fi
}

apply_nvim_theme() {
  local theme_name="$1"
  local nvim_active_symlink="$ACTIVE_NVIM_THEME_FILE"   # The symlink path
  local nvim_themes_dir="$HOME/.config/nvim/lua/themes" # Directory where your actual theme files reside

  # Ensure the themes directory exists (if it contains your actual theme files)
  mkdir -p "$nvim_themes_dir"

  local nvim_target_file="" # The actual theme file in ~/.config/nvim/lua/themes/

  case "$theme_name" in
  "rose-pine")
    nvim_target_file="$nvim_themes_dir/rose-pine.lua"
    ;;
  "rose-pine-moon")
    nvim_target_file="$nvim_themes_dir/rose-pine-moon.lua"
    ;;
  "rose-pine-dawn")
    nvim_target_file="$nvim_themes_dir/rose-pine-dawn.lua"
    ;;
  *)
    echo "Neovim theme variant not defined for '$theme_name'. Skipping Neovim theme change."
    return 1
    ;;
  esac

  # Call the helper function to create the symlink
  create_active_symlink "$nvim_target_file" "$nvim_active_symlink"
  if [[ $? -ne 0 ]]; then
    echo "Failed to apply Neovim theme via symlink."
    return 1
  fi

  echo "Neovim active theme symlink created: $nvim_active_symlink -> $nvim_target_file"

  # Notify user to restart Neovim
  notify-send "Neovim Theme Changed" "Please restart Neovim for the theme to apply." -t 3000
}

set_wallpaper() {
  local wallpaper_path="$1"
  if [[ ! -f "$wallpaper_path" ]]; then
    echo "Error: Wallpaper not found at $wallpaper_path."
    return 1
  fi
  echo "Setting wallpaper: $wallpaper_path"
  swww img "$wallpaper_path" --transition-fps 60 --transition-type grow --transition-duration 0.7 || {
    echo "Error: Failed to set wallpaper with swww."
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
  hyprctl reload || { echo "Warning: Hyprland reload failed or hyprctl not available."; }

  echo "Reloading Mako..."
  pkill mako && mako &
  disown
  sleep 0.5 # Give Mako a moment to start

  # Alacritty/Ghostty usually require a restart to pick up theme changes.
  # It's generally better to inform the user or have a separate script for this
  # to avoid interrupting workflows.
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
  echo "Error: Unknown theme selected: $SELECTED_THEME"
  exit 1
fi

echo "Applying theme: $SELECTED_THEME"

case "$SELECTED_THEME" in
"rose-pine" | "rose-pine-moon" | "rose-pine-dawn")
  # Set specific wallpaper for static themes
  if ! set_wallpaper "$DEFAULT_WALLPAPERS_DIR/${SELECTED_THEME}.jpg"; then
    echo "Using fallback wallpaper as theme-specific one not found."
    # Optionally, set a default fallback wallpaper here
    # set_wallpaper "$HOME/wallpapers/default.jpg"
  fi

  apply_hyprland_theme "$SELECTED_THEME"
  apply_alacritty_theme "$SELECTED_THEME"
  apply_ghostty_theme "$SELECTED_THEME"
  apply_waybar_theme "$SELECTED_THEME"
  apply_rofi_theme "$SELECTED_THEME"
  apply_gtk_theme "$SELECTED_THEME"
  apply_nvim_theme "$SELECTED_THEME" # Apply Neovim theme
  ;;
*) # This 'catch-all' will now also handle cases where 'dynamic' might still be selected via wofi if not fully purged
  echo "Error: Unhandled or unsupported theme selected: $SELECTED_THEME"
  exit 1
  ;;
esac

echo "Reloading components..."
reload_components

echo "Theme applied successfully!"
echo "Please restart your terminal applications (Alacritty, Ghostty, Neovim) for full theme changes to take effect."
