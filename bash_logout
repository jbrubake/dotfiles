#!/bin/bash

#
# If I am logging out completely, clear the
# screen and delete command history
#
if [ "$SHLVL" = 1 ]; then
    clear;
    history -c
fi
