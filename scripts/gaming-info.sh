#!/usr/bin/env bash
set -Eeuo pipefail

line() { printf '[ INFO ] %s\n' "$*"; }
has() { command -v "$1" >/dev/null 2>&1; }

line "Kernel: $(uname -r)"
line "CPU: $(lscpu 2>/dev/null | awk -F: '/Model name/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')"
line "GPU:"
lspci 2>/dev/null | grep -Ei 'vga|3d|display' | sed 's/^/[ INFO ] /' || true

if has nvidia-smi; then
  nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null | sed 's/^/[ INFO ] NVIDIA: /' || true
fi

for cmd in vulkaninfo steam gamemoderun mangohud gamescope; do
  if has "$cmd"; then
    line "$cmd: available"
  else
    line "$cmd: not found"
  fi
done

if has xrandr; then
  line "Displays from xrandr:"
  xrandr --query 2>/dev/null | grep -E ' connected|^[[:space:]]+[0-9]+x[0-9]+' | sed 's/^/[ INFO ] /' || true
fi
