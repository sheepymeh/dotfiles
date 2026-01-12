#!/bin/sh
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
	echo "Script must be run as root"
	exit
fi

pacman -S --noconfirm --needed sbctl

sbctl status

sbctl create-keys
sbctl enroll-keys --yes-this-might-brick-my-machine
sbctl verify

sbctl sign -s /boot/vmlinuz-linux
sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI
sbctl sign -s /boot/EFI/systemd/systemd-bootx64.efi
sbctl sign -s /boot/EFI/Linux/arch-linux.efi
sbctl sign -s -o /usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed /usr/lib/systemd/boot/efi/systemd-bootx64.efi

sbctl status
sbctl verify
