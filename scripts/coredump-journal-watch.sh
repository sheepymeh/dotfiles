#!/bin/sh
set -eu

MESSAGE_ID=fc2e22bc6ee647b6b90729ab34a250b1  # https://man.archlinux.org/man/systemd-coredump.8#INFORMATION_ABOUT_THE_CRASHED_PROCESS

journalctl -f -n 0 MESSAGE_ID="$MESSAGE_ID" -o json 2>/dev/null | while read -r line; do
	read -r exe pid sig uid ts <<-EOF
		$(printf '%s' "$line" | jq -r '[
			.COREDUMP_COMM,
			.COREDUMP_PID,
			.COREDUMP_SIGNAL_NAME // .COREDUMP_SIGNAL,
			.COREDUMP_OWNER_UID // .COREDUMP_UID,
			.COREDUMP_TIMESTAMP
		] | @tsv')
	EOF

	seconds=$((ts / 1000000))
	human_time="$(date -d "@$seconds" '+%F %T')"

	title="Process ${exe} (${pid}) crashed"
	body="At ${human_time} with signal ${sig}"

	target="logged-in"  # notify all logged-in users if crash was from system or UID not known
	if [ "$uid" -ge 1000 ]; then
		target="${uid}"
	fi

	/usr/local/bin/notify-user.sh "$target" "$title" "$body" dialog-error critical || true
done

exit 0
