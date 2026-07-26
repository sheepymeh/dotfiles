#!/bin/bash

set -Eeuo pipefail
enable sleep

shopt -s failglob
LEDS=(/sys/class/leds/*::capslock/brightness)
shopt -u failglob

declare -A INITIAL_STATES
for led in "${LEDS[@]}"; do
	read -r INITIAL_STATES["$led"] < "$led"
done

set_leds() {
	for led in "${LEDS[@]}"; do
		echo "$1" > "$led"
	done
}

set_leds 1
sleep 0.1
set_leds 0
sleep 0.1
set_leds 1
sleep 0.1

for led in "${!INITIAL_STATES[@]}"; do
	echo "${INITIAL_STATES[$led]}" > "$led"
done
