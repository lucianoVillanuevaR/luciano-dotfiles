# Installation

Clone the repository to the supported path:

```bash
git clone https://github.com/lucianoVillanuevaR/luciano-dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Use `./install.sh --dry-run` first. The installer detects the distribution,
refuses root execution and only installs the selected profile.

Managed dotfiles are symlinked from `config/` into `$HOME/.config` after
backing up any existing target to
`~/.local/share/luciano-dotfiles/backups/`.

Package profiles use plain package names for repository packages and
`aur:package-name` for future AUR-only entries. AUR entries are skipped safely
when `paru` or `yay` is unavailable.

In dry-run mode, package profiles may query installed packages with read-only
commands such as `pacman -Qq`, but they do not execute `pacman -S`, `paru -S`
or `yay -S`. They print install commands only for missing packages.

Recommended Hyprland installation:

```bash
./install.sh --dry-run hyprland
./install.sh hyprland
./install.sh --dry-run hyprland-dotfiles
./install.sh hyprland-dotfiles
```

The `hyprland` profile installs packages only. The `hyprland-dotfiles` profile
deploys `hypr`, `swaync`, `waybar`, `rofi`, `hyprlock`, `wlogout` and
`waybar.service`.

The `full` profile runs package profiles first, then common dotfiles, then
Hyprland dotfiles:

```text
common -> cachyos -> gaming -> hyprland -> development -> dotfiles -> hyprland-dotfiles
```

`full` does not configure kernel, NVIDIA drivers, PRIME, bootloader, initramfs,
SDDM or KDE.
