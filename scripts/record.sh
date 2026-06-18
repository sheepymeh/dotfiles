#!/bin/bash
enable sleep
enable cut
CODEC="hevc"

if [ "$1" = status ]; then
	if RECPID=$(pgrep -n wf-recorder); then
		while TIME=$(ps -p "$RECPID" -o etime=); do
			TIME=${TIME#"${TIME%%[![:space:]]*}"}
			printf '󰻃 %s\n' "$TIME"
			sleep 1
		done
		echo
	fi
else
	if ! killall -s SIGINT wf-recorder 2>/dev/null; then
		ARGS=(
			-f "$HOME/Videos/Screen Recording $(date +'%m.%d.%y %T').mp4"
			--audio
		)
		if [ "$1" = slurp ]; then
			ARGS+=(-g "$(slurp)")
		fi
		if [ -e /dev/nvidia0 ]; then
			if [ -e /usr/share/vulkan/icd.d/nvidia_icd.json ]; then
				ARGS+=(-c "${CODEC}_vulkan")
			else
				ARGS+=(-c "${CODEC}_nvenc" -b)
			fi
		elif [ -e /dev/dri/renderD128 ]; then
			ARGS+=(-c "${CODEC}_vaapi" -d "/dev/dri/renderD128")
		fi
		wf-recorder "${ARGS[@]}" 2>/dev/null &
	fi
	sleep .2
	pkill -SIGRTMIN+2 i3blocks
fi
