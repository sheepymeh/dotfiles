#!/bin/sh

pacman -S virt-manager dnsmasq qemu-desktop edk2-ovmf swtpm
usermod -aG libvirt "$SUDO_USER"

sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf
sed -i 's/#unix_sock_rw_perms = "0777"/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf

sed -i "s/#user = \"username\"/user = \"$SUDO_USER\"/" /etc/libvirt/qemu.conf
sed -i 's/#group = "libvirt"/group = "libvirt"/' /etc/libvirt/qemu.conf

echo firewall_backend=iptables >> /etc/libvirt/network.conf

systemctl enable --now libvirtd.service
virsh net-autostart default
