# Installation

Use `./install.sh --dry-run` first. The installer detects the distribution, refuses root execution and only installs the profile selected by the user.

Managed dotfiles are linked from `config/` into `$HOME/.config` after backing up any existing target.

Package profiles use plain package names for repository packages and `aur:package-name` for future AUR-only entries. AUR entries are skipped safely when `paru` or `yay` is unavailable.

In dry-run mode, package profiles do not query or execute `pacman`, `paru` or `yay`. They print the install commands that would be used with `--needed`.

Prefer incremental installation:

```bash
./install.sh --dry-run common
./install.sh common
./install.sh --dry-run dotfiles
./install.sh dotfiles
```

The `full` profile is available, but it is intentionally not the default recommendation. It includes `common`, `cachyos`, `gaming`, `hyprland`, `development` and `dotfiles`.

Keep the repository in a permanent location such as `~/.dotfiles` before linking dotfiles. The installer detects its own directory dynamically, but symlinks point to the current repository location and will break if the repository is moved later.
