local function shell_quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function run_once(command, pattern)
  local match = pattern or command
  hl.exec_cmd("pgrep -u \"$USER\" -f " .. shell_quote(match) .. " >/dev/null 2>&1 || " .. command)
end

hl.on("hyprland.start", function()
  run_once("$HOME/.dotfiles/scripts/start-wallpaper.sh", "hyprpaper")
  run_once("swaync", "^swaync$")
  run_once("waybar", "^waybar$")
  run_once("wl-paste --type text --watch cliphist store", "wl-paste --type text --watch cliphist store")
  run_once("wl-paste --type image --watch cliphist store", "wl-paste --type image --watch cliphist store")

  run_once(
    "test -x /usr/lib/polkit-kde-authentication-agent-1 && /usr/lib/polkit-kde-authentication-agent-1",
    "polkit-kde-authentication-agent-1"
  )
end)
