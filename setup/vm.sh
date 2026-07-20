#!/bin/sh
set -eu
if [ -z "$SUDO_USER" ]; then
	echo "This script must be run with sudo"
	exit 1
fi

pacman -S virt-manager dnsmasq qemu-desktop edk2-ovmf swtpm
usermod -aG libvirt "$SUDO_USER"

echo 'firewall_backend = "iptables"' >> /etc/libvirt/network.conf

systemctl enable --now libvirtd.service
virsh net-autostart default
