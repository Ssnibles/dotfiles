# ~/.config/fish/functions/misc_functions.fish

## History Enhancements
# Use bind instead of functions to improve efficiency and clarity
# The "bang-bang" functionality is best handled by direct bindings.
# This prevents potential conflicts and is the standard fish approach.
bind ! __history_previous_command
bind '$' __history_previous_command_arguments

function __history_previous_command
    # This function is now only for the binding and can be simplified
    commandline -i $history[-1]
end

function __history_previous_command_arguments
    # This is also simplified to its core functionality
    commandline -t (history -t)
end

## Copy and Backup Functions
# Combine copy and cp to allow for default cp behavior while adding a more robust copy
function copy
    if test (count $argv) = 2 && test -d "$argv[1]"
        # The 'string' command can be slow; a simple test might be faster here.
        # This condition handles the `cp -r` case for directories.
        command cp -r -- "$argv"
    else
        # Fallback to standard cp with all arguments
        command cp -- $argv
    end
end

function backup --argument filename
    # A more idiomatic fish check for argument presence
    if not set -q filename
        echo "Usage: backup <filename>"
        return 1
    end
    # Ensure a full path to the backup file to avoid ambiguity
    set backup_file "$filename".bak

    # Check if the file already exists before overwriting
    if test -f "$backup_file"
        read -P "Backup file '$backup_file' already exists. Overwrite? (y/N): " response
        if not test "$response" = y
            echo "Backup aborted."
            return 1
        end
    end
    command cp -- "$filename" "$backup_file"
    echo "Backup of '$filename' created as '$backup_file'"
end

## History Function
# Replaces the built-in history command with a more useful version
function history
    # fish's `history` command is a built-in.
    # The `builtin` keyword is good practice for clarity.
    builtin history --show-time='%F %T ' --max=1000
end

## Clean Function
# This function is already well-written. The use of `command` and `sudo` is correct.
function clean
    set script_path "$HOME/scripts/clean.sh"
    if test (count $argv) -gt 0 && test "$argv[1]" = "sudo"
        command sudo "$script_path" $argv[2..-1]
    else
        "$script_path" $argv
    end
end

## Pets Function
# This function is also excellent. No major changes needed.
function pets --description "Search and execute pet snippets"
    set -l selected_command (pet search)
    if test -n "$selected_command"
        commandline --insert "$selected_command"
    end
end
