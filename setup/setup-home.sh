#!/bin/sh
set -euo pipefail

if [ "$EUID" -eq 0 ]; then
	echo "Script must be run as user"
	exit
fi
if [[ $(basename "$PWD") != "setup" ]]; then
	echo "Script must be run from /setup"
	exit
fi

# Prepare /home/user
xdg-user-dirs-update
rm -rf ~/Desktop ~/Templates ~/Public ~/Documents ~/Music
xdg-user-dirs-update
touch ~/.hushlogin

# Configure colors
git clone --depth=1 -q https://github.com/catppuccin/alacritty.git ~/.config/alacritty/catppuccin
papirus-folders -C cat-mocha-mauve --theme Papirus-Dark
wget -qO ~/.config/wallpaper.png https://raw.githubusercontent.com/archcraft-os/archcraft-wallpapers/main/archcraft-backgrounds-minimal/files/minimal-12.jpg

cd ..

# Copy configs
cp -r config/* ~/.config
mkdir -p ~/.config/Code/User
cp code/* ~/.config/Code/User
cp bashrc ~/.bashrc
sed -i 's$sway >$sway --unsupported-gpu >$' ~/.bashrc
if [ ! -d /sys/class/power_supply/BAT* ]; then
	rm ~/.config/sway/laptop.conf
fi

# Configure git
git config --global user.name 'sheepymeh'
git config --global user.email 'sheepymeh@users.noreply.github.com'
git config --global credential.helper store
git config --global pull.rebase false

# Configure VS Code
code --install-extension Catppuccin.catppuccin-vsc
code --install-extension Catppuccin.catppuccin-vsc-icons
code --install-extension Vue.volar
code --install-extension eamodio.gitlens
code --install-extension GitHub.copilot
code --install-extension ms-python.python

# Configure bat
mkdir -p "$(bat --config-dir)/themes"
wget -qO "$(bat --config-dir)/themes/Catppuccin-mocha.tmTheme" https://raw.githubusercontent.com/catppuccin/bat/main/Catppuccin-mocha.tmTheme
bat cache --build

# Configure sway
wget -qO ~/.config/sway/catppuccin-mocha https://raw.githubusercontent.com/catppuccin/i3/main/themes/catppuccin-mocha

# Configure fcitx5
mkdir -p ~/.local/share/fcitx5/rime/ ~/.local/share/fcitx5/themes/
cat <<EOF >~/.local/share/fcitx5/rime/default.custom.yaml
patch:
  schema_list:
    - schema: pinyin_simp
EOF
echo Theme=catppuccin-mocha > ~/.config/fcitx5/conf/classicui.conf
git clone --depth=1 https://github.com/catppuccin/fcitx5.git
cp -r ./fcitx5/src/catppuccin-mocha ~/.local/share/fcitx5/themes
rm -rf fcitx5
sed 's/FAB387/CBA6F7/g' -i ~/.local/share/fcitx5/themes/catppuccin-mocha/theme.conf
sed 's/87B0F9/B4BEFE/g' -i ~/.local/share/fcitx5/themes/catppuccin-mocha/theme.conf
echo Theme=catppuccin-mocha > ~/.config/fcitx5/conf/classicui.conf

# systemd services
systemctl --user enable ssh-agent
mkdir -p ~/.config/systemd/user/
cat <<EOF >~/.config/systemd/user/inhibit-while-playing-media.service
[Unit]
Description=Inhibit idle while media is playing

[Service]
ExecStart=systemd-inhibit --what=idle --who=playerctl --why='Active media playing' sleep infinity
EOF
cat <<EOF >~/.config/systemd/user/inhibit-idle.service
[Unit]
Description=Inhibit idle

[Service]
ExecStart=systemd-inhibit --what=idle --who=i3blocks --why='User inhibited idle' sleep infinity
EOF

# Configure Wine
wine reg.exe add HKCU\\Software\\Wine\\Drivers /v Graphics /d x11,wayland
setup_dxvk install

# Install iwd-wofi
git clone --depth=1 https://github.com/sheepymeh/iwd_wofi.git
cd iwd_wofi
python -m build -w
pipx install dist/iwd_wofi-*-py3-none-any.whlpipx runpip iwd-wofi install -r requirements.txt
pipx runpip iwd-wofi install -r requirements.txt
cd ..
rm -rf iwd_wofi

systemctl --user enable ssh-agent
mkdir ~/.ssh
echo AddKeysToAgent yes >~/.ssh/config
chmod 600 ~/.ssh/config
