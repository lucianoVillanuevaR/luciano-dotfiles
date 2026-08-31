hl.window_rule({
  name = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})

hl.window_rule({
  name = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

hl.window_rule({
  name = "float-pavucontrol",
  match = { class = "org.pulseaudio.pavucontrol" },
  float = true,
  size = "900 600",
  center = true,
})

hl.window_rule({
  name = "quick-terminal",
  match = { class = "quick-terminal" },
  float = true,
  size = "1200 600",
  center = true,
  fullscreen = false,
  pin = false,
})
