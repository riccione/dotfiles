#!/bin/bash
#
set -euo pipefail

export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP="sway"
export XDG_SESSION_DESKTOP="sway"

# Use native Wayland where possible
export MOZ_ENABLE_WAYLAND=1
export SDL_VIDEODRIVER=wayland
export QT_QPA_PLATFORM=wayland

# scale: should be handled by sway config output * scale 1.x

# GNOME keyring
if command -v gnome-keyring-daemon >/dev/null; then
  eval "$(/usr/bin/gnome-keyring-daemon --start --components=secrets,ssh)"
  export SSH_AUTH_SOCK
fi


# for logging add after sway '-d 2> ~/sway.log'
exec dbus-run-session sway
