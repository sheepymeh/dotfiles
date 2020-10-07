#!/bin/bash

status=$(cat /sys/class/power_supply/ADP0/online)
charge=$(cat /sys/class/power_supply/BAT0/capacity)

if [ "$EUID" == 0 ]; then
	if [ $(cat /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode) == "0" ]; then
		echo 1 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode
	else
		echo 0 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode
	fi
fi

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
	if [ $(cat /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode) == "1" ]; then
		echo " "
	else
		echo " "
	fi
else
	echo
fi

echo "$charge"

if [[ $status == 0 ]]; then
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
