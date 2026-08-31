-- Safe fallback: do not assume connector names or disable displays.
-- Final target is internal 1920x1080@60 plus external 1920x1080@60, both scale 1.
-- After first Hyprland login, confirm names with: hyprctl monitors all

hl.monitor({
  output = "HDMI-A-1",
  mode = "preferred",
  position = "0x0",
  scale = 1,
})

hl.monitor({
  output = "eDP-1",
  mode = "preferred",
  position = "1920x0",
  scale = 1,
})
