#!/bin/sh
enable sleep
enable cut
CODEC="hevc"

if [ "$1" = status ]; then
	if RECPID=$(pgrep -n wf-recorder); then
		while TIME=$(ps -p $RECPID -o etime=); do
			TIME=${TIME#"${TIME%%[![:space:]]*}"}
			printf ' %s\n' "$TIME"
			sleep 1
		done
		echo
	fi
else
	if ! killall -s SIGINT wf-recorder 2>/dev/null; then
		if [ "$1" = slurp ]; then
			LOC="-g $(slurp)"
		fi
		if [ -e /dev/nvidia0 ]; then
			if [ -e /usr/share/vulkan/icd.d/nvidia_icd.json ]; then CODEC="-c ${CODEC}_vulkan"
			else CODEC="-c ${CODEC}_nvenc -b"
			fi
		elif [ -e /dev/dri/renderD128 ]; then CODEC="-c ${CODEC}_vaapi -d /dev/dri/renderD128"
		else CODEC=""
		fi
		wf-recorder -f "$HOME/Videos/Screen Recording $(date +'%m.%d.%y %T').mp4" $LOC $CODEC -a"$(pactl info | grep 'Default Sink' | cut -d':' -f2 | xargs).monitor" 2>/dev/null &
	fi
	sleep .2
	pkill -SIGRTMIN+2 i3blocks
fi