#!/bin/bash

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

# Perform a chezmoi add to catch any changes
echo "Performing final add..."
chezmoi add $HOME

# Get the updated list of managed files
updated_managed_files=$(chezmoi managed)

# Compare the initial and updated lists
if [ "$managed_files" != "$updated_managed_files" ]; then
  echo "Changes detected in managed files. New files may have been added."
  echo "Updated list of managed files:"
  echo "$updated_managed_files"
else
  echo "No changes detected in managed files after final add."
fi
