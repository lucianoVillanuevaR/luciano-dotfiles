local mainMod = "SUPER"
local terminal = "kitty"
local launcher = "rofi -show drun"
local fileManager = "dolphin"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(launcher))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("~/.dotfiles/scripts/clipboard-menu.sh"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock --config \"$HOME/.dotfiles/config/hyprlock/hyprlock.conf\""))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("kitty --class spotify-player spotify_player"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("~/.dotfiles/scripts/toggle-quick-terminal.sh"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("~/.dotfiles/scripts/minimize-window.sh"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("~/.dotfiles/scripts/restore-minimized.sh"))
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd("rofi -show window -theme ~/.dotfiles/config/rofi/luciano-dark.rasi"))

hl.bind("Print", hl.dsp.exec_cmd("~/.dotfiles/scripts/screenshot-full.sh"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("~/.dotfiles/scripts/screenshot-area.sh"))

for i = 1, 9 do
  hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("~/.dotfiles/scripts/power-profile-menu.sh"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("~/.dotfiles/scripts/control-center.sh"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"))

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true })

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.dotfiles/scripts/osd-control.sh volume-up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.dotfiles/scripts/osd-control.sh volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("~/.dotfiles/scripts/osd-control.sh volume-mute"), { locked = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("~/.dotfiles/scripts/osd-control.sh brightness-up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("~/.dotfiles/scripts/osd-control.sh brightness-down"), { locked = true, repeating = true })
