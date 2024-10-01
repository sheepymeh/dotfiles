#!/bin/sh
set -euo pipefail

if [ "$EUID" -eq 0 ]; then
	echo "Script must be run as user"
	exit
fi
if [[ $(basename "$PWD") != "setup" ]]; then
	echo "Script must be run from /setup"
	exit
fi

firefox --createprofile default-release
FF_PROFILE="$(grep Path ~/.mozilla/firefox/profiles.ini | cut -f2 -d=)"
cat <<EOF >>~/.mozilla/firefox/profiles.ini
[Install4F96D1932A9F858E]
Default=$FF_PROFILE
Locked=1
EOF

wget https://github.com/catppuccin/firefox/releases/download/old/catppuccin_mocha_mauve.xpi
firefox \
	https://addons.mozilla.org/en-US/firefox/addon/decentraleyes \
	https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager \
	https://addons.mozilla.org/en-US/firefox/addon/history-cleaner \
	https://addons.mozilla.org/en-US/firefox/addon/mal-sync \
	https://addons.mozilla.org/en-US/firefox/addon/sponsorblock \
	https://addons.mozilla.org/en-US/firefox/addon/clearurls \
	https://addons.mozilla.org/en-US/firefox/addon/google-container \
	https://addons.mozilla.org/en-US/firefox/addon/ublock-origin \
	https://addons.mozilla.org/en-US/firefox/addon/styl-us \
	https://addons.mozilla.org/en-US/firefox/addon/zoom-redirector \
	https://addons.mozilla.org/en-US/firefox/addon/wallabagger \
	catppuccin_mocha_mauve.xpi \
rm catppuccin_mocha_mauve.xpi
# rm bypass_paywalls_clean-latest.xpi

cp ../firefox/* ~/.mozilla/firefox/$FF_PROFILE
sqlite3 ~/.mozilla/firefox/$FF_PROFILE/permissions.sqlite <<EOF
INSERT INTO moz_perms (origin, type, permission, expireType, expireTime, modificationTime) VALUES
('https://app.tuta.com', 'cookie', '1', '0', '0', '1600000000000'),
('https://github.com', 'cookie', '1', '0', '0', '1600000000000'),
('https://sheepymeh.net', 'cookie', '1', '0', '0', '1600000000000'),
('https://discord.com', 'cookie', '1', '0', '0', '1600000000000'),
('https://www.notion.so', 'cookie', '1', '0', '0', '1600000000000'),
('https://sheepymeh.net', 'cookie', '1', '0', '0', '1600000000000'),
('https://chatgpt.com', 'cookie', '1', '0', '0', '1600000000000'),
('https://amazon.co.uk', 'cookie', '1', '0', '0', '1600000000000'),
('https://web.whatsapp.com', 'cookie', '1', '0', '0', '1600000000000'),
('https://web.telegram.org', 'cookie', '1', '0', '0', '1600000000000'),
('https://cam.ac.uk', 'cookie', '1', '0', '0', '1600000000000'),
('https://login.microsoftonline.com', 'cookie', '1', '0', '0', '1600000000000'),
('https://accounts.google.com', 'cookie', '1', '0', '0', '1600000000000'),
('https://music.youtube.com', 'cookie', '1', '0', '0', '1600000000000');
EOF
