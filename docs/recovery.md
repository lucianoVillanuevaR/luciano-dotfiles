# Recovery

Backups:

```bash
ls ~/.local/share/luciano-dotfiles/backups/
```

Hyprland config:

```bash
hyprctl configerrors
```

Waybar service:

```bash
systemctl --user status waybar.service
systemctl --user daemon-reload
systemctl --user restart waybar.service
```

Wallpaper:

```bash
hyprctl hyprpaper listactive
cp /ruta/a/imagen.jpg ~/.dotfiles/wallpapers/current.jpg
pkill hyprpaper
~/.dotfiles/scripts/start-wallpaper.sh
```
