# Luciano Dotfiles

## Instalar

```bash
git clone https://github.com/lucianoVillanuevaR/luciano-dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh
./install.sh --dry-run hyprland
./install.sh hyprland
./install.sh --dry-run hyprland-dotfiles
./install.sh hyprland-dotfiles
```

## Uso

```bash
cd ~/.dotfiles
./install.sh --dry-run full
./install.sh full
```

## Perfiles

```bash
./install.sh common
./install.sh cachyos
./install.sh gaming
./install.sh hyprland
./install.sh development
./install.sh dotfiles
./install.sh hyprland-dotfiles
./install.sh full
```

## Wallpaper

```bash
cp /ruta/a/imagen.jpg ~/.dotfiles/wallpapers/current.jpg
```

Si Hyprland ya esta iniciado:

```bash
pkill hyprpaper
~/.dotfiles/scripts/start-wallpaper.sh
```

## Actualizar

```bash
cd ~/.dotfiles
git pull
./install.sh --dry-run hyprland-dotfiles
./install.sh hyprland-dotfiles
```
