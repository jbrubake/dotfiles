#!/bin/sh
#
# This file should only contain setup required when logging
# directly into X. Setup should be the same after that

# Setup Environment {{{1
. /etc/profile # login shells load this automatically
. "$HOME/.env" # common environment

# Start gpg and ssh agents
command -v keychain >/dev/null &&
    eval $(keychain --eval --nogui --agents ssh,gpg)

# Finish setting up {{{1
. $HOME/.xinitrc

