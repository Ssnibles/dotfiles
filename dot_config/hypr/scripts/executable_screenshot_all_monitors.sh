#!/usr/bin/env bash

# Define screenshot directory if not set
screenshot_dir="${screenshot_dir:-$HOME/Pictures/Screenshots}"

# Create directory if it doesn't exist
mkdir -p "$screenshot_dir"

# Generate filename with timestamp
filename="$screenshot_dir/$(date +"%Y-%m-%d-%H-%M-%S").png"

# Take screenshot and save
grimblast save screen "$filename"

# Notify user
notify-send "Screenshot saved" "$filename"

# Copy image content to clipboard (Wayland)
wl-copy <"$filename"
