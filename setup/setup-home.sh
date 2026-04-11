#!/bin/bash
set -Eeuo pipefail
trap 'kill 0' ERR

if [ -z "$WAYLAND_DISPLAY" ]; then
	echo '$WAYLAND_DISPLAY not initialized'
fi

if [ "$EUID" -eq 0 ]; then
	echo "Script must be run as user"
	exit
fi
cd "$(dirname -- "$0")"

VSCODE_CONFIG_DIR="$HOME/.config/Code - OSS/User"
VSCODE_EXTENSIONS=(
	# Themes
	Catppuccin.catppuccin-vsc
	Catppuccin.catppuccin-vsc-icons

	# Git
	eamodio.gitlens
	github.vscode-pull-request-github
	github.vscode-github-actions

	# Utilities
#	GitHub.copilot
	ms-azuretools.vscode-docker

	# Text
	james-yu.latex-workshop
	davidanson.vscode-markdownlint

	# Python
	ms-python.python
	ms-toolsai.jupyter
	ms-python.mypy-type-checker
	kv9898.basedpyright
	charliermarsh.ruff
	astral-sh.ty

	# Web
	Vue.volar
	dbaeumer.vscode-eslint
	esbenp.prettier-vscode

	# Shell
	timonwong.shellcheck
)

install_vscode_ext() {
	for ext in "${VSCODE_EXTENSIONS[@]}"; do
		code --install-extension "$ext"
	done

	# manual install https://github.com/microsoft/vscode-copilot-chat/releases
}

install_wine() {
	if command -v wine &>/dev/null; then
		wineboot
		setup_dxvk install --symlink
		setup_vkd3d_proton install --symlink
	fi
}

# Start slow-running jobs
install_vscode_ext &
install_wine &

# Configure git
git config --global user.name 'sheepymeh'
git config --global user.email 'sheepymeh@users.noreply.github.com'
git config --global credential.helper store
git config --global pull.rebase false
git config --global init.defaultBranch main

# Prepare /home/user
xdg-user-dirs-update
rm -rf ~/Desktop ~/Templates ~/Public ~/Documents ~/Music
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
mkdir -p "$VSCODE_CONFIG_DIR"
cp code/* "$VSCODE_CONFIG_DIR"
if ! swaymsg -t get_outputs | jq -e 'any(.name == "eDP-1")' >/dev/null; then
	rm ~/.config/sway/config.d/laptop.conf
fi
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

systemctl --user enable clear-trash.timer
systemctl --user enable ssh-agent
if [ ! -d ~/.ssh ]; then
	mkdir ~/.ssh
	echo AddKeysToAgent yes >~/.ssh/config
	chmod 600 ~/.ssh/config
fi

wait
