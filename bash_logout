#!/bin/bash

# If I am logging out completely, clear the screen
#
if [ "$SHLVL" = 1 ]; then
    type clear >/dev/null 2>&1 && clear
fi
