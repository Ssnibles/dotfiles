# ~/.config/fish/aliases/common_aliases.fish

# Common use aliases
alias grubup="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"

# Use functions for commands that take arguments.
# This ensures arguments are passed correctly.
function tarnow
    tar -acf "$argv[1]" "$argv[2]"
end

function untar
    tar -zxvf "$argv"
end

function wget
    command wget -c $argv
end

# Shorthand for directory navigation
# This is a common and useful pattern in fish.
function ..
    cd ..
end

function ...
    cd ../..
end

# Functions for specific actions
function psmem
    ps auxf | sort -nr -k 4 $argv
end

function psmem10
    ps auxf | sort -nr -k 4 | head -10
end

set -x GREP_OPTIONS "--color=auto"
set -x DIR_COLORS "auto"

alias hw="hwinfo --short"
alias big="expac -H M '%m\t%n' | sort -h | nl"
alias gitpkg="pacman -Q | grep -i "\-git" | wc -l"

# Combining commands into a single, reliable update function.
function update
    sudo pacman -Syyu
    and paru -Syyu
end

alias n="nvim"
alias t="tmux"

# Get fastest mirrors
function mirror
    sudo cachyos-rate-mirrors $argv
end

# Cleanup orphaned packages
function cleanup
    sudo pacman -Rns (pacman -Qtdq)
end

# Get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# Recent installed packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# Open file in emacs cli
function emacs
    emacs -nw $argv
end
