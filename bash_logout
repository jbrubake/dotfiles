#!/bin/bash

# Do not run this script if a tmux/screen session exists
type -p tmux   >/dev/null 2>&1 && tmux list-sessions
type -p screen >/dev/null 2>&1 && screen -ls

# If I am logging out completely, clear the screen
#
if [ "$SHLVL" = 1 ]; then
    type clear 2>&1 >/dev/null && clear
fi
