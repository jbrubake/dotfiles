#!/bin/bash

# Do not run this script if a tmux/screen session exists
type -p tmux && tmux list-sessions 2>&1 >/dev/null && return
type -p screen && screen -ls 2>&1 >/dev/null && return

# If I am logging out completely, clear the screen
#
if [ "$SHLVL" = 1 ]; then
    type clear 2>&1 >/dev/null && clear
fi
