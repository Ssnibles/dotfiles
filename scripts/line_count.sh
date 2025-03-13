#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 <path-or-git-url>"
    echo "Counts lines of code using cloc for a local directory, file, or remote Git repository"
}

# Check if an argument is provided
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

TARGET="$1"
TEMP_DIR="temp-linecount-repo"

# Check if required commands are available
for cmd in cloc; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed or not in PATH"
        exit 1
    fi
done

# Function to clean up temporary directory
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        echo -e "\nCleaning up..."
        rm -rf "$TEMP_DIR"
    fi
}

# Set trap to ensure cleanup on script exit
trap cleanup EXIT

# Check if the target is a URL (simplified check)
if [[ $TARGET == http* ]]; then
    # It's a URL, so we need to clone it
    if ! command -v git &> /dev/null; then
        echo "Error: git is not installed or not in PATH"
        exit 1
    fi

    echo "Cloning repository..."
    if ! git clone --depth 1 "$TARGET" "$TEMP_DIR"; then
        echo "Error: Failed to clone repository"
        exit 1
    fi
    TARGET="$TEMP_DIR"
fi

echo -e "\nCounting lines of code...\n"

# Run cloc on the target
if ! cloc "$TARGET"; then
    echo "Error: Failed to run cloc"
    exit 1
fi

echo "Done!"
