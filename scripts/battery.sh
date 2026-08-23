#!/bin/sh

set -eu

_BAT_PATH="${BATTERY_PATH}"
_AC_PATH="${AC_PATH}"

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
	case "$2" in
		_Unplugged)
			if [ "$1" -lt 20 ]; then
				echo "#f38ba8"
			fi
			;;
		Charging)
			if [ "$1" -lt 20 ]; then
				echo "#f9e2af"
			elif [ "$1" -gt 80 ]; then
				echo "#a6e3a1"
			fi
			;;
		Not\ *)
			if [ "$1" -lt 90 ]; then
				echo "#fab387"
			fi
			;;
	esac
}

charging_icon() {
	case "$1" in
		Charging) echo '' ;;
		Not\ *) echo '' ;;
	esac
}

read -r PERCENTAGE < "$_BAT_PATH/capacity"

if [ -n "$_AC_PATH" ] && [ -f "$_AC_PATH/online" ]; then
	read -r AC_ONLINE < "$_AC_PATH/online"
	if [ "$AC_ONLINE" = "1" ]; then
		CHARGING="Charging"
	else
		CHARGING="_Unplugged"
	fi
else
	read -r CHARGING < "$_BAT_PATH/status"
fi

printf "%s %s %s\n%s" \
	"$(percentage_icon "$PERCENTAGE")" \
	"$PERCENTAGE%" \
	"$(charging_icon "$CHARGING")" \
	"$(percentage_color "$PERCENTAGE" "$CHARGING")"
