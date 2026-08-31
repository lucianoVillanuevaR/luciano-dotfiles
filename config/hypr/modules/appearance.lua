local palette = {
  bg = "rgba(050505a6)",
  bg_dim = "rgba(0f0f0fb8)",
  border = "rgba(ffffff1f)",
  border_active = "rgba(ffffff59)",
  text = "rgba(f0f0f0ff)",
  shadow = 0x99000000,
}

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 10,
    border_size = 2,
    col = {
      active_border = palette.border_active,
      inactive_border = palette.border,
    },
    resize_on_border = true,
    allow_tearing = false,
    layout = "dwindle",
  },

  decoration = {
    rounding = 9,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = {
      enabled = true,
      range = 9,
      render_power = 2,
      color = palette.shadow,
    },
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.12,
    },
  },

  animations = {
    enabled = true,
  },

  dwindle = {
    preserve_split = true,
    smart_split = false,
  },

  misc = {
    disable_hyprland_logo = true,
    force_default_wallpaper = 0,
  },
})

hl.curve("lucianoEase", { type = "bezier", points = { { 0.22, 1.0 }, { 0.36, 1.0 } } })
hl.curve("lucianoLinear", { type = "bezier", points = { { 0.0, 0.0 }, { 1.0, 1.0 } } })

hl.animation({ leaf = "global", enabled = true, speed = 1, bezier = "default" })
hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "lucianoEase", style = "popin 92%" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "lucianoEase" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "lucianoEase", style = "fade" })
hl.animation({ leaf = "layers", enabled = true, speed = 3, bezier = "lucianoEase", style = "fade" })

return palette
