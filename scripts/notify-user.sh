#!/bin/sh
set -eu

if [ $# -lt 2 ]; then
	echo "Usage: notify-user.sh <user-or-uid|logged-in> <title> [body] [icon] [urgency]" >&2
	exit 1
fi

target="$1"
title="$2"
body="${3:-}"
icon="${4:-dialog-error}"
urgency="${5:-critical}"

send_for_user() {
	case "$1" in
		*[!0-9]*)
			uid="$(id -u "$1")"
			;;
		*)
			uid="$1"
			;;
	esac

	runtime_dir="/run/user/$uid"
	bus_path="$runtime_dir/bus"

	if [ -S "$bus_path" ]; then
		runuser -u "$uid" -- env \
			DBUS_SESSION_BUS_ADDRESS="unix:path=$bus_path" \
			XDG_RUNTIME_DIR="$runtime_dir" \
			notify-send "$title" "$body" --icon="$icon" -u "$urgency" -t 0
	else
		systemd-run --machine="$uid"@.host --user \
			notify-send "$title" "$body" --icon="$icon" -u "$urgency" -t 0
	fi
}

if [ "$target" = "logged-in" ]; then
	for user in $(loginctl list-users --json=short 2>/dev/null | jq -r '.[] | .uid'); do
		if [ "$user" -ge 1000 ]; then
			send_for_user "$user" || true
		fi
	done
else
	send_for_user "$target"
fi
