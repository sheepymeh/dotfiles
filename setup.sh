#!/bin/bash

# Install AUR packages
git clone -q https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
wget -q https://keys.openpgp.org/vks/v1/by-fingerprint/5C6DA024DDE27178073EA103F4B432D5D67990E3
gpg --import 5C6DA024DDE27178073EA103F4B432D5D67990E3
rm 5C6DA024DDE27178073EA103F4B432D5D67990E3
yay -Sq --noconfirm --needed noto-fonts-sc wob wofi-hg
yay -Sq --noconfirm --needed steghide ffuf

# Initialize git
git config --global user.name 'sheepymeh'
git config --global user.email 'sheepymeh@users.noreply.github.com'
git config --global credential.helper store

# Install dotfiles
mkdir -p ~/.config/sway ~/.config/swaylock ~/.config/wofi ~/.config/alacritty ~/.config/mako ~/.config/i3blocks
mv sway.conf ~/.config/sway/config
mv swaylock.conf ~/.config/swaylock/config
mv alacritty.yml ~/.config/alacritty/alacritty.yml
mv wofi.conf ~/.config/wofi/config
mv wofi.css ~/.config/wofi/style.css
mv i3blocks.conf ~/.config/i3blocks/config
mv mako.conf ~/.config/mako/config
mv gtk-2.0 ~/.gtkrc-2.0
mv bashrc ~/.bashrc

# 7za x %f
# 7za a -tzip Archive.zip %F
