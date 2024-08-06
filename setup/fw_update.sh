#!/bin/sh

set -e

# innoextract f0cn41ww.exe

if [ -z "$1" ]; then
	echo Firmware updater - updates firmware using capsule files
	echo '    usage: ./fw_update.sh FILE.cap'
	echo '    requires fwupd to be installed and root (sudo) permissions'
	exit 1
fi

DEVICE_ID="$(fwupdmgr get-devices 2>/dev/null | grep -A1 'System Firmware' | grep 'Device ID' | cut -f2 -d':' | xargs)"
if [ -z "$DEVICE_ID" ]; then
	>&2 echo No compatible device found
	exit 1
fi

if [ ! -f "$1" ]; then
	>&2 echo Update file not found
	exit 1
fi

sudo fwupdtool install-blob "$1" "$DEVICE_ID"
