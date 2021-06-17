#!/bin/bash

# Do not run this script if a tmux/screen session exists
tmux list-sessions 2>&1 >/dev/null && return
screen -ls 2>&1 >/dev/null && return

# If I am logging out completely, clear the screen
#
if [ "$SHLVL" = 1 ]; then
    type clear >/dev/null 2>&1 && clear
fi
