#!/bin/bash

sudo pacman -Syyu
sudo pacman -S --noconfirm --needed acpi alacritty alsa-utils android-tools arc-gtk-theme avahi base bash-completion cups-pdf dialog exfat-utils firefox gnome-keyring grim gvfs gvfs-mtp i3blocks imv amd-ucode inter-font light linux linux-firmware lollypop mako nano neofetch networkmanager nextcloud-client nodejs npm p7zip papirus-icon-theme pulseaudio-alsa pulseaudio-bluetooth qt5-wayland slurp sway swayidle swaylock thunar ttf-font-awesome ttf-jetbrains-mono unzip wget wl-clipboard xbindkeys xdg-user-dirs xorg-server xorg-server-xwayland xorg-xrandr htop mesa gst-plugins-good gst-plugins-bad acpi_call
wget https://keys.openpgp.org/vks/v1/by-fingerprint/5C6DA024DDE27178073EA103F4B432D5D67990E3
gpg --import 5C6DA024DDE27178073EA103F4B432D5D67990E3
rm 5C6DA024DDE27178073EA103F4B432D5D67990E3
yay -S --noconfirm --needed noto-fonts-sc wob wofi-hg vscodium-bin

sudo pacman -D --asexplicit go
sudo pacman -S --noconfirm --needed wireshark-qt audacity volatility gnu-netcat python-pip sqlmap
yay -S --noconfirm --needed steghide ffuf
sudo pip install pwntools

sudo usermod -a -G video sheepymeh
sudo usermod -a -G rfkill sheepymeh

git config --global user.name 'sheepymeh'
git config --global user.email 'sheepymeh@users.noreply.github.com'
git config --global credential.helper store

chmod a+x battery.sh
mkdir -p ~/.config/sway ~/.config/swaylock ~/.config/wofi ~/.config/alacritty ~/.config/mako ~/.config/i3blocks

sudo mkdir -p /usr/local/bin/i3blocks
sudo mv battery.sh /usr/local/bin/i3blocks/battery.sh
mv sway.conf ~/.config/sway/config
mv swaylock.conf ~/.config/swaylock/config
mv alacritty.yml ~/.config/alacritty/alacritty.yml
mv wofi.conf ~/.config/wofi/config
mv wofi.css ~/.config/wofi/style.css
mv i3blocks.conf ~/.config/i3blocks/config
mv mako.conf ~/.config/mako/config
mv gtk-2.0 ~/.gtkrc-2.0
mv bashrc ~/.bashrc

cat <<EOF | sudo tee -a /etc/environment
MOZ_ENABLE_WAYLAND=1
QT_QPA_PLATFORM=wayland-egl
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
EOF

sudo sed -i 's$#Color$Color\nILoveCandy$' /etc/pacman.conf

sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat <<EOF | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin sheepymeh --noclear %I linux
EOF

cat <<EOF | sudo tee /etc/pacman.d/hooks/100-systemd-boot.hook
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl update
EOF

# 7za x %f
# 7za a -tzip Archive.zip %F
