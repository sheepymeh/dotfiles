#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
	echo "Script must be run as root"
	exit
fi

sed -i 's$#Color$Color\nILoveCandy$' /etc/pacman.conf
sed -i 's$#ParallelDownloads$ParallelDownloads$' /etc/pacman.conf
sed -i '/deny = /c\deny = 0' /etc/security/faillock.conf

pacman -Syyu
pacman -Sq --noconfirm --needed acpi acpi_call bash-completion cups-pdf dialog firefox gnome-keyring htop i3blocks imv light nano neofetch nextcloud-client p7zip s-tui ufw linux-firmware wget
pacman -Sq --noconfirm --needed gst-plugins-bad gst-plugins-good playerctl pipewire pipewire-pulse pamixer lollypop
pacman -Sq --noconfirm --needed arc-gtk-theme inter-font noto-fonts-cjk papirus-icon-theme ttf-font-awesome ttf-jetbrains-mono
pacman -Sq --noconfirm --needed exfat-utils ffmpegthumbnailer gvfs gvfs-mtp tumbler thunar xdg-user-dirs
pacman -Sq --noconfirm --needed alacritty android-tools code docker git go nodejs npm python-pip
pacman -Sq --noconfirm --needed grim mako qt5-wayland slurp sway swayidle swaylock wf-recorder wl-clipboard wofi xdg-desktop-portal xdg-desktop-portal-wlr xorg-server xorg-server-xwayland xorg-xrandr

if rfkill list bluetooth >/dev/null 2&>1; then
	pacman -Sq --noconfirm --needed blueman bluez-utils
	systemctl --quiet enable --now bluetooth
fi

if ! command -v yay &> /dev/null; then
	su -c "git clone https://aur.archlinux.org/yay-bin.git" $SUDO_USER
	cd yay-bin
	sudo -u $SUDO_USER makepkg -si
	cd ..
fi
wget -qO - https://keys.openpgp.org/vks/v1/by-fingerprint/5C6DA024DDE27178073EA103F4B432D5D67990E3 | gpg --import

sudo -u $SUDO_USER yay -Sq --noconfirm --needed autotiling wob

if [ -d /sys/class/power_supply/BAT* ]; then
	go build battery.go
	chmod u+s battery
	mv battery /usr/local/bin
fi
if [ -d /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00 ]; then
	go build perf.go
	chmod u+s perf
	mv perf /usr/local/bin
fi

if [ $(grep -m1 vendor_id /proc/cpuinfo | cut -f2 -d':' | cut -c 2-) -eq 'AuthenticAMD' ]; then
	pacman -Sq --noconfirm --needed amd-ucode
elif [ $(grep -m1 vendor_id /proc/cpuinfo | cut -f2 -d':' | cut -c 2-) -eq 'GenuineIntel' ]; then
	pacman -Sq --noconfirm --needed intel-ucode
fi

if [ $(lspci -k | grep -A 2 -E "(VGA|3D)" | grep -i nvidia | wc -l) -gt 0 ]; then
	echo NVIDIA Drivers in use, will not boot
	pacman -Sq --noconfirm --needed nvidia nvidia-utils
	if [ -d /proc/acpi/battery/BAT* ]; then
		usermod -a -G bumblebee $SUDO_USER
		systemctl enable --now bumblebeed.service
		echo "options bbswitch load_state=0 unload_state=1" >/etc/modprobe.d/bbswitch.conf
	fi
fi
if [ $(lspci -k | grep -A 2 -E "(VGA|3D)" | grep -i intel | wc -l) -gt 0 ]; then
	pacman -Sq --noconfirm --needed intel-media-driver libva-intel-driver
	su -c "yay -Sq --noconfirm --needed intel-hybrid-codec-driver" $SUDO_USER
fi
if [ $(lspci -k | grep -A 2 -E "(VGA|3D)" | grep -i amd | wc -l) -gt 0 ]; then
	pacman -Sq --noconfirm --needed libva-mesa-driver mesa-vdpau mesa
fi

sed -i 's/:luksdev/:luksdev:allow-discards quiet/' /boot/loader/entries/*.conf
sed -i 's/issue_discards = 0/issue_discards = 1/' /etc/lvm/lvm.conf
systemctl enable fstrim.timer

usermod -a -G video $SUDO_USER
usermod -a -G rfkill $SUDO_USER
#usermod -a -G libvirt $SUDO_USER
usermod -a -G docker $SUDO_USER
cat <<EOF >>/etc/environment
MOZ_ENABLE_WAYLAND=1
QT_QPA_PLATFORM=wayland-egl
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
XDG_CURRENT_DESKTOP=sway
XDG_SESSION_TYPE=wayland
EOF
mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat <<EOF >/etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $SUDO_USER --noclear %I linux
EOF

su -c "xdg-user-dirs-update" $SUDO_USER
rm -rf /home/$SUDO_USER/Desktop /home/$SUDO_USER/Templates /home/$SUDO_USER/Public /home/$SUDO_USER/Documents /home/$SUDO_USER/Music
su -c "xdg-user-dirs-update" $SUDO_USER

su -c "git config --global user.name 'sheepymeh'" $SUDO_USER
su -c "git config --global user.email 'sheepymeh@users.noreply.github.com'" $SUDO_USER
su -c "git config --global credential.helper store" $SUDO_USER

su -c "mkdir -p ~/.config/sway ~/.config/swaylock ~/.config/wofi ~/.config/alacritty ~/.config/mako ~/.config/i3blocks ~/.config/gtk-3.0 '~/.config/Code - OSS/User/' ~/.config/Thunar" $SUDO_USER
su -c "mv sway/config ~/.config/sway/config" $SUDO_USER
su -c "mv swaylock.conf ~/.config/swaylock/config" $SUDO_USER
su -c "mv alacritty.yml ~/.config/alacritty/alacritty.yml" $SUDO_USER
su -c "mv wofi.conf ~/.config/wofi/config" $SUDO_USER
su -c "mv wofi.css ~/.config/wofi/style.css" $SUDO_USER
su -c "mv i3blocks.conf ~/.config/i3blocks/config" $SUDO_USER
su -c "mv mako.conf ~/.config/mako/config" $SUDO_USER
su -c "mv gtk-2.0 ~/.gtkrc-2.0" $SUDO_USER
su -c "mv gtk-3.0 ~/.config/gtk-3.0/settings.ini" $SUDO_USER
su -c "mv bashrc ~/.bashrc" $SUDO_USER
su -c "mv uca.xml ~/.config/Thunar/uca.xml" $SUDO_USER
su -c "mv code/keybindings.json '~/.config/Code - OSS/User/'" $SUDO_USER
su -c "mv code/settings.json '~/.config/Code - OSS/User/'" $SUDO_USER
if [ -d /sys/class/power_supply/BAT* ]; then
	su -c "mv sway/laptop.conf ~/.config/sway/laptop.conf" $SUDO_USER
fi
