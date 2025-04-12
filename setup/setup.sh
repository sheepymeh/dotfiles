#!/bin/sh
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
	echo "Script must be run as root"
	exit
fi
if [[ $(basename "$PWD") != "setup" ]]; then
	echo "Script must be run from /setup"
	exit
fi
cd ..

sed -i 's$#Color$Color\nILoveCandy$' /etc/pacman.conf # pacman color output
sed -i 's$#ParallelDownloads$ParallelDownloads$' /etc/pacman.conf # pacman parallel downloads
mkdir -p /etc/pacman.d/hooks
cp pacman-hooks/chromium-no-defaults.hook /etc/pacman.d/hooks

sed -i '/deny = /c\deny = 6' /etc/security/faillock.conf # increase allowed failed attempt count

pacman -Syyu --noconfirm
pacman -Sq --noconfirm --needed \
	acpi acpid acpi_call bash-completion bat curl dialog gnome-keyring jq brightnessctl man-db nano plymouth ufw linux-firmware wget \
	firefox imv mpv signal-desktop thunderbird \
	fastfetch htop mission-center nvtop \
	cups cups-pdf system-config-printer \
	playerctl pipewire pipewire-pulse pamixer pavucontrol \
	inter-font noto-fonts-cjk papirus-icon-theme ttf-font-awesome ttf-jetbrains-mono otf-crimson-pro \
	exfat-utils engrampa ffmpegthumbnailer gvfs gvfs-mtp owncloud-client tumbler thunar thunar-archive-plugin xdg-user-dirs 7zip \
	libreoffice-fresh hunspell hunspell-en_us hunspell-de gutenprint \
	fcitx5 fcitx5-rime rime-pinyin-simp fcitx5-mozc \
	grim i3blocks mako qt6-wayland slurp sway swaybg swayidle swaylock wf-recorder wl-clipboard wofi xdg-desktop-portal xdg-desktop-portal-wlr polkit-gnome \
	foot android-tools podman git go sqlite \
	tesseract tesseract-data-eng \
	texlive-basic texlive-binextra texlive-latex texlive-latexrecommended texlive-latexextra texlive-fontsrecommended texlive-mathscience \
	python-beautifulsoup4 python-build python-ipykernel python-pip python-numpy python-pytorch-opt python-torchvision python-pillow python-opencv python-scikit-learn python-flask python-aiohttp python-pycryptodome python-tqdm python-pymupdf uv \
	jupyter-notebook python-ipywidgets jupyterlab-widgets \
	ocaml opam dune \
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
	autotiling papirus-folders-catppuccin-git python-catppuccin signal-desktop-fix-sway visual-studio-code-bin wob

# Install wine if multilib is enabled
pacman -Ss '^wine$' && \
	sudo -u "$SUDO_USER" yay -Sq --noconfirm --needed --sudoloop \
	wine wine-gecko wine-mono mangohud dxvk-bin vkd3d-proton-bin lib32-vulkan-radeon lib32-gnutls

yay -Scc --noconfirm

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
	# sudo -u "$SUDO_USER" yay -Sq --noconfirm --needed intel-hybrid-codec-driver
	sed -i '/^MODULES=(.*i915/b; s/MODULES=(/MODULES=(i915 /' /etc/mkinitcpio.conf
fi
if lspci -k | grep -A 2 -E '(VGA|3D)' | grep -qi amd; then
	pacman -Sq --noconfirm --needed libva-mesa-driver mesa-vdpau mesa vulkan-radeon
	sed -i '/^MODULES=(/ { /amdgpu/! s/MODULES=(/MODULES=(amdgpu / }' /etc/mkinitcpio.conf
fi

usermod -aG video "$SUDO_USER"
usermod -aG input "$SUDO_USER"

# Plymouth boot splash screen
git clone https://github.com/sheepymeh/plymouth-theme-arch-agua
cp -r plymouth-theme-arch-agua /usr/share/plymouth/themes/arch-agua
rm -rf plymouth-theme-arch-agua
sed -i '/^HOOKS=(/ { /plymouth/! s/encrypt/plymouth encrypt/ }' /etc/mkinitcpio.conf
sed -i 's/ )$/)/' /etc/mkinitcpio.conf
plymouth-set-default-theme -R arch-agua

papirus-folders -C cat-mocha-mauve --theme Papirus-Dark

sed -i 's/^#SystemMaxUse=$/SystemMaxUse=200M/' /etc/systemd/journald.conf
sed -i 's/^#MaxRetentionSec=0$/MaxRetentionSec=7d/' /etc/systemd/journald.conf

# Quiet boot
sed -i 's$timeout 3$timeout 0$' /boot/loader/loader.conf
sed -i '/^options .* quiet/b; /^options / s/$/ quiet splash loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3/' /boot/loader/entries/*.conf
bootctl update --graceful
systemctl enable --now systemd-boot-update.service

sed -i "s/PKGEXT=.*/PKGEXT='.pkg.tar'/g" /etc/makepkg.conf
sed -i "s/SRCEXT=.*/SRCEXT='.src.tar'/g" /etc/makepkg.conf

# Configure podman
touch /etc/subuid /etc/subgid
usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$SUDO_USER"
echo 'unqualified-search-registries = ["docker.io"]' >>/etc/containers/registries.conf

systemctl enable --now ufw
ufw logging off
ufw enable

# Wayland env vars
cat <<EOF >>/etc/environment
SDL_VIDEODRIVER=wayland
GDK_BACKEND=wayland
QT_QPA_PLATFORM=wayland
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
XDG_CURRENT_DESKTOP=sway
XDG_SESSION_TYPE=wayland
ELECTRON_OZONE_PLATFORM_HINT=auto
_JAVA_AWT_WM_NONREPARENTING=1
WINEDEBUG=-all

PYTORCH_NO_HIP_MEMORY_CACHING=1
HSA_DISABLE_FRAGMENT_ALLOCATOR=1
TORCH_BLAS_PREFER_HIPBLASLT=0
HSA_OVERRIDE_GFX_VERSION=9.0.0

ANV_VIDEO_DECODE=1
RADV_PERFTEST=video_decode,video_encode
EOF

# Edge TPU udev rules
# cat <<EOF >/usr/lib/udev/rules.d/60-edgetpu.rules
# SUBSYSTEM=="apex", MODE="0660", GROUP="plugdev"
# SUBSYSTEM=="usb",ATTRS{idVendor}=="1a6e",GROUP="plugdev"
# SUBSYSTEM=="usb",ATTRS{idVendor}=="18d1",GROUP="plugdev"
# EOF

# DoT CloudFlare DNS
mkdir -p /etc/systemd/resolved.conf.d/
cat <<EOF >/etc/systemd/resolved.conf.d/dns_over_tls.conf
[Resolve]
DNS=1.1.1.1#cloudflare-dns.com
DNSOverTLS=yes
EOF
systemctl restart systemd-resolved.service

# Enable (REI)SUB
# echo kernel.sysrq = 244 >/etc/sysctl.d/99-sysctl.conf

# Enable TRIM
cryptsetup --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue --persistent refresh root

# Autologin (since LUKS already requires auth)
mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat <<EOF >/etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --skip-login --nonewline --noissue --autologin "$SUDO_USER" --noclear %I linux
EOF

# Enable CUPS
systemctl enable --now cups.service

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen
cat <<EOF >/etc/locale.conf
LANG=en_US.UTF-8
LC_TIME=en_GB.UTF-8
EOF
locale-gen

# Notes:
# https://bbs.archlinux.org/viewtopic.php?id=257315
# https://www.kernel.org/doc/Documentation/cpu-freq/boost.txt
