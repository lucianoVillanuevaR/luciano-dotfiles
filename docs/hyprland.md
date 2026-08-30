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

`config/hypr/modules/gpu.lua` sets `AQ_DRM_DEVICES` with AMD first and NVIDIA
second:

```text
/dev/dri/by-path/pci-0000:05:00.0-card:/dev/dri/by-path/pci-0000:01:00.0-card
```

This makes AMD Vega the preferred renderer while keeping NVIDIA available for
games and for outputs physically wired to it. If HDMI behaves unexpectedly, the
first Hyprland test should include `hyprctl monitors all` and a review of this
ordering.

No legacy NVIDIA variables are enabled. Variables such as `GBM_BACKEND`,
`__GLX_VENDOR_LIBRARY_NAME` or cursor workarounds should only be added after a
specific issue appears and current documentation still recommends them.

## Monitors

The initial monitor configuration is deliberately generic:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
```

This avoids assuming connector names. The target layout is internal
`1920x1080@60` plus external `1920x1080@60`, both scale `1`, after names are
confirmed from inside Hyprland.

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

The installer does not deploy these dotfiles yet. Review them first, then decide
when to add `hypr`, `waybar`, `rofi`, `hyprlock` and `wlogout` to
`install_dotfiles`.

## Missing Runtime Packages

At detection time, these package commands did not report installed packages:

- `wl-clipboard`
- `cliphist`
- `grim`
- `slurp`
- `hyprlock`
- `wlogout`
- `uwsm`

They are not installed automatically during this phase.
