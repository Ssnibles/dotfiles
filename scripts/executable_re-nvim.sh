#!/bin/bash

rm -rf ~/.local/state/nvim/ ~/.config/nvim/ ~/.local/share/nvim/ ~/.cache/nvim/
echo "removed"
git clone -b test2 https://github.com/Ssnibles/kickstart.nvim.git ~/.config/nvim
echo "re-installed"

