#!/usr/bin/bash

status=$(cat /sys/class/power_supply/AC0/online)
charge=$(cat /sys/class/power_supply/BAT0/capacity)

if [[ $charge -lt 10 ]]; then
	echo -n ""
elif [[ $charge -lt 35 ]]; then
	echo -n ""
elif [[ $charge -lt 65 ]]; then
	echo -n ""
elif [[ $charge -lt 90 ]]; then
	echo -n ""
else
	echo -n ""
fi

echo -n " $charge%"

if [[ $status == 1 ]]; then
	echo "+"
else
	echo -e "\n"
fi

echo "$charge%"

if [[ $status == 0 ]]; then
	if [[ $charge -eq 20 ]]; then
		swaynag -m '20% Battery Remaining'
	fi
	if [[ $charge -lt 20 ]]; then
		echo "#ce575d"
	fi
elif [[ $status == Not* ]]; then
	if [[ $charge -lt 90 ]]; then
		echo "#FFFF00"
	fi
elif [[ $status == Charging ]]; then
	if [[ $charge -lt 20 ]]; then 
		echo "#ffe665"
	elif [[ $charge -gt 80 ]]; then
		echo "#77dd77"
	fi
fi
