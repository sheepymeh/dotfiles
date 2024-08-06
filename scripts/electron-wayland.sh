#!/bin/sh
read pkgname
if ! pacman -Qq "$pkgname" >/dev/null 2>&1; then
	echo 'package not found'
	exit 1
fi
SAVEIFS=$IFS
IFS=$'\n'
DESKTOP_FILES=($(pacman -Qql "$pkgname" | grep '\.desktop$'))
IFS=$SAVEIFS
for (( i=0; i<${#DESKTOP_FILES[@]}; i++ )); do
	if ! grep -q ' --enable-features=UseOzonePlatform --ozone-platform=wayland ' "${DESKTOP_FILES[$i]}"; then
		perl -i -pe 's/^Exec=(\S+?)[ \n]/Exec=$1 --enable-features=UseOzonePlatform --ozone-platform=wayland /' "${DESKTOP_FILES[$i]}"
	fi
done