-- ASUS TUF Gaming FX505DT GPUs detected read-only on 2026-08-30:
--   01:00.0 NVIDIA TU117M GeForce GTX 1650 Mobile / Max-Q
--   05:00.0 AMD Picasso/Raven 2 Radeon Vega Series / Vega Mobile Series
--
-- Persistent DRM paths detected:
--   NVIDIA card: /dev/dri/by-path/pci-0000:01:00.0-card
--   NVIDIA render: /dev/dri/by-path/pci-0000:01:00.0-render
--   AMD card:    /dev/dri/by-path/pci-0000:05:00.0-card
--   AMD render:  /dev/dri/by-path/pci-0000:05:00.0-render
--
-- Hyprland/Aquamarine uses AQ_DRM_DEVICES as a colon-separated list of DRM
-- card devices; the first path is primary. The intended order for this laptop
-- is AMD Vega first, NVIDIA second, keeping NVIDIA available for games and for
-- any outputs wired to it, such as HDMI on many hybrid laptops.
--
-- Enabled because both persistent PCI card paths were identified above.
hl.env(
  "AQ_DRM_DEVICES",
  "/dev/dri/by-path/pci-0000:05:00.0-card:/dev/dri/by-path/pci-0000:01:00.0-card"
)

-- Do not add legacy NVIDIA variables here by habit. Revisit only if a concrete
-- issue appears and current Hyprland/Arch documentation still recommends it.
