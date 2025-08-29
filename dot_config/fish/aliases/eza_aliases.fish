# ~/.config/fish/aliases/eza_aliases.fish

# Define a variable for common eza options
set -g eza_options "--color=always --group-directories-first --icons"

# List all aliases using the variable
alias ls="eza -al $eza_options" # preferred listing
alias la="eza -a $eza_options"  # all files and dirs
alias ll="eza -l $eza_options"  # long format
alias lt="eza -aT $eza_options" # tree listing

# Special case for dotfiles
function l.
    eza -a $eza_options | grep -e '^\.'
end
