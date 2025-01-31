#!/bin/bash

CONFIG="$HOME/.config/waybar/config"
CSS="$HOME/.config/waybar/style.css"
CONFIG_FILES=("$CONFIG" "$CSS")

# Check if waybar is installed
if ! command -v waybar &>/dev/null; then
  echo "Error: waybar is not installed or not in PATH" >&2
  exit 1
fi

# Check if config files exist
for file in "${CONFIG_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "Error: Config file $file does not exist" >&2
    exit 1
  fi
done

trap 'killall waybar' EXIT

while true; do
  waybar -c "$CONFIG" &
  inotifywait -e create,modify "${CONFIG_FILES[@]}"
  killall waybar
  sleep 0.1 # Short delay to ensure waybar is fully terminated
done
