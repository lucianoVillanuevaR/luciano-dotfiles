# Installation

Use `./install.sh --dry-run` first. The installer detects the distribution, refuses root execution and only installs the profile selected by the user.

Managed dotfiles are linked from `config/` into `$HOME/.config` after backing up any existing target.

Package profiles use plain package names for repository packages and `aur:package-name` for future AUR-only entries. AUR entries are skipped safely when `paru` or `yay` is unavailable.
