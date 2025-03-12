#!/bin/bash

# Declare an associative array to store directories and patterns
declare -A dirs

# Use exact paths or patterns (wildcards allowed)
dirs[".config"]="$HOME/.config/nvim $HOME/.config/ghostty $HOME/.config/btop $HOME/.config/fish $HOME/.config/hypr $HOME/.config/waybar $HOME/.config/rio $HOME/.config/yazi $HOME/.config/zed $HOME/.config/zellij"
dirs["Scripts"]="$HOME/Scripts/"
# dirs[".local"]="$HOME/.local/share/chezmoi"
# dirs["Documents"]="$HOME/Documents/*.md"

# Initial re-add
echo "Performing initial re-add..."
chezmoi re-add

# Get the list of files managed by chezmoi
managed_files=$(chezmoi managed)

# Loop through each managed file
while IFS= read -r file; do
  # Check if the file exists in the home directory
  if [ ! -e "$HOME/$file" ]; then
    echo "File $file has been deleted locally."

    # Use chezmoi forget to remove the file from management
    chezmoi forget "$HOME/$file"

    if [ $? -eq 0 ]; then
      echo "Successfully forgotten $file from chezmoi management."
    else
      echo "Failed to forget $file from chezmoi management."
    fi
  fi
done <<<"$managed_files"

# Perform chezmoi add for each specified path or pattern
echo "Adding specified files and directories..."
for dir_name in "${!dirs[@]}"; do
  patterns="${dirs[$dir_name]}"
  echo "Processing $dir_name..."
  for pattern in $patterns; do
    echo "  Adding $pattern..."
    chezmoi add $pattern
  done
done

# Get the updated list of managed files
updated_managed_files=$(chezmoi managed)

# Compare the initial and updated lists
if [ "$managed_files" != "$updated_managed_files" ]; then
  echo "Changes detected in managed files. New files may have been added."
  echo "Updated list of managed files:"
  echo "$updated_managed_files"
else
  echo "No changes detected in managed files after adding specified paths."
fi
