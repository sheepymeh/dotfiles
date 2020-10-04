#!/bin/bash
# BEFORE RUNNING THIS SCRIPT:
# Connect to the internet using iwd:
#   rfkill unblock wlan0
#   station wlan0 scan
#   station wlan0 get-networks
#   station wlan0 connect SSID
# Partition the disk with cfdisk (/boot 260M, /root 100%FREE)

# Prepare system
timedatectl set-ntp true
wget "https://www.archlinux.org/mirrorlist/?country=SG&country=JP&protocol=https&ip_version=4" -O /etc/pacman.d/mirrorlist
sed -i 's$#Server$Server$' /etc/pacman.d/mirrorlist
sed -i 's$#Color$Color\nILoveCandy$' /etc/pacman.conf

# Format partitions
mkfs.vfat -F32 /dev/nvme0n1p1
cryptsetup -v luksFormat /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2 luks
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mapper/luks
lvcreate -l +100%FREE vg0 -n root
mkfs.ext4 /dev/mapper/vg0-root
mount /dev/mapper/vg0-root /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

# Install & chroot
pacstrap /mnt base base-devel linux linux-firmware
genfstab -pU /mnt >> /mnt/etc/fstab
arch-chroot /mnt

# Locale
ln -sf /usr/share/zoneinfo/Asia/Singapore /etc/localtime
hwclock --systohc
sed -i 's$#en_US.UTF-8 UTF-8$en_US.UTF-8 UTF-8$' /etc/pacman.conf
sed -i 's$#en_US ISO-8859-1$en_US ISO-8859-1$' /etc/pacman.conf
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
echo "koito" > /etc/hostname
echo "127.0.0.1	koito.localdomain	koito" > /etc/hosts

# Install required packages
pacman -S --noconfirm --needed acpi acpi_call alacritty alsa-utils amd-ucode android-tools arc-gtk-theme avahi bash-completion blueman bluez-utils code cups-pdf dialog exfat-utils firefox git gnome-keyring grim gst-plugins-bad gst-plugins-good gvfs gvfs-mtp htop i3blocks imv amd-ucode inter-font libva-mesa-driver light lollypop lvm2 mako mesa mesa-vdpau nano neofetch networkmanager nextcloud-client nodejs npm p7zip papirus-icon-theme pulseaudio-alsa pulseaudio-bluetooth python-pip qt5-wayland s-tui sed slurp sudo sway swayidle swaylock thunar ttf-font-awesome ttf-jetbrains-mono ufw wf-recorder wget wl-clipboard xdg-user-dirs xorg-server xorg-server-xwayland xorg-xrandr
pacman -S qemu virt-manager iptables ebtables dnsmasq
systemctl enable libvirtd.service
sed -i 's$#unix_sock_group = "libvirt"$unix_sock_group = "libvirt"$' /etc/libvirt/libvirtd.conf
pacman -S --noconfirm --needed wireshark-qt volatility gnu-netcat sqlmap
pip install pwntools
systemctl enable networkmanager

# Install scripts
chmod 755 battery.sh
chmod 755 perf.sh
mv battery.sh /usr/local/sbin/battery.sh
mv perf.sh /usr/local/sbin/perf.sh

# Set up systemd-boot
bootctl --path=/boot/ install
cat <<EOF | tee /boot/loader/loader.conf
default arch
timeout 0
editor 0
EOF
cat <<EOF | tee /boot/loader/entries/arch.conf
title	Arch Linux
linux	/vmlinuz-linux
initrd	/amd-ucode.img
initrd	/initramfs-linux.img
options	cryptdevice=UUID=$(blkid /dev/nvme0n1p2 -s "UUID" -o value):vg0:allow-discards root=/dev/mapper/vg0-root quiet rw
EOF
bootctl status

cat <<EOF | tee /etc/pacman.d/hooks/100-systemd-boot.hook
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl update
EOF

# Set up userland
useradd -m -G wheel -s /bin/bash sheepymeh
passwd sheepymeh
EDITOR=/usr/bin/nano visudo
usermod -a -G video sheepymeh
usermod -a -G rfkill sheepymeh
usermod -a -G libvirt sheepymeh
mkdir /home/sheepymeh/dotfiles
mv * /home/shpeepymeh/dotfiles
cat <<EOF | tee -a /etc/environment
MOZ_ENABLE_WAYLAND=1
QT_QPA_PLATFORM=wayland-egl
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
EOF
mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat <<EOF | tee /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin sheepymeh --noclear %I linux
EOF

# AFTER RUNNING THIS SCRIPT:
# Edit mkinitcpio
#   nano /etc/mkinitcpio.conf
#   mkinitcpio -p linux
# Unmount the disks
#   Ctrl + D
#   umount -R /mnt
# Reboot
