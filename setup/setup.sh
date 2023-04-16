#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
	echo "Script must be run as root"
	exit
fi
if [[ $(basename "$PWD") != "setup" ]]; then
	echo "Script must be run from /setup"
	exit
fi
cd .. # Script should be run from /setup

sed -i 's$#Color$Color\nILoveCandy$' /etc/pacman.conf # pacman color output
sed -i 's$#ParallelDownloads$ParallelDownloads$' /etc/pacman.conf # pacman parallel downloads

sed -i '/deny = /c\deny = 0' /etc/security/faillock.conf # turn off disabling accounts after 3 failed login attempts

pacman -Syyu
pacman -Sq --noconfirm --needed acpi acpid acpi_call bash-completion cups-pdf dialog firefox gnome-keyring htop i3blocks imv jq light nano neofetch nextcloud-client nvtop p7zip s-tui ufw linux-firmware wget
pacman -Sq --noconfirm --needed mpv playerctl pipewire pipewire-pulse pamixer # consider switching pamixer to wpctl
pacman -Sq --noconfirm --needed inter-font noto-fonts-cjk papirus-icon-theme ttf-font-awesome ttf-jetbrains-mono otf-crimson-pro
pacman -Sq --noconfirm --needed exfat-utils ffmpegthumbnailer gvfs gvfs-mtp tumbler thunar xdg-user-dirs
pacman -Sq --noconfirm --needed libreoffice-fresh hunspell hunspell-en_us hunspell-de
pacman -Sq --noconfirm --needed alacritty android-tools podman git go nodejs npm python-pip
pacman -Sq --noconfirm --needed grim mako qt5-wayland slurp sway swaybg swayidle swaylock wf-recorder wl-clipboard wofi xdg-desktop-portal xdg-desktop-portal-wlr # xwayland: xorg-server xorg-server-xwayland xorg-xrandr

cat <<EOF >/etc/acpi/events/ac
event=ac_adapter
action=pkill -SIGRTMIN+3 i3blocks
EOF
sed -i 's/^/#/' /etc/acpi/events/anything
systemctl enable --now acpid

# Bluetooth detection does not work
if [[ $(rfkill list bluetooth | head -c1 | wc -c) -ne 0 ]] 2>&1; then
	pacman -Sq --noconfirm --needed blueman bluez-utils
	systemctl --quiet enable --now bluetooth
	usermod -aG rfkill "$SUDO_USER"
fi

# Install yay-bin
if ! command -v yay &> /dev/null; then
	su -c "echo MAKEFLAGS="-j$(nproc)" >/home/"$SUDO_USER"/.makepkg.conf" "$SUDO_USER" # Multithreaded AUR build
	su -c "git clone https://aur.archlinux.org/yay-bin.git" "$SUDO_USER"
	cd yay-bin
	sudo -u "$SUDO_USER" makepkg -si --noconfirm
	cd ..
	rm -rf yay-bin
fi
wget -qO - https://keys.openpgp.org/vks/v1/by-fingerprint/5C6DA024DDE27178073EA103F4B432D5D67990E3 | gpg --import # Key for wob
sudo -u "$SUDO_USER" yay -Sq --noconfirm --needed autotiling catppuccin-gtk-theme-mocha libinput-gestures papirus-folders-catppuccin-git plymouth vscodium-bin vscodium-bin-features vscodium-bin-marketplace wob # Install AUR packages

# Build and install i3blocks scripts
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
chmod a+x /usr/local/bin/record.sh
cp scripts/mic.sh /usr/local/bin
chmod a+x /usr/local/bin/mic.sh
cp scripts/network.sh /usr/local/bin
chmod a+x /usr/local/bin/network.sh
mkdir -p /etc/pacman.d/hooks

# Install iwd-wofi
git clone --depth=1 https://github.com/sheepymeh/iwd_wofi.git
cd iwd_wofi
pip install -qU build
python -m build -w
pip install -q dist/iwd_wofi-*-py3-none-any.whl

# Install microcode updates as needed
if [ "$(grep -m1 vendor_id /proc/cpuinfo | cut -f2 -d':' | cut -c 2-)" == 'AuthenticAMD' ]; then
	pacman -Sq --noconfirm --needed amd-ucode
elif [ "$(grep -m1 vendor_id /proc/cpuinfo | cut -f2 -d':' | cut -c 2-)" == 'GenuineIntel' ]; then
	pacman -Sq --noconfirm --needed intel-ucode
fi

# Video drivers
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -qi nvidia; then
	pacman -Sq --noconfirm --needed nvidia nvidia-utils
	systemctl enable nvidia-{suspend,hibernate}
	echo options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp >/etc/modprobe.d/nvidia-power-management.conf

	cat <<EOF >/etc/pacman.d/hooks/nvidia.hook
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case \$trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOF
	sed -i '/^options/ s/$/ nvidia_drm.modeset=1/' /boot/loader/entries/*.conf
	sed -i '/^MODULES=(.*nvidia nvidia_modeset nvidia_uvm nvidia_drm/b; s/MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
	cat <<EOF >>/etc/environment
GBM_BACKEND=nvidia-drm
WLR_NO_HARDWARE_CURSORS=1
__GLX_VENDOR_LIBRARY_NAME=nvidia
__GL_ExperimentalPerfStrategy=1
EOF

	# Nvidia Optimus for battery operated devices
	if [ -d /proc/acpi/battery/BAT* ]; then
		usermod -aG bumblebee "$SUDO_USER"
		systemctl enable --now bumblebeed.service
		echo 'options bbswitch load_state=0 unload_state=1' >/etc/modprobe.d/bbswitch.conf
	fi
fi
if lspci -k | grep -A 2 -E '(VGA|3D)' | grep -qi intel; then
	pacman -Sq --noconfirm --needed intel-media-driver libva-intel-driver
	sudo -u "$SUDO_USER" yay -Sq --noconfirm --needed intel-hybrid-codec-driver
	sed -i '/^MODULES=(.*i915/b; s/MODULES=(/MODULES=(i915 /' /etc/mkinitcpio.conf
fi
if lspci -k | grep -A 2 -E '(VGA|3D)' | grep -qi amd; then
	pacman -Sq --noconfirm --needed libva-mesa-driver mesa-vdpau mesa
	sed -i '/^MODULES=(.*amdgpu/b; s/MODULES=(/MODULES=(amdgpu /' /etc/mkinitcpio.conf
fi
usermod -aG video "$SUDO_USER"

usermod -aG input "$SUDO_USER"

# Plymouth boot splash screen
git clone https://github.com/sheepymeh/plymouth-theme-arch-agua
cp -r plymouth-theme-arch-agua /usr/share/plymouth/themes/arch-agua
sed -i '/^HOOKS=(/ s/encrypt/ plymouth plymouth-encrypt/' /etc/mkinitcpio.conf
plymouth-set-default-theme -R arch-agua

sed -i 's$timeout 3$timeout 0$' /boot/loader/loader.conf

# Quiet boot
sed -i '/^options .* quiet/b; /^options / s/$/ quiet splash loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3/' /boot/loader/entries/*.conf

# TRIM
sed -i 's/:luksdev /:luksdev:allow-discards /' /boot/loader/entries/*.conf
sed -i 's/issue_discards = 0/issue_discards = 1/' /etc/lvm/lvm.conf
systemctl enable fstrim.timer

bootctl update --graceful
mkinitcpio -P

# Configure podman
touch /etc/subuid /etc/subgid
usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$SUDO_USER"
echo 'unqualified-search-registries = ["docker.io"]' >>/etc/containers/registries.conf

ufw enable
systemctl enable --now ufw

# Wayland env vars
cat <<EOF >>/etc/environment
SDL_VIDEODRIVER=wayland
GDK_BACKEND=wayland
MOZ_ENABLE_WAYLAND=1
QT_QPA_PLATFORM=wayland-egl
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
XDG_CURRENT_DESKTOP=sway
XDG_SESSION_TYPE=wayland
EOF

# DoT CloudFlare DNS
mkdir -p /etc/systemd/resolved.conf.d/
cat <<EOF >/etc/systemd/resolved.conf.d/dns_over_tls.conf
[Resolve]
DNS=1.1.1.1#cloudflare-dns.com
DNSOverTLS=yes
EOF
systemctl restart systemd-resolved.service

# Enable (REI)SUB
echo kernel.sysrq = 176 >>/etc/sysctl.d/99-sysctl.conf

# Autologin (since LUKS already requires auth)
mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat <<EOF >/etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --skip-login --nonewline --noissue --autologin "$SUDO_USER" --noclear %I linux
EOF

su -c './setup/setup-home.sh' "$SUDO_USER"

# Update Pacman hooks
cat <<EOF >/etc/pacman.d/hooks/chromium-no-defaults.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = chromium
Target = ungoogled-chromium-bin

[Action]
Description = Removing defaults for Chromium
When = PostTransaction
Exec = /usr/bin/sed -i '/MimeType/d' /usr/share/applications/chromium.desktop
NeedsTargets
EOF
cat <<EOF >/etc/pacman.d/hooks/electron-wayland.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = vscodium-bin
Target = chromium
Target = ungoogled-chromium-bin
Target = signal-desktop

[Action]
Description = Adding Wayland flags for Electron
When = PostTransaction
Exec = /usr/local/sbin/electron-wayland.sh
NeedsTargets
EOF
cat <<EOF >/usr/local/sbin/electron-wayland.sh
#!/bin/sh
read pkgname
if ! pacman -Qq "$pkgname" >/dev/null 2>&1; then
	echo 'package not found'
	exit 1
fi
SAVEIFS=$IFS
IFS=$'\n'
DESKTOP_FILES=($(pacman -Qql "$pkgname" | grep '\.desktop$'))
IFS=$SAVEIFS
for (( i=0; i<${#DESKTOP_FILES[@]}; i++ )); do
	if ! grep -q ' --enable-features=UseOzonePlatform --ozone-platform=wayland ' "${DESKTOP_FILES[$i]}"; then
		perl -i -pe 's/^Exec=(\S+?)[ \n]/Exec=$1 --enable-features=UseOzonePlatform --ozone-platform=wayland /' "${DESKTOP_FILES[$i]}"
	fi
done
EOF
chmod +x /usr/local/sbin/electron-wayland.sh

# Notes:
# https://bbs.archlinux.org/viewtopic.php?id=257315
# https://www.kernel.org/doc/Documentation/cpu-freq/boost.txt
