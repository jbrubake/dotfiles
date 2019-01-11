#!/bin/bash vim: foldlevel=0
#
# ~/.bash_profile: bash-specific login configuration

source "$HOME/.profile" # non-bash specific login config
source "$HOME/.bashrc"  # not sourced by default
BASH_ENV="$HOME/.env"   # non-interactive setup

