#!/bin/sh

pacman -S virt-manager dnsmasq qemu-desktop edk2-ovmf swtpm
usermod -aG libvirt "$SUDO_USER"

echo 'firewall_backend = "iptables"' >> /etc/libvirt/network.conf

systemctl enable --now libvirtd.service
virsh net-autostart default
