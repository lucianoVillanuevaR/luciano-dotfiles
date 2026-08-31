# Hyprland

Hyprland is configured as an alternative session alongside KDE Plasma. Plasma,
SDDM, NVIDIA drivers, kernel, bootloader, PRIME and initramfs are intentionally
left untouched by this repository phase.

## Phase 2 Detection

Read-only checks on 2026-08-30 detected:

- Hyprland: `0.56.2-1`, so the main configuration uses Lua at `config/hypr/hyprland.lua`.
- Current session: `XDG_SESSION_TYPE=wayland`, `XDG_CURRENT_DESKTOP=KDE`.
- UWSM: not installed as a package, but SDDM currently lists `hyprland-uwsm.desktop`.
- SDDM Wayland sessions: `hyprland.desktop`, `hyprland-uwsm.desktop`, `plasma.desktop`.
- NVIDIA driver via `nvidia-smi`: `610.57.04`.

GPU PCI devices:

- NVIDIA GTX 1650 Mobile / Max-Q: `01:00.0`.
- AMD Radeon Vega Mobile Series: `05:00.0`.

Persistent DRM paths:

- NVIDIA card: `/dev/dri/by-path/pci-0000:01:00.0-card`.
- NVIDIA render: `/dev/dri/by-path/pci-0000:01:00.0-render`.
- AMD card: `/dev/dri/by-path/pci-0000:05:00.0-card`.
- AMD render: `/dev/dri/by-path/pci-0000:05:00.0-render`.

## Architecture

```text
config/hypr/
├── hyprland.lua
└── modules/
    ├── appearance.lua
    ├── autostart.lua
    ├── environment.lua
    ├── gpu.lua
    ├── input.lua
    ├── keybinds.lua
    ├── monitors.lua
    └── windowrules.lua
```

The entrypoint uses Lua `require()` to load modules. This follows current
Hyprland documentation for 0.55+ and avoids a monolithic `hyprland.conf`.

## Multi-GPU

`config/hypr/modules/gpu.lua` keeps `AQ_DRM_DEVICES` temporarily disabled for
the first Hyprland session. Hyprland will autodetect the GPUs during that first
test.

Do not concatenate the current `/dev/dri/by-path/pci-*` paths directly into
`AQ_DRM_DEVICES`: the PCI path names contain `:` characters, and
`AQ_DRM_DEVICES` also uses `:` as its separator. The persistent GPU selection
will be resolved after the first session, likely with explicit AMD/NVIDIA DRM
aliases reviewed in a separate step.

Known PCI IDs remain documented:

- AMD Vega: `05:00.0`.
- NVIDIA GTX 1650: `01:00.0`.

The future target remains AMD Vega as the preferred renderer and NVIDIA
available for games or outputs physically wired to it. If HDMI behaves
unexpectedly, the first Hyprland test should include `hyprctl monitors all` and
a review of the GPU order.

No legacy NVIDIA variables are enabled. Variables such as `GBM_BACKEND`,
`__GLX_VENDOR_LIBRARY_NAME` or cursor workarounds should only be added after a
specific issue appears and current documentation still recommends them.

## Monitors

Monitor configuration lives in `config/hypr/modules/monitors.lua`. Validate the
active layout from inside Hyprland with:

```bash
hyprctl monitors all
```

## Portals

Both `xdg-desktop-portal-hyprland` and `xdg-desktop-portal-kde` are installed.
They should coexist so KDE and Hyprland can use the backend appropriate to each
session. Do not remove KDE portal packages as part of Hyprland setup.

## Components

- Waybar: `config/waybar/config.jsonc`, `config/waybar/style.css`.
- Rofi: `config/rofi/config.rasi`, `config/rofi/luciano-dark.rasi`.
- Clipboard menu: `scripts/clipboard-menu.sh`.
- Screenshots: `scripts/screenshot-full.sh`, `scripts/screenshot-area.sh`.
- Hyprlock: `config/hyprlock/hyprlock.conf`.
- Wlogout: `config/wlogout/layout`, `config/wlogout/style.css`.
- Diagnostics: `scripts/hyprland-info.sh`.

Deploy the Hyprland desktop configuration with:

```bash
./install.sh --dry-run hyprland-dotfiles
./install.sh hyprland-dotfiles
```

This links:

- `~/.config/hypr`
- `~/.config/swaync`
- `~/.config/waybar`
- `~/.config/rofi`
- `~/.config/hyprlock`
- `~/.config/wlogout`
- `~/.config/systemd/user/waybar.service`

After `waybar.service` is linked, the installer runs
`systemctl --user daemon-reload`. It does not enable or start the service;
Hyprland starts it from `config/hypr/modules/autostart.lua`.

## Runtime Packages

Install the Hyprland package profile before deploying the dotfiles:

```bash
./install.sh --dry-run hyprland
./install.sh hyprland
```

The profile includes Waybar, Rofi, Hyprlock, Wlogout, Hyprpaper, SwayNC,
wl-clipboard, cliphist, grim, slurp, brightnessctl, playerctl and pavucontrol.
