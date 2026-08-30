#!/usr/bin/env bash
set -Eeuo pipefail

ok() { printf '[ OK ] %s\n' "$*"; }
warn() { printf '[ WARN ] %s\n' "$*"; }
fail() { printf '[ FAIL ] %s\n' "$*"; }
info() { printf '[ INFO ] %s\n' "$*"; }
has() { command -v "$1" >/dev/null 2>&1; }

info "Kernel: $(uname -r)"
info "Uptime: $(uptime -p 2>/dev/null || uptime)"

info "Disk usage:"
df -h --output=source,fstype,size,used,avail,pcent,target / | sed 's/^/[ INFO ] /'

info "Memory:"
free -h | sed 's/^/[ INFO ] /'

if has systemctl; then
  failed_units="$(systemctl --failed --no-legend 2>/dev/null || true)"
  if [[ -n "$failed_units" ]]; then
    warn "Failed systemd units detected"
    printf '%s\n' "$failed_units" | sed 's/^/[ WARN ] /'
  else
    ok "No failed systemd units"
  fi
fi

if lspci 2>/dev/null | grep -qi nvidia; then
  ok "NVIDIA GPU detected"
  if has nvidia-smi; then
    nvidia-smi --query-gpu=name,driver_version,temperature.gpu --format=csv,noheader 2>/dev/null | sed 's/^/[ INFO ] NVIDIA: /' || warn "nvidia-smi is present but failed"
  else
    warn "nvidia-smi not found"
  fi
else
  info "No NVIDIA GPU detected by lspci"
fi

if has vulkaninfo; then
  ok "vulkaninfo available"
else
  warn "vulkaninfo not found"
fi

if has gamemoded; then
  ok "GameMode daemon command available"
else
  warn "gamemoded not found"
fi

if has systemctl; then
  if systemctl list-timers --all 2>/dev/null | grep -q 'fstrim'; then
    ok "TRIM timer found"
  else
    warn "TRIM timer not found"
  fi
fi

if findmnt -n -o FSTYPE / 2>/dev/null | grep -q '^btrfs$'; then
  ok "Root filesystem is Btrfs"
  findmnt -n -o OPTIONS / | sed 's/^/[ INFO ] Btrfs options: /'
else
  info "Root filesystem is not Btrfs"
fi

if has sensors; then
  sensors 2>/dev/null | sed -n '1,20p' | sed 's/^/[ INFO ] /'
else
  warn "lm_sensors not available"
fi
