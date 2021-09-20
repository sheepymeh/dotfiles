#!/bin/bash
set -e
cd .. # Script should be run from /setup

if [ "$EUID" -ne 0 ]; then
	echo "Script must be run as root"
	exit
fi

sed -i 's$#Color$Color\nILoveCandy$' /etc/pacman.conf
sed -i 's$#ParallelDownloads$ParallelDownloads$' /etc/pacman.conf
sed -i '/deny = /c\deny = 0' /etc/security/faillock.conf

pacman -Syyu
pacman -Sq --noconfirm --needed acpi acpi_call bash-completion cups-pdf dialog firefox gnome-keyring htop i3blocks imv light nano neofetch nextcloud-client p7zip s-tui ufw linux-firmware wget
pacman -Sq --noconfirm --needed gst-plugins-bad gst-plugins-good mpv playerctl pipewire pipewire-pulse pamixer lollypop
pacman -Sq --noconfirm --needed arc-gtk-theme inter-font noto-fonts-cjk papirus-icon-theme ttf-font-awesome ttf-jetbrains-mono
pacman -Sq --noconfirm --needed exfat-utils ffmpegthumbnailer gvfs gvfs-mtp tumbler thunar xdg-user-dirs
pacman -Sq --noconfirm --needed libreoffice-fresh hunspell hunspell-en_us hunspell-de
pacman -Sq --noconfirm --needed alacritty android-tools code podman git go nodejs npm python-pip
pacman -Sq --noconfirm --needed grim mako qt5-wayland slurp swayidle swaylock wf-recorder wl-clipboard wofi xdg-desktop-portal xdg-desktop-portal-wlr xorg-server xorg-server-xwayland xorg-xrandr

if systemctl status bluetooth >/dev/null 2&>1; then
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
	go build scripts/battery.go
	chmod u+s battery
	mv battery /usr/local/bin
fi
if [ -d /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00 ]; then
	go build scripts/perf.go
	chmod u+s perf
	mv perf /usr/local/bin
fi
cp scripts/record.sh /usr/local/bin
cp scripts/mic.sh /usr/local/bin
chmod a+x /usr/local/bin/record.sh
chmod a+x /usr/local/bin/mic.sh

if [ $(grep -m1 vendor_id /proc/cpuinfo | cut -f2 -d':' | cut -c 2-) -eq 'AuthenticAMD' ]; then
	pacman -Sq --noconfirm --needed amd-ucode
elif [ $(grep -m1 vendor_id /proc/cpuinfo | cut -f2 -d':' | cut -c 2-) -eq 'GenuineIntel' ]; then
	pacman -Sq --noconfirm --needed intel-ucode
fi

if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -qi nvidia; then
	echo Using EGLStreams sway fork for NVIDIA driver
	pacman -Sq --noconfirm --needed nvidia nvidia-utils
	sudo -u $SUDO_USER yay -Sq --noconfirm --needed sway-git wlroots-eglstreams-git
	systemctl enable nvidia-{suspend,hibernate,resume}
	echo options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp >/etc/modprobe.d/nvidia-power-management.conf
	sed -i '/^options/ s/$/ nvidia_drm.modeset=1/' /boot/loader/entries/*.conf
	bootctl update
	if [ -d /proc/acpi/battery/BAT* ]; then
		usermod -a -G bumblebee $SUDO_USER
		systemctl enable --now bumblebeed.service
		echo "options bbswitch load_state=0 unload_state=1" >/etc/modprobe.d/bbswitch.conf
	fi
else
	pacman -Sq --noconfirm --needed sway
fi
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -qi intel; then
	pacman -Sq --noconfirm --needed intel-media-driver libva-intel-driver
	sudo -u $SUDO_USER yay -Sq --noconfirm --needed intel-hybrid-codec-driver
fi
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -qi amd; then
	pacman -Sq --noconfirm --needed libva-mesa-driver mesa-vdpau mesa
fi

sed -i 's/:luksdev/:luksdev:allow-discards quiet/' /boot/loader/entries/*.conf
sed -i 's/issue_discards = 0/issue_discards = 1/' /etc/lvm/lvm.conf
systemctl enable fstrim.timer

usermod -a -G video $SUDO_USER
usermod -a -G rfkill $SUDO_USER
#usermod -a -G libvirt $SUDO_USER

touch /etc/subuid /etc/subgid
usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $SUDO_USER
echo 'unqualified-search-registries = ["docker.io"]' >>/etc/containers/registries.conf

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

cp -r config/* /home/$SUDO_USER/.config
mkdir -p /home/$SUDO_USER/.config/Code\ -\ OSS/User
cp code/* /home/$SUDO_USER/.config/Code\ -\ OSS/User
cp bashrc /home/$SUDO_USER/.bashrc
if [ ! -d /sys/class/power_supply/BAT* ]; then
	rm /home/$SUDO_USER/.config/sway/laptop.conf
fi

su -c "git config --global user.name 'sheepymeh'" $SUDO_USER
su -c "git config --global user.email 'sheepymeh@users.noreply.github.com'" $SUDO_USER
su -c "git config --global credential.helper store" $SUDO_USER
