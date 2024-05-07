#!/bin/sh
#
# This file should only contain setup required when logging
# directly into X. Setup should be the same after that

# Setup Environment {{{1
. "$HOME/.env"      # common environment

# Start gpg and ssh agents
eval $(keychain --eval --nogui --agents ssh,gpg)

# Finish setting up {{{1
. $HOME/.xinitrc

