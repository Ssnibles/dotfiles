#!/usr/bin/env bash

# Capture the selected emoji
emoji=$(rofimoji --action print)

# If an emoji was selected, copy it and show a notification
if [[ -n "$emoji" ]]; then
  printf '%s' "$emoji" | xclip -selection clipboard

  # Show notification with emoji in body and as icon (if supported)
  notify-send "Emoji copied!" "$emoji" --icon=emoji
fi
