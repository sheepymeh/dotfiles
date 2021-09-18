#!/bin/sh
# Based on https://hugo.barrera.io/journal/2021/06/16/my-desktop-mute-toggle/, changed to i3blocks and without using ponymix
show() {
	if MIC=$(pactl list short sources | awk '$2 !~ /monitor/ && /RUNNING$/ { r = 1; print $2; exit } END { exit !r }'); then
		if pamixer --source "$MIC" --get-mute >/dev/null; then
			echo -e '{"full_text": ""}'
		else
			echo -e '{"full_text": "", "background": "#CE575D"}'
		fi
	else
		echo
	fi
}

monitor() {
	pactl subscribe | /usr/bin/grep --line-buffered "'change' on source" |
		while read -r _; do
			show
		done
	exit
}

show
monitor