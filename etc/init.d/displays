#!/bin/sh

# How many screens are connected?
screens=$(($(xrandr -q | grep ' connected' | wc -l) - 1))

# Office 3-monitor setup:
#
if [ $screens -eq 3 ]; then
    vertrot="left"
    
    # Determine actual name of each screen
    #
    # DP-{1,4}-1: Right side (vertical)
    # DP-{1,4}-2: Center
    # DP-{1,4}-3: Left side
    xrandr -q | grep -q "DP-1-1 connected"
    if [ $? -eq 0 ]; then
        left="DP-1-3"
        middle="DP-1-2"
        right="DP-1-1"
    else
        left="DP-4-3"
        middle="DP-4-2"
        right="DP-4-1"
    fi
    xrandr --output "$left"   --left-of "$middle" \
           --output "$middle" --left-of "$right" --primary \
           --output "$right"                     --rotate "$vertrot"
fi

