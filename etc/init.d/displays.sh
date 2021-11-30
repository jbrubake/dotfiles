#!/bin/sh

# Office 3-monitor setup:
#
# DP-4-1: Vertical
# DP-4-2: Large 
# DP-4-3: KVM
left="DP-4-3"
middle="DP-4-2"
right="DP-4-1"
vertrot="left"

screens=$(($(xrandr -q | grep ' connected' | wc -l) - 1))
if [ $screens -eq 3 ]; then
    xrandr --output "$left"   --left-of "$middle" \
           --output "$middle" --left-of "$right" --primary \
           --output "$right"                     --rotate "$vertrot"
fi

