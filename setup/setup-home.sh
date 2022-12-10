#!/bin/sh

# Prepare /home/user
xdg-user-dirs-update
rm -rf ~/Desktop ~/Templates ~/Public ~/Documents ~/Music
xdg-user-dirs-update
touch ~/.hushlogin

# Configure colors
git clone --depth=1 -q https://github.com/catppuccin/alacritty.git ~/.config/alacritty/catppuccin
papirus-folders -C cat-mocha-mauve --theme Papirus-Dark

# Copy configs
cp -r config/* ~/.config
mkdir -p ~/.swaylog
mkdir -p ~/.config/VSCodium/User
cp code/* ~/.config/VSCodium/User
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

# Configure Codium
codium --install-extension Catppuccin.catppuccin-vsc
codium --install-extension ms-python.python
codium --install-extension Vue.volar