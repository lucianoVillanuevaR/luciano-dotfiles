# Luciano Dotfiles

Personal Linux configuration focused on CachyOS, gaming, Hyprland and reproducible system setup.

> Showcase: pending screenshots once the visual configuration is ready.

## Goals

- Safe, modular and documented Linux recovery workflow.
- CachyOS-first setup for gaming on KDE Plasma and future Hyprland sessions.
- Debian-ready architecture for a later work/development profile.
- Idempotent installer with backups before touching managed files.
- No destructive system changes without explicit review.

## Reference Hardware

- ASUS TUF Gaming FX505DT
- AMD Ryzen 5 3550H
- NVIDIA GeForce GTX 1650 4 GB
- AMD Vega iGPU

Hardware details are documentation only. Scripts must not hardcode machine-specific paths or assumptions.

## Stack

- CachyOS / Arch-compatible package profiles
- KDE Plasma on Wayland
- NVIDIA plus AMD iGPU
- Steam, Proton, GameMode, MangoHud and Gamescope
- Fish, Kitty, Fastfetch, btop and MangoHud dotfiles
- Future Hyprland session alongside Plasma

## Structure

```text
packages/   Package profiles by purpose
config/     Dotfiles managed by this repository
lib/        Installer helper libraries
scripts/    Safe operational scripts
system/     Distribution-specific notes and future automation
wallpapers/ Visual assets
docs/       Project documentation
```

## Installation

Preview actions without modifying the system:

```bash
./install.sh --dry-run
```

Interactive menu:

```bash
./install.sh
```

Direct profiles are planned and partially wired:

```bash
./install.sh common
./install.sh gaming
./install.sh hyprland
```

## Profiles

- `common`: general CLI and system inspection tools.
- `cachyos`: CachyOS/Arch convenience tools.
- `gaming`: Steam, Proton helpers and overlays without driver/kernel changes.
- `hyprland`: packages for a future alternative Hyprland session.
- `development`: basic development tools, intentionally conservative.

## Hyprland

Hyprland is planned as an additional session selectable from SDDM. This repository must not remove KDE Plasma, replace SDDM, change kernels, alter bootloader configuration or modify NVIDIA drivers automatically.

## NVIDIA

NVIDIA-related Hyprland settings will live in `config/hypr/nvidia.conf` and must be documented before being enabled. Kernel parameters, initramfs regeneration, PRIME changes and driver replacement require explicit manual approval.

## Backups

Managed configurations are backed up before replacement under:

```text
~/.local/share/luciano-dotfiles/backups/YYYY-MM-DD_HH-MM-SS/
```

Only paths managed by this repository are considered for backup.

## Security

Never commit secrets, tokens, private keys, cookies, VPN credentials, API keys, `.env` files or Steam account data. See `.gitignore` for guardrails.

## Initial Keybinds

Future Hyprland keybinds will include terminal, launcher, close window, file manager, fullscreen, floating toggle, workspaces, clipboard history, screenshots and lock screen.

## Credits

Inspired by: https://github.com/43PR/dotfiles

This is an independent implementation built around my own system, preferences and recovery workflow.
