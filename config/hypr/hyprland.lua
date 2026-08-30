-- Hyprland 0.55+ Lua entrypoint.
-- Keep this file small; each module owns one part of the session.

require("modules.environment")
require("modules.gpu")
require("modules.monitors")
require("modules.input")
require("modules.appearance")
require("modules.windowrules")
require("modules.autostart")
require("modules.keybinds")
