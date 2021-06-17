#!/bin/bash vim: foldlevel=0
#
# ~/.bash_profile: bash-specific login configuration

# This file does non-X login stuff so return
# if some DM decides it should be sourced
if test -n "$DISPLAY"; then
    return 2>/dev/null || exit
fi

source "$HOME/.profile" # non-bash specific login config
source "$HOME/.bashrc"  # interactive setup. not sourced by default
