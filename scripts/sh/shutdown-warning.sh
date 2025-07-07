#!/usr/bin/env bash

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

notify-send "Shutting down in 1 minute!" "Save your work now."

sleep 60

systemctl poweroff
