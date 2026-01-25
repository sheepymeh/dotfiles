#!/bin/sh
set -euo pipefail

if [ "$EUID" -eq 0 ]; then
	echo "Script must be run as user"
	exit
fi

sqlite3 ~/.config/mozilla/firefox/$FF_PROFILE/permissions.sqlite <<-EOF
	INSERT INTO moz_perms (origin, type, permission, expireType, expireTime, modificationTime) VALUES
	('https://accounts.google.com', 'cookie', '1', '0', '0', '1600000000000'),
	('https://amazon.co.uk', 'cookie', '1', '0', '0', '1600000000000'),
	('https://amazon.com', 'cookie', '1', '0', '0', '1600000000000'),
	('https://amazon.sg', 'cookie', '1', '0', '0', '1600000000000'),
	('https://app.tuta.com', 'cookie', '1', '0', '0', '1600000000000'),
	('https://cam.ac.uk', 'cookie', '1', '0', '0', '1600000000000'),
	('https://chatgpt.com', 'cookie', '1', '0', '0', '1600000000000'),
	('https://discord.com', 'cookie', '1', '0', '0', '1600000000000'),
	('https://github.com', 'cookie', '1', '0', '0', '1600000000000'),
	('https://login.microsoftonline.com', 'cookie', '1', '0', '0', '1600000000000'),
	('https://music.youtube.com', 'cookie', '1', '0', '0', '1600000000000');
	('https://sheepymeh.net', 'cookie', '1', '0', '0', '1600000000000'),
	('https://web.telegram.org', 'cookie', '1', '0', '0', '1600000000000'),
	('https://web.whatsapp.com', 'cookie', '1', '0', '0', '1600000000000'),
	('https://www.notion.so', 'cookie', '1', '0', '0', '1600000000000'),
EOF
