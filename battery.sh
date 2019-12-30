#!/usr/bin/bash

res=$(acpi -b | tail -n1)
status=${res%%,*}
status=${status#Battery 1: *}
charge=res | grep -oP "\d+%"

charge=$(echo $res | grep -oP "\d+%" | tr -d "%")

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

if [[ $status == Charging ]]; then
	echo "+"
else
	echo -e "\n"
fi

echo "$charge%"

if [[ $status == Discharging ]]; then
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
