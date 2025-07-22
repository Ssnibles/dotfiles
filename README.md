
# Dotfiles 🎨

![preview image](./preview.png)

### Single Command

This will install chezmoi and initialise your dotfiles from this repo:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply Ssnibles
```

**For just the chezmoi binary:**

```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
```

### Using Your Package Manager

- **Arch:** `sudo pacman -S chezmoi`
- **Alpine:** `apk add chezmoi`
- **NixOS:** `nix-env -i chezmoi`
- **OpenSUSE Tumbleweed:** `zypper install chezmoi`
- **Debian/Ubuntu:** `sudo apt install chezmoi`
- **Fedora:** `sudo dnf install chezmoi`
- **Homebrew (macOS/Linux):** `brew install chezmoi`
- **Chocolatey (Windows):** `choco install chezmoi`

### Manual Installation

If you prefer, download the binary and add it to your `$PATH`:

1. Download from the [chezmoi releases page](https://github.com/twpayne/chezmoi/releases).
2. Unpack the archive.
3. Move the binary to a directory in your `$PATH` (e.g. `/usr/local/bin`).

## Usage

### Common Commands

- **Apply changes:**

  ```bash
  chezmoi apply
  ```

  This updates your dotfiles in place using the contents from the repo.

- **Edit a dotfile:**

  ```bash
  chezmoi edit ~/.bashrc
  ```

  Opens the dotfile in your configured `$EDITOR` and tracks changes.

- **Add a new file to manage:**

  ```bash
  chezmoi add ~/.vimrc
  ```

  Starts tracking the file via chezmoi.

- **Diff between your system & chezmoi state:**

  ```bash
  chezmoi diff
  ```

### Secure Secrets Management

Chezmoi supports integrating with password managers (e.g. Bitwarden, LastPass, 1Password, pass). See the official documentation for details on [managing secrets](https://www.chezmoi.io/user-guide/managing-secrets/).

## Maintenance

### To Update

Update chezmoi and all managed dotfiles:

```bash
chezmoi update -R -v
```

> [!NOTE]
> This command updates chezmoi’s source, external dependencies, and gives verbose output.

### Backing Up Dotfiles

To ensure your latest dotfiles are backed up to your repo:

```bash
chezmoi cd     # cd into chezmoi's working tree
git add .
git commit -m "Update dotfiles"
git push
```

## Advanced Features

- **Templates:** Use logic, variables, and conditions in your dotfiles for more dynamic setups.
- **Scripts:** Run post-install scripts to automate extra setup steps (e.g., installing plugins).
- **Hooks:** Customize chezmoi’s behavior before and after operations.

## Troubleshooting

- **Check for errors:**

  ```bash
  chezmoi doctor
  ```

- **View help:**

  ```bash
  chezmoi help
  ```

## References

- [Chezmoi documentation](https://www.chezmoi.io/)
- [Official GitHub repository](https://github.com/twpayne/chezmoi)
