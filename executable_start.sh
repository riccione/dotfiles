#!/bin/bash
#

export XDG_CURRENT_DESKTOP="sway"
export XDG_SESSION_DESKTOP="sway"

# scale
export GDK_SCALE=1.5
export GDK_DPI_SCALE=1.5
export QT_AUTO_SCREEN_SCALE_FACTOR=1.5
export QT_SCALE_FACTOR=1.5

export XDG_DATA_DIRS=/usr/local/share:/usr/share

# GNOME keyring
eval $(/usr/bin/gnome-keyring-daemon --start --components=secrets,pkcs11,ssh)
export SSH_AUTH_SOCK

# for logging add after sway '-d 2> ~/sway.log'
exec dbus-run-session sway
