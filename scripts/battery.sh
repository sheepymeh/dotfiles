#!/bin/sh

set -eu
BAT_PATH="$BATTERY_PATH"
# missing AC online detection

percentage_icon() {
	if [ "$1" -le 10 ]; then
		echo ''
	elif [ "$1" -le 35 ]; then
		echo ''
	elif [ "$1" -le 65 ]; then
		echo ''
	elif [ "$1" -le 90 ]; then
		echo ''
	else
		echo ''
	fi
}

percentage_color() {  # PERCENTAGE CHARGING
	if [ "$2" = "Charging" ]; then
		if [ "$1" -lt 20 ]; then
			echo "#f9e2af"
		elif [ "$1" -gt 80 ]; then
			echo "#a6e3a1"
		fi
	elif [ "$2" = "Not *" ]; then
		if [ "$1" -lt 90 ]; then
			echo "#fab387"
		fi
	fi
}

charging_icon() {
	if [ "$1" = "Charging" ]; then
		echo ''
	elif [ "$1" = "Not *" ]; then
		echo ''
	fi
}

read -r PERCENTAGE < "${BAT_PATH}/capacity"
read -r CHARGING < "${BAT_PATH}/status"
printf "%s %s %s\n%s" \
	"$(percentage_icon "$PERCENTAGE")" \
	"$PERCENTAGE%" \
	"$(charging_icon "$CHARGING")" \
	"$(percentage_color "$PERCENTAGE" "$CHARGING")"
