#!/bin/bash
set -Eeuo pipefail
if [ "$EUID" -eq 0 ]; then
	echo "Script must be run as user"
	exit 1
fi
cd "$(dirname -- "$0")"

FF_PROFILE="$(compgen -G "$HOME/.config/mozilla/firefox/*.default-release")"

cp ../firefox/user.js "$FF_PROFILE/user.js"

sqlite3 "$FF_PROFILE/permissions.sqlite" <<-EOF
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
	('https://login.nvgs.nvidia.com', 'cookie', '1', '0', '0', '1600000000000'),
	('https://music.youtube.com', 'cookie', '1', '0', '0', '1600000000000'),
	('https://notion.so', 'cookie', '1', '0', '0', '1600000000000'),
	('https://play.geforcenow.com', 'cookie', '1', '0', '0', '1600000000000'),
	('https://sheepymeh.net', 'cookie', '1', '0', '0', '1600000000000'),
	('https://tripos.pro', 'cookie', '1', '0', '0', '1600000000000'),
	('https://web.telegram.org', 'cookie', '1', '0', '0', '1600000000000'),
	('https://web.whatsapp.com', 'cookie', '1', '0', '0', '1600000000000'),
	('https://wikipedia.org', 'cookie', '1', '0', '0', '1600000000000');
EOF
