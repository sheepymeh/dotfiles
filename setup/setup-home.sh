#!/bin/bash
set -Eeuo pipefail
if [ "$EUID" -eq 0 ]; then
	echo "Script must be run as user"
	exit 1
fi
cd "$(dirname -- "$0")"
. ../posix-common/config.sh
trap 'kill 0' ERR

if [ -z "$WAYLAND_DISPLAY" ]; then
	echo '$WAYLAND_DISPLAY not initialized'
	exit 1
fi

install_wine() {
	if command -v wine &>/dev/null; then
		wineboot
		setup_dxvk install --symlink
		setup_vkd3d_proton install --symlink
	fi
}

# Start slow-running jobs
vscode_install_ext code &
install_wine &

git_config

# Prepare /home/user
xdg-user-dirs-update
rm -r ~/Desktop ~/Templates ~/Projects ~/Public ~/Documents ~/Music
xdg-user-dirs-update
touch ~/.hushlogin

# Configure colors
mkdir -p ~/.config/foot
wget -qO ~/.config/foot/catppuccin-mocha.ini https://raw.githubusercontent.com/catppuccin/foot/refs/heads/main/themes/catppuccin-mocha.ini
wget -qO ~/.config/wallpaper.png https://raw.githubusercontent.com/archcraft-os/archcraft-wallpapers/main/archcraft-backgrounds-minimal/files/minimal-12.jpg

# Install Catppuccin GTK
wget -q https://github.com/catppuccin/gtk/releases/download/v1.0.3/catppuccin-mocha-mauve-standard+default.zip
mkdir -p ~/.themes
unzip -qo catppuccin-mocha-mauve-standard+default.zip -d ~/.themes
rm catppuccin-mocha-mauve-standard+default.zip

# Copy configs
cd ..
cp -a home-config/. ~
cp -a config/. ~/.config
if ! swaymsg -t get_outputs | jq -e 'any(.name == "eDP-1")' >/dev/null; then
	rm ~/.config/sway/config.d/laptop.conf
fi

vscode_config ".config/Code - OSS/User"

cd -

# Configure bat
mkdir -p "$(bat --config-dir)/themes"
wget -qO "$(bat --config-dir)/themes/Catppuccin Mocha.tmTheme" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
bat cache --build

# Configure sway
wget -qO ~/.config/sway/catppuccin-mocha https://raw.githubusercontent.com/catppuccin/i3/main/themes/catppuccin-mocha

# Configure fcitx5
mkdir -p ~/.local/share/fcitx5/rime ~/.local/share/fcitx5/themes
cat <<-EOF >~/.local/share/fcitx5/rime/default.custom.yaml
	patch:
	  schema_list:
	    - schema: pinyin_simp
	  notifications: false
EOF
git clone -q --depth=1 https://github.com/catppuccin/fcitx5.git
cp -r ./fcitx5/src/catppuccin-mocha-mauve/ ~/.local/share/fcitx5/themes
rm -rf fcitx5

systemctl --user enable ssh-agent sway-inhibit-idle clear-trash.timer

wait
