#!/bin/bash

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
