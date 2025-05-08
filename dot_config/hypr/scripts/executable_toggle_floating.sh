#!/usr/bin/env bash

# Get floating state and window ID
floating=$(hyprctl activewindow -j | jq '.floating')

# Desired size (adjust as needed)
width=960
height=540

if [[ "$floating" == "false" ]]; then
  # Toggle floating on
  hyprctl dispatch togglefloating

  # Resize window to exact size
  hyprctl dispatch resizeactive exact $width $height

  # Center window on the monitor
  # hyprctl dispatch centerwindow
else
  # Toggle floating off
  hyprctl dispatch togglefloating
fi
