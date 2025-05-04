#!/bin/sh
x="Lock\nExit\nReboot\nShutdown"

selected=$(printf $x | fuzzel -dmenu | awk '{print tolower($1)}')

case $selected in
    lock)
        swaylock -e -c 000000 --indicator-idle-visible;;
    exit)
        sway exit;;
    reboot)
        exec systemctl reboot;;
    shutdown)
        exec systemctl poweroff;;
esac
