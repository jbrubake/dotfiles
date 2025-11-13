#!/bin/sh
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Copyright 2021 Jeremy Brubaker <jbru362@gmail.com>
#
# abstract: print battery status
#
# Seconds until script output cache is stale
INTERVAL=60

# 10% to 100%
unplugged=󰁺󰁻󰁼󰁽󰁾󰁿󰂀󰂁󰂂󰁹
# 10% to 100%
charging=󰢜󰂆󰂇󰂈󰢝󰂉󰢞󰂊󰂋󰂅
# number of icons
icon_len=10

# Colorization threshholds
RED_THRESH=50
YELLOW_THRESH=75

# Get the battery name
get_battery() { upower -e | grep battery; }

# Is the AC adapter plugged in?
is_plugged_in() {
    [ $(upower -i $(upower -e | grep AC) | awk '/online:/ {print $2}') = 'yes' ]
}

battery() {
    # Get current % charge
    charge=$(upower -i $(get_battery) | awk '/percentage:/ {print $2}' | sed 's/%//')

    i=$((charge / icon_len + 1))            # convert charge to index into $unplugged / $charging
    [ "$i" -gt "$icon_len" ] && i=$icon_len # max of $icon_len

    # Which icon set to use?
    if is_plugged_in; then
        icons=$charging
    else
        icons=$unplugged
    fi

    # <icon> <charge>%
    printf '%s%s %s%%' "$(colorize "$charge" "$RED_THRESH" "$YELLOW_THRESH")" "$(echo "$icons" | cut -c"$i")" "$charge"
}

