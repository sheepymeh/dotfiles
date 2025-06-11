#!/bin/sh

enable sleep

LEDS=$(find /sys/class/leds/ -name '*::capslock')
declare -A START_STATES

for led in $LEDS; do
	brightness_file="$led/brightness"
	if [ -f "$brightness_file" ]; then
		read START_STATES["$brightness_file"] < "$brightness_file"
	fi
done

set_leds() {
	for led in $LEDS; do
		echo "$1" > "$led/brightness"
	done
}

set_leds 1
sleep 0.1
set_leds 0
sleep 0.1
set_leds 1
sleep 0.1

for brightness_file in "${!START_STATES[@]}"; do
	echo "${START_STATES[$brightness_file]}" > "$brightness_file"
done
