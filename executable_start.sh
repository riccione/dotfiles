#!/bin/bash
#

export XDG_CURRENT_DESKTOP="sway"
export XDG_SESSION_DESKTOP="sway"

# scale
export GDK_SCALE=1.5
export GDK_DPI_SCALE=1.5
export QT_AUTO_SCREEN_SCALE_FACTOR=1.5
export QT_SCALE_FACTOR=1.5

# export MOZ_ENABLE_WAYLAND=1

# GNOME keyring
eval $(/usr/bin/gnome-keyring-daemon --start --components=secrets,pkcs11,ssh)
export SSH_AUTH_SOCK

exec dbus-run-session sway
