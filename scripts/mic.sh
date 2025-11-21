#!/bin/sh
# Based on https://hugo.barrera.io/journal/2021/06/16/my-desktop-mute-toggle/, changed to i3blocks and without using ponymix
show() {
	if MIC="$(/usr/bin/pactl list short sources | awk '$2 !~ /monitor/ && /RUNNING$/ { r = 1; print $2 } END { exit !r }')"; then
		if /usr/bin/pactl get-source-mute "$MIC" | grep -q yes; then
			echo -e '{"full_text": ""}'
		else
			echo -e '{"full_text": "", "color": "#f38ba8"}'
		fi
	else
		echo
	fi
}

monitor() {
	/usr/bin/pactl subscribe 2>/dev/null | /usr/bin/grep --line-buffered "'change' on source" |
		while read -r _; do
			show
		done
	exit
}

show
monitor
