#!/bin/bash
set -e

sed -i 's$#Color$Color\nILoveCandy$' /etc/pacman.conf
sed -i 's$#ParallelDownloads$ParallelDownloads$' /etc/pacman.conf

pacman -Sq --noconfirm --needed acpi acpi_call bash-completion cups-pdf dialog firefox gnome-keyring htop i3blocks imv light nano neofetch networkmanager nextcloud-client p7zip s-tui ufw linux-firmware wget
pacman -Sq --noconfirm --needed gst-plugins-bad gst-plugins-good lollypop
pacman -Sq --noconfirm --needed arc-gtk-theme inter-font noto-fonts-cjk papirus-icon-theme ttf-font-awesome ttf-jetbrains-mono
pacman -Sq --noconfirm --needed exfat-utils gvfs gvfs-mtp thunar xdg-user-dirs
pacman -Sq --noconfirm --needed alacritty android-tools code docker git nodejs npm python-pip
pacman -Sq --noconfirm --needed grim mako qt5-wayland slurp sway swayidle swaylock wf-recorder wl-clipboard wofi xdg-desktop-portal xdg-desktop-portal-wlr xorg-server xorg-server-xwayland xorg-xrandr
#something wrong with this line
#pacman -Sq --noconfirm --needed qemu virt-manager iptables ebtables dnsmasq
pacman -Sq --noconfirm --needed wireshark-qt volatility gnu-netcat

systemctl --quiet enable --now NetworkManager

if [[ ! $(rfkill list bluetooth) ]]; then
	pacman -Sq --noconfirm --needed blueman bluez-utils
	systemctl --quiet enable --now bluetooth
fi
#systemctl --quiet enable --now libvirtd.service
#sed -i 's$#unix_sock_group = "libvirt"$unix_sock_group = "libvirt"$' /etc/libvirt/libvirtd.conf

if ! command -v yay &> /dev/null; then
	sudo -u sheepymeh git clone https://aur.archlinux.org/yay-bin.git
	cd yay-bin
	sudo -u sheepymeh makepkg -si
	cd ..
fi
wget -q https://keys.openpgp.org/vks/v1/by-fingerprint/5C6DA024DDE27178073EA103F4B432D5D67990E3
gpg --import 5C6DA024DDE27178073EA103F4B432D5D67990E3
rm 5C6DA024DDE27178073EA103F4B432D5D67990E3
sudo -u sheepymeh yay -Sq --noconfirm --needed wob steghide ffuf

if [ -d /proc/acpi/battery/BAT* ]; then
	chmod 755 battery.sh
	mv battery.sh /usr/local/sbin/battery.sh
fi
if [ -d /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00 ]; then
	chmod 755 perf.sh
	mv perf.sh /usr/local/sbin/perf.sh
fi

if [ $(grep -m1 vendor_id /proc/cpuinfo | cut -f2 -d':' | cut -c 2-) -eq 'AuthenticAMD' ]; then
	pacman -Sq --noconfirm --needed amd-ucode
elif [ $(grep -m1 vendor_id /proc/cpuinfo | cut -f2 -d':' | cut -c 2-) -eq 'GenuineIntel' ]; then
	pacman -Sq --noconfirm --needed intel-ucode
fi

if [ $(lspci -k | grep -A 2 -E "(VGA|3D)" | grep -i nvidia | wc -l) -gt 0 ]; then
	pacman -Sq --noconfirm --needed nvidia nvidia-utils
	if [ -d /proc/acpi/battery/BAT* ]; then
		sudo usermod -a -G bumblebee sheepymeh
		sudo systemctl enable --now bumblebeed.service
		echo "options bbswitch load_state=0 unload_state=1" | sudo tee /etc/modprobe.d/bbswitch.conf
	fi
fi
if [ $(lspci -k | grep -A 2 -E "(VGA|3D)" | grep -i intel | wc -l) -gt 0 ]; then
	pacman -Sq --noconfirm --needed intel-media-driver libva-intel-driver
	sudo -u sheepymeh yay -Sq --noconfirm --needed intel-hybrid-codec-driver
fi
if [ $(lspci -k | grep -A 2 -E "(VGA|3D)" | grep -i amd | wc -l) -gt 0 ]; then
	pacman -Sq --noconfirm --needed libva-mesa-driver mesa-vdpau mesa
fi

usermod -a -G video sheepymeh
usermod -a -G rfkill sheepymeh
#usermod -a -G libvirt sheepymeh
usermod -a -G docker sheepymeh
cat <<EOF | tee -a /etc/environment
MOZ_ENABLE_WAYLAND=1
QT_QPA_PLATFORM=wayland-egl
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
XDG_CURRENT_DESKTOP=sway
XDG_SESSION_TYPE=wayland
EOF
mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat <<EOF | tee /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin sheepymeh --noclear %I linux
EOF

sudo -u sheepymeh git config --global user.name 'sheepymeh'
sudo -u sheepymeh git config --global user.email 'sheepymeh@users.noreply.github.com'
sudo -u sheepymeh git config --global credential.helper store

sudo -u sheepymeh mkdir -p /home/sheepymeh/.config/sway /home/sheepymeh/.config/swaylock /home/sheepymeh/.config/wofi /home/sheepymeh/.config/alacritty /home/sheepymeh/.config/mako /home/sheepymeh/.config/i3blocks
sudo -u sheepymeh mv sway.conf /home/sheepymeh/.config/sway/config
sudo -u sheepymeh mv swaylock.conf /home/sheepymeh/.config/swaylock/config
sudo -u sheepymeh mv alacritty.yml /home/sheepymeh/.config/alacritty/alacritty.yml
sudo -u sheepymeh mv wofi.conf /home/sheepymeh/.config/wofi/config
sudo -u sheepymeh mv wofi.css /home/sheepymeh/.config/wofi/style.css
sudo -u sheepymeh mv i3blocks.conf /home/sheepymeh/.config/i3blocks/config
sudo -u sheepymeh mv mako.conf /home/sheepymeh/.config/mako/config
sudo -u sheepymeh mv gtk-2.0 /home/sheepymeh/.gtkrc-2.0
sudo -u sheepymeh mv bashrc /home/sheepymeh/.bashrc
