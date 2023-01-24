#!/bin/sh

# Seconds until script output cache is stale
INTERVAL=60

# Get script location (OK even if it is a link because
# support scripts should also be linked here)
# PWD=$(dirname "$0")
# test "$PWD" == "." && PWD=$(pwd)
# source "$PWD/utils/cache.sh"
PLUGINS=$(tmux show-option -gqv @plugin_dir)
source "$PLUGINS/utils/cache.sh"
source "$PLUGINS/utils/utils.sh"

battery_status() {
    if is_wsl; then
		battery=$(find /sys/class/power_supply/*/status | tail -n1)
		awk '{print tolower($0);}' "$battery"
	elif command -v "pmset" >/dev/null; then
		pmset -g batt | awk -F '; *' 'NR==2 { print $2 }'
	elif command -v "acpi" >/dev/null; then
		acpi -b | awk '{gsub(/,/, ""); print tolower($3); exit}'
	elif command -v "upower" >/dev/null; then
		battery=$(upower -e | grep -E 'battery|DisplayDevice'| tail -n1)
		upower -i $battery | awk '/state/ {print $2}'
	elif command -v "termux-battery-status" >/dev/null; then
		termux-battery-status | jq -r '.status' | awk '{printf("%s%", tolower($1))}'
	elif command -v "apm" >/dev/null; then
		battery=$(apm -a)
		if [ $battery -eq 0 ]; then
			echo "discharging"
		elif [ $battery -eq 1 ]; then
			echo "charging"
		fi
	fi
}

battery_percentage() {
	# percentage displayed in the 2nd field of the 2nd row
	if is_wsl; then
		battery=$(find /sys/class/power_supply/*/capacity | tail -n1)
		cat "$battery"
	elif command -v "pmset" >/dev/null; then
		pmset -g batt | grep -o "[0-9]\{1,3\}%"
	elif command -v "acpi" >/dev/null; then
		acpi -b | grep -m 1 -Eo "[0-9]+%"
	elif command -v "upower" >/dev/null; then
        # use DisplayDevice if available otherwise battery
		battery=$(upower -e | grep -E 'battery|DisplayDevice'| tail -n1)
		if [ -z "$battery" ]; then
			return
		fi
		percentage=$(upower -i $battery | awk '/percentage:/ {print $2}')

		if [ "$percentage" ]; then
			echo ${percentage%.*%}
			return
		fi

		energy=$(upower -i $battery | awk -v nrg="$energy" '/energy:/ {print nrg+$2}')
		energy_full=$(upower -i $battery | awk -v nrgfull="$energy_full" '/energy-full:/ {print nrgfull+$2}')
		if [ -n "$energy" ] && [ -n "$energy_full" ]; then
			echo $energy $energy_full | awk '{printf("%d%%", ($1/$2)*100)}'
		fi
	elif command -v "termux-battery-status" >/dev/null; then
		termux-battery-status | jq -r '.percentage' | awk '{printf("%d%%", $1)}'
	elif command -v "apm" >/dev/null; then
		apm -l
	fi
}

get_battery() {
    battery_percentage
    battery_status
}

get_battery
# get_value get_battery "$INTERVAL"
