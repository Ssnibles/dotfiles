# Functions needed for !! and !$ (enhanced from https://github.com/oh-my-fish/plugin-bang-bang)
function __history_previous_command
  switch (commandline -t)
    case "!"
      # Use last history item (Fish history is 1=oldest, -1=newest)
      commandline -t $history[-1]
      commandline -f repaint
    case '*'
      commandline -i !
  end
end

function __history_previous_command_arguments
  switch (commandline -t)
    case "!"
      commandline -t ""
      commandline -f history-token-search-backward
    case '*'
      commandline -i '$'
  end
end

# Enhanced copy function with better path handling
function copy
  set count (count $argv)
  if test "$count" = 2 && test -d "$argv[1]"
    # Remove trailing slash using Fish string replacement
    set from (string replace -r '/$' '' -- $argv[1])
    set to $argv[2]
    command cp -r -- "$from" "$to"
  else
    command cp -- $argv
  end
end

# History with timestamp formatting
function history
  builtin history --show-time='%F %T ' --max=1000
end

# Backup function with error checking
function backup --argument filename
  if test -z "$filename"
    echo "Usage: backup <filename>"
    return 1
  end
  cp -- "$filename" "$filename.bak"
end

# Clean function with proper path handling
function clean
  set script_path "$HOME/scripts/clean.sh"
  
  if test (count $argv) -gt 0 && test "$argv[1]" = "sudo"
    command sudo "$script_path" $argv[2..-1]
  else
    "$script_path" $argv
  end
end

# Open pet search and run
function pets
    set cmd (pet search)
    if test -n "$cmd"
        eval $cmd
    end
end

