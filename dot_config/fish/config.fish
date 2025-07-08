# Source from conf.d before our fish config
source ~/.config/fish/conf.d/done.fish
source ~/.config/fish/functions/fzf_functions.fish
source ~/.config/fish/functions/fetch_functions.fish
source ~/.config/fish/functions/misc_functions.fish
source ~/.config/fish/functions/zoxide.fish
source ~/.config/fish/keybinds.fish
source ~/.config/fish/aliases/eza_aliases.fish
source ~/.config/fish/aliases/common_aliases.fish
source ~/.config/fish/aliases/help_aliases.fish
source ~/.config/fish/aliases/scripts_aliases.fish
source ~/.config/fish/variables.fish
source ~/.config/fish/env.fish
source ~/.config/fish/fzf.fish

fish_config theme choose "active_theme"

# PATHs
fish_add_path $HOME/.spicetify
fish_add_path $HOME/.emacs.d/bin/
fish_add_path "$HOME/.spicetify"
fish_add_path $HOME/.millennium/ext/bin

starship init fish | source
zoxide init fish | source


# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
set --export WNHOME "/usr/share/wordnet/"

set -gx EDITOR nvim
set -gx VISUAL nvim

