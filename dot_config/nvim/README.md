# Neovim Config

My Personal Neovim Config built from scratch using lazy.nvim as the plugin manager
![preview](./preview.png)

## Features

Auto completion using blink.cmp, fuzzy searching using snacks.picker, and many more things

## Install

```bash
rm -rf ~/.config/nvim/ ~/.local/state/nvim/ ~/.local/share/nvim/ ~/.cache/nvim/
```

Afterward run:

```bash
git clone -b <BRANCH> https://github.com/Ssnibles/kickstart.nvim.git ~/.config/nvim
```

## Branches

- master - pretty much dead though I do push updates to it from time to time
- main - even more dead then master
- test - also dead lol
- test2 - most active and "main" branch at this point

Now you can run neovim
On first run a bunch of LSPs will be installed,
after they have been installed run

```bash
MasonToolsInstall
```

the above command will installe formatters and linters
