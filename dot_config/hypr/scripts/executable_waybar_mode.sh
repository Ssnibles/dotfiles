#!/bin/bash

# File to store the current state for Waybar visibility
STATE_FILE="$HOME/.config/hypr/waybar_state"

# Function to hide Waybar
hide_waybar() {
  killall -SIGUSR2 waybar # Hide Waybar
  echo "1" >"$STATE_FILE"
}

# Function to show Waybar
show_waybar() {
  killall -SIGUSR1 waybar # Show Waybar
  echo "0" >"$STATE_FILE"
}

# Check if the state file exists; if not, create it and set to "show" (0)
if [ ! -f "$STATE_FILE" ]; then
  echo "0" >"$STATE_FILE"
fi

# Read the current state
current_state=$(cat "$STATE_FILE")

# Toggle the state
if [ "$current_state" = "0" ]; then
  hide_waybar
else
  show_waybar
fi
