#!/bin/sh

if command -v feh >/dev/null; then
    feh --no-fehbg --bg-fill $HOME/.wallpaper0
elif command -v xsetroot >/dev/null; then
    xsetroot \
        -mod "$(xrdb -query | awk '/xsetroot\.modx/ {print $2}')" \
             "$(xrdb -query | awk '/xsetroot\.mody/ {print $2}')" \
        -bg "$(xrdb -query | awk '/xsetroot\.background/ {print $2}')" \
        -fg "$(xrdb -query | awk '/xsetroot\.foreground/ {print $2}')"
fi

