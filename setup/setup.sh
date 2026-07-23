#!/bin/bash
set -Eeuo pipefail
if [ -z "$SUDO_USER" ]; then
	echo "This script must be run with sudo"
	exit 1
fi
cd "$(dirname -- "$0")/.."

cleanup() {
	trap - EXIT INT TERM ERR
	rm -f "/etc/sudoers.d/temp-setup"
	kill 0
}
trap cleanup EXIT INT TERM ERR

BATTERY_PATH=
for supply in /sys/class/power_supply/*; do
	if [ -f "$supply/type" ] && [ "$(cat "$supply/type")" = "Battery" ]; then
		BATTERY_PATH="$supply"
		break
	fi
done

pi () { pacman -Sq --noconfirm --needed "$@"; }


# shellcheck disable=SC2120
setup_packages() {
	pi \
		age bash-completion bat brightnessctl curl dialog gnome-keyring jq kernel-modules-hook linux-firmware man-db nano nano-syntax-highlighting \
		autotiling grim i3blocks mako qt6-wayland slurp sway swaybg swayidle swaylock wf-recorder wl-clipboard wl-mirror wofi xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk polkit-gnome wdisplays wob \
		delfin firefox imv mpv signal-desktop thunderbird transmission-gtk \
		htop mission-center s-tui \
		cups cups-pdf gutenprint system-config-printer \
		playerctl pipewire pipewire-pulse pavucontrol \
		inter-font noto-fonts-cjk ttf-jetbrains-mono-nerd otf-crimson-pro \
		exfat-utils engrampa ffmpegthumbnailer gvfs gvfs-mtp owncloud-client tumbler thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman trash-cli unzip xdg-user-dirs 7zip \
		hunspell hunspell-en_us hunspell-de \
		python-pip python-virtualenv jupyter-notebook jupyterlab-widgets python-ipykernel python-ipywidgets python-tqdm \
		fcitx5 fcitx5-rime rime-pinyin-simp fcitx5-mozc \
		android-tools foot impala iwd sqlite shellcheck \
		code verilator

	while [[ $# -gt 0 ]]; do
		case "$1" in
			--torch) pi python-numpy python-pytorch-opt python-torchvision python-pillow python-opencv python-scikit-learn ;;
			--tesseract) pi tesseract tesseract-data-eng ;;
			--tex) pi texlive-basic texlive-binextra texlive-latex texlive-latexrecommended texlive-latexextra texlive-fontsrecommended texlive-mathscience perl-file-homedir perl-yaml-tiny ;;
			--office) pi libreoffice-fresh ;;
			--cloudflare) pi wrangler ;;
			--web) pi eslint eslint-language-server nodejs npm pnpm prettier typescript ;;
			--wine) pi wine wine-gecko mangohud ;;  # dxvk-bin vkd3d-proton-bin
			--python) pi mypy python-pytest python-pytest-aiohttp python-pytest-asyncio python-beautifulsoup4 python-flask python-aiohttp python-pycryptodome python-pymupdf python-pytest-cov python-pydantic python-pylint python-tqdm python-uv pyright ruff ty uv ;;
			--smart)
				pi smartmontools
				systemctl enable --now smartd.service
				cat <<-EOF >/usr/share/smartmontools/smartd_warning.d/smartdnotify
					#!/bin/sh
					/usr/local/bin/notify-user.sh logged-in "S.M.A.R.T Error (\$SMARTD_FAILTYPE)" "\$SMARTD_MESSAGE" dialog-warning
				EOF
				chmod a+x /usr/share/smartmontools/smartd_warning.d/smartdnotify
				sed -i 's/^DEVICESCAN$/DEVICESCAN -a -m @smartdnotify -n standby,15,q/' /etc/smartd.conf
			;;
			--podman)
				pi podman podman-compose
				# Configure userland podman
				touch /etc/subuid /etc/subgid
				usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$SUDO_USER"
				mkdir -p /etc/containers/registries.conf.d
				echo 'unqualified-search-registries = ["docker.io"]' >/etc/containers/registries.conf.d/10-docker-hub.conf
			;;
		esac
		shift
	done

	BT_SYS_PATH="/sys/class/bluetooth"
	if [ -d "$BT_SYS_PATH" ] && [ -n "$(compgen -G "$BT_SYS_PATH/*")" ]; then
		pi blueman bluez-utils
		systemctl --quiet enable --now bluetooth
		usermod -aG rfkill "$SUDO_USER"
	fi

	# Microcode updates
	CPU_VENDOR="$(grep -m1 vendor_id /proc/cpuinfo | cut -f2 -d':' | cut -c 2-)"
	case "$CPU_VENDOR" in
		AuthenticAMD) pi amd-ucode ;;
		GenuineIntel) pi intel-ucode ;;
	esac

	# Video drivers
	if lspci -k | grep -A 2 -E '(VGA|3D|Graphics)' | grep -qi nvidia; then
		pi nvidia nvidia-utils
		systemctl enable nvidia-{suspend,hibernate}
		echo options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp >/etc/modprobe.d/nvidia-power-management.conf
		echo 'nvidia_drm.modeset=1' >/etc/cmdline.d/20-nvidia.conf
		cat <<-EOF >/etc/mkinitcpio.conf.d/20-nvidia.conf
			MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
		EOF
		grep -q GBM_BACKEND /etc/environment || cat <<-EOF >>/etc/environment
			GBM_BACKEND=nvidia-drm
			WLR_NO_HARDWARE_CURSORS=1
			__GLX_VENDOR_LIBRARY_NAME=nvidia
			__GL_ExperimentalPerfStrategy=1
		EOF

		# Nvidia Optimus for battery operated devices
		if [ -n "$BATTERY_PATH" ]; then
			usermod -aG bumblebee "$SUDO_USER"
			systemctl enable --now bumblebeed.service
			echo 'options bbswitch load_state=0 unload_state=1' >/etc/modprobe.d/bbswitch.conf
		fi
	fi
	if lspci -k | grep -A 2 -E '(VGA|3D|Graphics)' | grep -qi intel; then
		pi intel-media-driver vulkan-intel  # libva-intel-driver
		# runuser -u "$SUDO_USER" -- yay -Sq --noconfirm --needed intel-hybrid-codec-driver
		cat <<-EOF >/etc/mkinitcpio.conf.d/20-intel.conf
			MODULES+=(i915)
		EOF
	fi
	if lspci -k | grep -A 2 -E '(VGA|3D|Graphics)' | grep -qi amd; then
		pi libva-mesa-driver mesa vulkan-radeon
		cat <<-EOF >/etc/mkinitcpio.conf.d/20-amd.conf
			MODULES+=(amdgpu)
		EOF
	fi

	yay -Scc --noconfirm
}


setup_scripts() {
	if [ -n "$BATTERY_PATH" ]; then
		BATTERY_PATH="$BATTERY_PATH" envsubst '${BATTERY_PATH}' < ../scripts/battery.sh > /usr/local/bin/battery
		chmod 755 /usr/local/bin/battery
		# go build scripts/battery.go
		# chmod u+s battery
		# mv battery /usr/local/bin
	fi
	# if [ -d /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00 ]; then
	# 	go build scripts/perf.go
	# 	chmod u+s perf
	# 	mv perf /usr/local/bin
	# fi
	for script in record.sh mic.sh date.sh blink-leds.sh notify-user.sh coredump-journal-watch.sh dynamic-workspaces.py; do
		install -m 755 "scripts/$script" /usr/local/bin
	done
}


setup_locale() {
	sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
	sed -i 's/^#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen
	locale-gen
	cat <<-EOF >/etc/locale.conf
		LANG=en_US.UTF-8
		LC_TIME=en_GB.UTF-8
		LC_PAPER=en_GB.UTF-8
		LC_MEASUREMENT=en_GB.UTF-8
		LC_COLLATE=C.UTF-8
	EOF
}


mkdir -p /etc/pacman.conf.d
grep -q "Include = /etc/pacman.conf.d/\*.conf" /etc/pacman.conf || sed -i '/^\[options\]/a Include = /etc/pacman.conf.d/*.conf' /etc/pacman.conf
cat <<-EOF >/etc/pacman.conf.d/custom_options.conf
	[options]
	ParallelDownloads = 5
	Color
	ILoveCandy
EOF

mkdir -p /etc/pacman.d/hooks
cp pacman-hooks/* /etc/pacman.d/hooks


sed -i '/deny = /c\deny = 6' /etc/security/faillock.conf  # increase allowed failed attempt count
sed -Ei '/[[:space:]]\/boot[[:space:]]+vfat[[:space:]]/ s/=0022/=0077/g' /etc/fstab  # restrict /boot permissions
chmod -R 700 /boot || true


mkdir -p /etc/mkinitcpio.conf.d
mkdir -p /etc/cmdline.d


# Enable TRIM
cryptsetup --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue --persistent refresh root
FS_PATH="$(findmnt -no SOURCE /)"
FS_TYPE="$(findmnt -no FSTYPE /)"
if [ "$FS_TYPE" = 'ext4' ]; then
	tune2fs -o discard "$FS_PATH"
	systemctl disable --now fstrim.timer
elif [ "$FS_TYPE" = 'btrfs' ]; then
	# btrfs automatically enables online TRIM
	systemctl disable --now fstrim.timer
else
	systemctl enable --now fstrim.timer
fi


pacman -Syyu --noconfirm
pi base-devel

# Optimize makepkg - multithreading, disable compression and debug symbols
cat <<-EOF >/etc/makepkg.conf.d/flags.conf
	MAKEFLAGS="-j$(nproc)"
	PKGEXT='.pkg.tar'
	SRCEXT='.src.tar'
	OPTIONS+=(!debug)
	# BUILDDIR='/tmp/makepkg'
EOF

# Install yay-bin
if ! command -v yay &> /dev/null; then
	su -c 'git clone -q --depth=1 https://aur.archlinux.org/yay-bin.git' "$SUDO_USER"
	cd yay-bin
	runuser -u "$SUDO_USER" -- makepkg -si --noconfirm
	cd ..
	rm -rf yay-bin
fi

# Install AUR packages
runuser -u "$SUDO_USER" -- yay -Sq --noconfirm --needed --sudoloop \
	chayang papirus-folders-catppuccin-git sway-audio-idle-inhibit-git # python-catppuccin

# Packages that are used in the setup process
pi acpi acpi_call acpid cups git papirus-icon-theme plymouth python-build ufw wget


# Start slow-running jobs
setup_packages "$@" &
setup_scripts &
setup_locale &


# Configure ACPI to notify i3blocks on AC adapter events
cat <<-EOF >/etc/acpi/events/ac
	event=ac_adapter
	action=pkill -SIGRTMIN+3 i3blocks
EOF
rm -f /etc/acpi/events/anything
systemctl enable --now acpid


# Add user to groups
usermod -aG video "$SUDO_USER"
usermod -aG input "$SUDO_USER"


# Configure Firefox
mkdir -p /etc/firefox/policies
cp firefox/policies.json /etc/firefox/policies


# Configure Chromium
mkdir -p /etc/chromium/policies/managed
cat <<-EOF >/etc/chromium/policies/managed/custom_policy.json
	{
		"HighEfficiencyModeEnabled": true,
		"BackgroundModeEnabled": false
	}
EOF
cat <<-EOF >/etc/chromium/policies/managed/disable_policy.json
	{
		"autofill": {
			"credit_card_enabled": false,
			"profile_enabled": false
		},
		"browser": {
			"custom_chrome_frame": false
		},
		"credentials_enable_service": false,
		"extensions": {
			"theme": { "system_theme": 1 }
		},
		"net": {
			"network_prediction_options": 2
		},
		"payments": {
			"can_make_payment_enabled": false
		},
		"privacy_sandbox": {
			"m1": {
				"ad_measurement_enabled": false,
				"fledge_enabled": false,
				"topics_enabled": false
			}
		},
		"profile": {
			"cookie_controls_mode": 1,
			"password_manager_enabled": false
		},
		"webkit": {
			"webprefs": {
				"fonts": {
					"sansserif": { "Zyyy": "Sans" },
					"serif": { "Zyyy": "Serif" },
					"standard": { "Zyyy": "Sans" }
				}
			}
		}
	}
EOF


# Configure Papirus folders
papirus-folders -C cat-mocha-mauve --theme Papirus-Dark


# Core dump notifications
mkdir -p /etc/systemd/coredump.conf.d
cat <<-EOF >/etc/systemd/coredump.conf.d/10-limit.conf
	[Coredump]
	Storage=none
	ProcessSizeMax=0
	ExternalSizeMax=0
EOF

cat <<-EOF >/etc/systemd/system/coredump-journal-watch.service
	[Unit]
	Description=Watch journal for coredump events and notify user
	After=systemd-journald.service systemd-user-sessions.service
	Wants=systemd-user-sessions.service

	[Service]
	Type=simple
	ExecStart=/usr/local/bin/coredump-journal-watch.sh
	Restart=on-failure
	RestartSec=5s

	CapabilityBoundingSet=CAP_SYSLOG
	DeviceAllow=
	IPAddressDeny=any
	LockPersonality=yes
	MemoryDenyWriteExecute=yes
	NoNewPrivileges=yes
	PrivateDevices=yes
	PrivateNetwork=yes
	PrivateTmp=yes
	PrivateUsers=yes
	ProtectClock=yes
	ProtectControlGroups=yes
	ProtectHome=yes
	ProtectHostname=yes
	ProtectKernelLogs=yes
	ProtectKernelModules=yes
	ProtectKernelTunables=yes
	ProtectProc=invisible
	ProtectSystem=strict
	RestrictAddressFamilies=AF_UNIX
	RestrictNamespaces=yes
	RestrictRealtime=yes
	RestrictSUIDSGID=yes
	SystemCallArchitectures=native
	SystemCallFilter=@system-service
	SystemCallFilter=~@resources @privileged
	UMask=0077

	[Install]
	WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable coredump-journal-watch.service


# systemctl enable linux-modules-cleanup.service


# Configure journald - consider [Journal] Storage=volatile RuntimeMaxUse=1M
mkdir -p /etc/systemd/journald.conf.d
cat <<-EOF >/etc/systemd/journald.conf.d/10-retention.conf
	[Journal]
	SystemMaxUse=200M
	MaxRetentionSec=7d
EOF


# Networking
mkdir -p /etc/systemd/networkd.conf.d
cat <<-EOF >/etc/systemd/networkd.conf.d/10-ipv6-privacy.conf
	[Network]
	IPv6PrivacyExtensions=yes
EOF

mkdir -p /etc/systemd/resolved.conf.d
cat <<-EOF >/etc/systemd/resolved.conf.d/dns_over_tls.conf
	[Resolve]
	DNS=1.1.1.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com
	DNSOverTLS=yes
	DNSSEC=yes
EOF

systemctl enable --now ufw
ufw logging off
ufw enable

cat <<-EOF >/etc/iwd/main.conf
	[General]
	AddressRandomization=network
	AddressRandomizationRange=full
EOF


# Wayland env vars
grep -q SDL_VIDEODRIVER /etc/environment || cat <<-EOF >>/etc/environment
	ELECTRON_OZONE_PLATFORM_HINT=auto
	GDK_BACKEND=wayland
	QT_QPA_PLATFORM=wayland
	QT_WAYLAND_DISABLE_WINDOWDECORATION=1
	SDL_VIDEODRIVER=wayland
	XDG_CURRENT_DESKTOP=sway
	XDG_SESSION_TYPE=wayland
	_JAVA_AWT_WM_NONREPARENTING=1

	WINEDEBUG=-all

	ANV_DEBUG=video-decode,video-encode
	RADV_EXPERIMENTAL=video_decode,video_encode
EOF


# Edge TPU udev rules
# cat <<-EOF >/usr/lib/udev/rules.d/60-edgetpu.rules
# 	SUBSYSTEM=="apex", MODE="0660", GROUP="plugdev"
# 	SUBSYSTEM=="usb",ATTRS{idVendor}=="1a6e",GROUP="plugdev"
# 	SUBSYSTEM=="usb",ATTRS{idVendor}=="18d1",GROUP="plugdev"
# EOF


# Enable power management
cat <<-EOF >/etc/udev/rules.d/99-device-pm.rules
	SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="auto"
	SUBSYSTEM=="ata_port", KERNEL=="ata*", TEST=="device/power/control", ATTR{device/power/control}="auto"
	ACTION=="add", SUBSYSTEM=="i2c", TEST=="power/control", ATTR{power/control}="auto"
EOF
cat <<-EOF >/etc/udev/rules.d/99-usb-pm.rules
	# 01: Audio | 02: Comm | 03: HID | 0a: CDC-Data | 0e: Video
	ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="01|02|03|0a|0e", GOTO="usb_pm_end"

	# Network: Realtek|ASIX|DisplayLink|Microchip|Aquantia
	ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda|0b95|17e9|0424|1c04|2eca", GOTO="usb_pm_end"

	# Input devices
	ACTION=="add", SUBSYSTEM=="usb", ATTR{product}=="*Mouse*|*Keyboard*|*Joystick*|*Controller*|*Gamepad*|*Gigabit*|*Ethernet*", GOTO="usb_pm_end"
	# Logitech
	ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", GOTO="usb_pm_end"

	ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"

	LABEL="usb_pm_end"
EOF


# Allow user to write to Caps Lock LEDs
cat <<-EOF >/etc/udev/rules.d/99-leds.rules
	SUBSYSTEM=="leds", KERNEL=="*::capslock", ATTR{brightness}=="*", GROUP="input", MODE="0664"
	ACTION=="add", SUBSYSTEM=="leds", KERNEL=="*::capslock", RUN+="/usr/bin/chown root:input /sys/class/leds/%k/brightness", RUN+="/usr/bin/chmod 0664 /sys/class/leds/%k/brightness"
EOF


# sysctl
cat <<-EOF >/etc/sysctl.d/99-bbr.conf
	net.core.default_qdisc=fq
	net.ipv4.tcp_congestion_control=bbr
EOF

cat <<-EOF >/etc/sysctl.d/99-writeback.conf
	vm.dirty_writeback_centisecs=1500
EOF

cat <<-EOF >/etc/sysctl.d/20-quiet-printk.conf
	kernel.printk = 3 3 3 3
EOF

# Enable (REI)SUB
# echo kernel.sysrq = 244 >/etc/sysctl.d/99-sysctl.conf


# Autologin (since LUKS already requires auth)
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat <<-EOF >/etc/systemd/system/getty@tty1.service.d/override.conf
	[Service]
	ExecStart=
	ExecStart=-/usr/bin/agetty --skip-login --nonewline --noissue --autologin "$SUDO_USER" --noclear %I linux
EOF


# Enable CUPS
systemctl enable --now cups.service


# Quiet boot
CMDLINE_OPTIONS="quiet splash loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3 vt.global_cursor_default=0 nmi_watchdog=0 snd_hda_intel.power_save=1 pcie_aspm.policy=powersupersave"
# S540-13ARE: echo 'amdgpu.gpu_recovery=1 pcie_aspm=force' >/etc/cmdline.d/20-s540.conf
# Consider mitigations=off
# https://www.kernel.org/doc/html/latest/gpu/amdgpu/module-parameters.html
echo "$CMDLINE_OPTIONS" >/etc/cmdline.d/default.conf

fc-cache -f &


# Plymouth boot splash screen
# TODO: secure boot disabled warning
# git clone -q --depth=1 https://github.com/sheepymeh/plymouth-theme-arch-agua
# cp -r plymouth-theme-arch-agua /usr/share/plymouth/themes/arch-agua
# rm -rf plymouth-theme-arch-agua
cat <<-EOF >/etc/mkinitcpio.conf.d/10-hooks.conf
	HOOKS=(base udev autodetect microcode modconf kms plymouth keyboard keymap consolefont block encrypt filesystems fsck)
EOF
sed -i '/^[^#].*--splash/s/^/#/' /etc/mkinitcpio.d/*.preset

plymouth-set-default-theme -R spinner

wait


# Notes:
# https://bbs.archlinux.org/viewtopic.php?id=257315
# https://www.kernel.org/doc/Documentation/cpu-freq/boost.txt
# https://wiki.archlinux.org/title/Ext4#Improving_performance
