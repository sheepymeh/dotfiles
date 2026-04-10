#!/bin/bash
set -Eeuo pipefail
trap 'kill 0' ERR

if [ "$EUID" -eq 0 ]; then
	echo "Script must be run as user"
	exit
fi
cd "$(dirname -- "$0")"

install_vscode_ext() {
	code --install-extension Catppuccin.catppuccin-vsc
	code --install-extension Catppuccin.catppuccin-vsc-icons

	code --install-extension Vue.volar
	code --install-extension dbaeumer.vscode-eslint
	code --install-extension esbenp.prettier-vscode

	code --install-extension eamodio.gitlens
	code --install-extension github.vscode-pull-request-github
	code --install-extension github.vscode-github-actions

	code --install-extension GitHub.copilot
	code --install-extension ms-azuretools.vscode-docker

	code --install-extension ms-python.python
	code --install-extension ms-toolsai.jupyter
	code --install-extension ms-python.mypy-type-checker
	code --install-extension kv9898.basedpyright
	code --install-extension charliermarsh.ruff
	code --install-extension astral-sh.ty

	code --install-extension james-yu.latex-workshop
	code --install-extension davidanson.vscode-markdownlint

	code --install-extension timonwong.shellcheck
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
mkdir -p ~/.config/Code/User
cp code/* ~/.config/Code/User
if swaymsg -t get_outputs | jq -e 'any(.name == "eDP-1")' >/dev/null; then
	rm ~/.config/sway/config.d/laptop.conf
fi
cd -

# Configure git
git config --global user.name 'sheepymeh'
git config --global user.email 'sheepymeh@users.noreply.github.com'
git config --global credential.helper store
git config --global pull.rebase false
git config --global init.defaultBranch main

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
