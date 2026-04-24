#!/bin/bash
set -Eeuo pipefail

if [ "$EUID" -ne 0 ]; then
	echo "Script must be run as root"
	exit
fi

pacman -S --noconfirm --needed sbctl

sbctl status

sbctl create-keys
sbctl enroll-keys --yes-this-might-brick-my-machine
sbctl verify

set +e
sbctl sign -s /boot/vmlinuz-linux
sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI
sbctl sign -s /boot/EFI/Linux/arch-linux.efi
set -e

sbctl status
sbctl verify

mkinitcpio -P
