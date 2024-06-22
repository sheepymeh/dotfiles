#!/bin/sh
print_datetime() {
	echo " $(date '+%A %d.%m %H:%M')"
}

print_datetime
trap 'print_datetime' SIGUSR1

while :; do
	sleep $(( 60 - $(date "+%-S") % 60 )) &
	wait && print_datetime
done
