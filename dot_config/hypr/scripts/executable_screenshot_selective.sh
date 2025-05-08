#!/usr/bin/env bash

# Define screenshot directory if not set
screenshot_dir="${screenshot_dir:-$HOME/Pictures/Screenshots}"

# Create directory if it doesn't exist
mkdir -p "$screenshot_dir"

# Generate filename with timestamp
filename="$screenshot_dir/$(date +"%Y-%m-%d-%H-%M-%S").png"

# Take screenshot and save
grimblast save area "$filename"

# Check if file was created and is not empty
if [[ -s "$filename" ]]; then
  notify-send "Screenshot saved" "$filename"
  wl-copy <"$filename"
else
  # Optional: notify user that screenshot was cancelled
  notify-send "Screenshot cancelled"
fi
