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

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# PATHs
fish_add_path /home/josh/.spicetify
fish_add_path $HOME/.emacs.d/bin/

thefuck --alias | source
starship init fish | source

fish_add_path /home/josh/.millennium/ext/bin

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
