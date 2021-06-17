#!/bin/sh
#
# This file should only contain setup required when logging
# directly into X. Setup should be the same after that

# Setup Environment {{{1
. "$HOME/.env"      # common environment

# Show MOTD, etc {{{1
type 2>&1 >/dev/null xfortune && xfortune ~/share/games/fortunes

# Finish setting up {{{1
. ./.xinitrc

