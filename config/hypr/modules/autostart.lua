local function shell_quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function run_once(command, pattern, exact)
  local pgrep_flag = exact and "-x" or "-f"
  local match = pattern or command

  hl.exec_cmd("pgrep -u \"$USER\" " .. pgrep_flag .. " " .. shell_quote(match) .. " >/dev/null 2>&1 || " .. command)
end

local startup_log = "$HOME/.local/state/luciano-dotfiles/startup.log"

hl.on("hyprland.start", function()
  hl.exec_cmd(
    "mkdir -p \"$HOME/.local/state/luciano-dotfiles\"; " ..
    "if [ -n \"${HYPRLAND_INSTANCE_SIGNATURE:-}\" ]; then his=present; else his=missing; fi; " ..
    "printf '[%s] HYPRLAND_INSTANCE_SIGNATURE=%s WAYLAND_DISPLAY=%s wallpaper=requested waybar=requested\\n' " ..
    "\"$(date '+%Y-%m-%d %H:%M:%S %z')\" \"$his\" \"${WAYLAND_DISPLAY:-unset}\" >> " .. startup_log
  )

  run_once("$HOME/.dotfiles/scripts/start-wallpaper.sh", "hyprpaper", true)
  run_once("swaync", "swaync", true)

  hl.exec_cmd(
    "systemctl --user import-environment WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP XDG_SESSION_TYPE && " ..
    "systemctl --user start waybar.service || " ..
    "{ mkdir -p \"$HOME/.local/state/luciano-dotfiles\"; printf '[%s] ERROR Waybar service failed\\n' \"$(date '+%Y-%m-%d %H:%M:%S %z')\" >> " .. startup_log .. "; }"
  )

  run_once("wl-paste --type text --watch cliphist store")
  run_once("wl-paste --type image --watch cliphist store")
  run_once(
    "test -x /usr/lib/polkit-kde-authentication-agent-1 && /usr/lib/polkit-kde-authentication-agent-1",
    "polkit-kde-authentication-agent-1",
    true
  )
end)
