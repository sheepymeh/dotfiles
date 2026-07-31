#!/bin/sh

set -eu

threshold=90
state_file="${XDG_RUNTIME_DIR:-/tmp}/dotfiles-memory-high-$LOGNAME"

total_kb=
available_kb=

while IFS= read -r line; do
	case "$line" in
		MemTotal:*) total_kb="${line#MemTotal: }" ;;
		MemAvailable:*) available_kb="${line#MemAvailable: }" ;;
	esac
	if [ -n "$total_kb" ] && [ -n "$available_kb" ]; then
		break
	fi
done < /proc/meminfo

total_kb="${total_kb% kB}"
available_kb="${available_kb% kB}"
used_kb=$((total_kb - available_kb))
usage=$((used_kb * 100 / total_kb))

used_gib_tenths=$((used_kb * 10 / 1024 / 1024))
used_gib_major=$((used_gib_tenths / 10))
used_gib_minor=$((used_gib_tenths % 10))

color=
if [ "$usage" -ge "$threshold" ]; then
	color="#f38ba8"
fi

printf ' %d.%dGB / %d%%\n%d%%\n%s\n' "$used_gib_major" "$used_gib_minor" "$usage" "$usage" "$color"

if [ "$usage" -ge "$threshold" ]; then
	if [ ! -f "$state_file" ]; then
		notify-send "High memory usage" "Memory usage is at $usage%" --icon="dialog-error" -u "critical" -t 0
		: > "$state_file"
	fi
elif [ -f "$state_file" ]; then
	rm -f "$state_file"
fi
