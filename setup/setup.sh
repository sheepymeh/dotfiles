#!/bin/bash
set -euo pipefail

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
pacman -Sq --noconfirm --needed \
	acpi acpid acpi_call bash-completion bat cups-pdf curl dialog firefox gnome-keyring htop i3blocks imv jq brightnessctl man-db nano neofetch owncloud-client nvtop 7zip plymouth sbctl s-tui system-config-printer thunderbird ufw linux-firmware wget \
	mpv playerctl pipewire pipewire-pulse pamixer \
	inter-font noto-fonts-cjk papirus-icon-theme ttf-font-awesome ttf-jetbrains-mono otf-crimson-pro \
	exfat-utils engrampa ffmpegthumbnailer gvfs gvfs-mtp tumbler thunar thunar-archive-plugin xdg-user-dirs \
	libreoffice-fresh hunspell hunspell-en_us hunspell-de gutenprint \
	fcitx5 fcitx5-rime rime-pinyin-simp fcitx5-mozc \
	grim mako pavucontrol qt5-wayland qt6-wayland slurp sway swaybg swayidle swaylock wf-recorder wl-clipboard wofi xdg-desktop-portal xdg-desktop-portal-wlr \
	foot android-tools podman git go sqlite \
	tesseract tesseract-data-eng \
	python-beautifulsoup4 python-build python-ipykernel python-pip python-numpy python-pytorch-opt python-pillow python-opencv python-scikit-learn python-flask python-aiohttp python-pycryptodome python-pipx python-tqdm python-pymupdf uv \
	jupyter-notebook python-ipywidgets jupyterlab-widgets ocaml opam dune \
	texlive-basic texlive-binextra texlive-latex texlive-latexrecommended texlive-latexextra texlive-fontsrecommended texlive-mathscience \
	nodejs npm typescript wrangler

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
sudo -u "$SUDO_USER" yay -Sq --noconfirm --needed --sudoloop \
	autotiling catppuccin-gtk-theme-mocha papirus-folders-catppuccin-git visual-studio-code-bin wob

pacman -Ss '^wine$' \
	&& sudo -u "$SUDO_USER" yay -Sq --noconfirm --needed --sudoloop \
	wine wine-gecko wine-mono dxvk-bin

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
for script in record.sh mic.sh date.sh dynamic-workspaces.py; do
	cp scripts/"$script" /usr/local/bin
	chmod a+x /usr/local/bin/"$script"
done

# Install microcode updates as needed
if [ "$(grep -m1 vendor_id /proc/cpuinfo | cut -f2 -d':' | cut -c 2-)" == 'AuthenticAMD' ]; then
	pacman -Sq --noconfirm --needed amd-ucode
elif [ "$(grep -m1 vendor_id /proc/cpuinfo | cut -f2 -d':' | cut -c 2-)" == 'GenuineIntel' ]; then
	pacman -Sq --noconfirm --needed intel-ucode
fi

mkdir -p /etc/pacman.d/hooks

# Video drivers
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -qi nvidia; then
	pacman -Sq --noconfirm --needed nvidia nvidia-utils
	systemctl enable nvidia-{suspend,hibernate}
	echo options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp >/etc/modprobe.d/nvidia-power-management.conf
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
	pacman -Sq --noconfirm --needed libva-mesa-driver mesa-vdpau mesa vulkan-radeon
	sed -i '/^MODULES=(.*amdgpu/b; s/MODULES=(/MODULES=(amdgpu /' /etc/mkinitcpio.conf
fi
usermod -aG video "$SUDO_USER"

usermod -aG input "$SUDO_USER"

# Plymouth boot splash screen
git clone https://github.com/sheepymeh/plymouth-theme-arch-agua
cp -r plymouth-theme-arch-agua /usr/share/plymouth/themes/arch-agua
sed -i '/^HOOKS=(/ s/encrypt/plymouth encrypt/' /etc/mkinitcpio.conf
plymouth-set-default-theme -R arch-agua
rm -rf plymouth-theme-arch-agua

sed -i 's$timeout 3$timeout 0$' /boot/loader/loader.conf

# Quiet boot
sed -i '/^options .* quiet/b; /^options / s/$/ quiet splash loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3/' /boot/loader/entries/*.conf
bootctl update --graceful
mkinitcpio -P
systemctl enable --now systemd-boot-update.service

sed -i "s/PKGEXT=.*/PKGEXT='.pkg.tar'/g" /etc/makepkg.conf
sed -i "s/SRCEXT=.*/SRCEXT='.src.tar'/g" /etc/makepkg.conf

# Configure podman
touch /etc/subuid /etc/subgid
usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$SUDO_USER"
echo 'unqualified-search-registries = ["docker.io"]' >>/etc/containers/registries.conf

systemctl enable --now ufw
ufw enable

# Wayland env vars
cat <<EOF >>/etc/environment
SDL_VIDEODRIVER=wayland
GDK_BACKEND=wayland
MOZ_ENABLE_WAYLAND=1
QT_QPA_PLATFORM=wayland-egl
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
XDG_CURRENT_DESKTOP=sway
XDG_SESSION_TYPE=wayland
ELECTRON_OZONE_PLATFORM_HINT=wayland
EOF

# Edge TPU udev rules
cat <<EOF >/usr/lib/udev/rules.d/60-edgetpu.rules
SUBSYSTEM=="apex", MODE="0660", GROUP="plugdev"
SUBSYSTEM=="usb",ATTRS{idVendor}=="1a6e",GROUP="plugdev"
SUBSYSTEM=="usb",ATTRS{idVendor}=="18d1",GROUP="plugdev"
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
echo kernel.sysrq = 244 >/etc/sysctl.d/99-sysctl.conf

sudo cryptsetup --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue --persistent refresh root

# Autologin (since LUKS already requires auth)
mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat <<EOF >/etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --skip-login --nonewline --noissue --autologin "$SUDO_USER" --noclear %I linux
EOF

# Update Pacman hooks
cp pacman-hooks/* /etc/pacman.d/hooks
cp scripts/electron-wayland.sh /usr/local/sbin/electron-wayland.sh
chmod +x /usr/local/sbin/electron-wayland.sh
/usr/local/sbin/electron-wayland.sh <<< visual-studio-code-bin

# Enable CUPS
systemctl enable --now cups.service

# Notes:
# https://bbs.archlinux.org/viewtopic.php?id=257315
# https://www.kernel.org/doc/Documentation/cpu-freq/boost.txt
