# Source from conf.d before our fish config
source ~/.config/fish/conf.d/done.fish
source ~/.config/fish/functions/fzf_functions.fish
source ~/.config/fish/functions/fetch_functions.fish
source ~/.config/fish/functions/misc_functions.fish
source ~/.config/fish/keybinds.fish
source ~/.config/fish/aliases/eza_aliases.fish
source ~/.config/fish/aliases/common_aliases.fish
source ~/.config/fish/aliases/help_aliases.fish
source ~/.config/fish/aliases/scripts_aliases.fish
source ~/.config/fish/variables.fish
source ~/.config/fish/env.fish

# Add custom theme
fish_config theme choose "Rosé Pine Moon"

# PATHs
fish_add_path $HOME/.spicetify
fish_add_path $HOME/.emacs.d/bin/

starship init fish | source
zoxide init fish | source

fish_add_path $HOME/.millennium/ext/bin

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

fish_add_path /home/joshua/.spicetify
