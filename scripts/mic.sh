#!/bin/sh
# Based on https://hugo.barrera.io/journal/2021/06/16/my-desktop-mute-toggle/, changed to i3blocks and without using ponymix
show() {
	if MIC="$(pactl list short sources | awk '$2 !~ /monitor/ && /RUNNING$/ { r = 1; print $2 } END { exit !r }')"; then
		if [ "$(pactl get-source-mute "$MIC")" = 'Mute: yes' ]; then
			echo -e '{"full_text": ""}'
		else
			echo -e '{"full_text": "", "color": "#f38ba8"}'
		fi
	else
		echo
	fi
}

monitor() {
	pactl subscribe 2>/dev/null | grep --line-buffered "'change' on source" |
		while read -r _; do
			show
		done
	exit
}

show
monitor
