#!/bin/bash
set -Eeuo pipefail
if [ "$EUID" -eq 0 ]; then
	echo "Script must be run as user"
	exit 1
fi
cd "$(dirname -- "$0")"

firefox --window-size=1,1 --screenshot /dev/null about:blank

FF_PROFILE="$(compgen -G "$HOME/.config/mozilla/firefox/*.default-release")"

cp ../firefox/user.js "$FF_PROFILE/user.js"
