#!/bin/bash

if [ "$EUID" == 0 ]; then
	if [[ $(cat /sys/devices/system/cpu/cpufreq/boost) = 0 ]]; then
		echo 1 > /sys/devices/system/cpu/cpufreq/boost
	else
		echo 0 > /sys/devices/system/cpu/cpufreq/boost
	fi
fi

[[ $(cat /sys/devices/system/cpu/cpufreq/boost) = 1 ]] && echo -n  || echo -n 
echo " $(lscpu | grep "MHz" | head -n1 | cut -f 2 -d ":" | xargs | cut --b 1,2,3,4) MHz"
