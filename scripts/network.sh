#!/bin/sh

if network=(`networkctl | grep -m 1 routable`); then
	if [ "${network[2]}" = 'wlan' ]; then
		output=`iwctl station wlan0 show`
		if connected=`grep 'Connected network' <<< "$output"`; then
			connected=`grep 'Connected network' <<< "$output"`
			connected=`xargs <<< "${connected:34}"`
			signal=(`grep AverageRSSI <<< "$output"`)
			signal="${signal[1]}"
			printf ' %s / %d\n' "$connected" $signal
		else
			echo " No Wi-Fi signal"
		fi
	elif [ "${network[2]}" = 'ether' ]; then
		echo ""
	fi
else
	echo ""
fi
