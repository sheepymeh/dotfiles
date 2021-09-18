#!/bin/bash
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
		if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -i nvidia; then
			CODEC=h264_nvenc
		else
			CODEC=h264_vaapi
		fi
		wf-recorder -f "$HOME/Videos/Screen Recording $(date +'%m.%d.%y %T').mp4" "$LOC" -c $CODEC -d /dev/dri/renderD128 -a"$(pactl info | grep 'Default Sink' | cut -d':' -f2 | xargs).monitor" -t 2>/dev/null &
		# In case acceleration is unavailable:
		# wf-recorder -f "$HOME/Videos/Screen Recording $(date +'%m.%d.%y %T').mp4" "$LOC" -a"$(pactl info | grep 'Default Sink' | cut -d':' -f2 | xargs).monitor" $LOC &
	fi
	sleep .2
	pkill -SIGRTMIN+2 i3blocks
fi