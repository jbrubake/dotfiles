#!/bin/bash

#
# If I am logging out completely, clear the
# screen and delete command history
#
if [ "$SHLVL" = 1 ]; then
    type clear >/dev/null 2>&1 && clear
    clear;
    history -c
fi
