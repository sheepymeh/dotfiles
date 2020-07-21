#!/bin/bash

yay -Syu
yay -S --noconfirm --needed acpi alacritty alsa-utils android-tools arc-gtk-theme avahi base bash-completion cups-pdf ttf-dejavu dialog dmidecode efibootmgr exfat-utils firefox gnome-keyring grim grub gvfs gvfs-mtp i3blocks imv intel-ucode inter-font light linux linux-firmware lollypop mako nano neofetch networkmanager nextcloud-client nodejs npm p7zip papirus-icon-theme php-fpm pulseaudio-alsa pulseaudio-bluetooth qt5-wayland slurp sway swayidle swaylock throttled thunar tlp ttf-font-awesome ttf-roboto ttf-roboto-mono unzip vscodium-bin wget wl-clipboard xbindkeys xdg-user-dirs xf86-video-intel xf86-video-nouveau xorg-server xorg-server-xwayland xorg-xrandr htop nvidia bumblebee mesa gst-plugins-good gst-plugins-bad

wget https://keys.openpgp.org/vks/v1/by-fingerprint/5C6DA024DDE27178073EA103F4B432D5D67990E3
gpg --import 5C6DA024DDE27178073EA103F4B432D5D67990E3
rm 5C6DA024DDE27178073EA103F4B432D5D67990E3
yay -S --noconfirm --needed noto-fonts-sc plymouth plymouth-theme-arch-agua postman-bin wob wofi-hg

yay -D --asexplicit go
yay -R --noconfirm dhcpcd
yay -Rdd --noconfirm v4l-utils

sudo systemctl enable lenovo_fix

git config --global user.name 'sheepymeh'
git config --global user.email 'sheepymeh@users.noreply.github.com'
git config --global credential.helper store

sudo usermod -a -G bumblebee sheepymeh
sudo systemctl enable bumblebeed.service
echo "options bbswitch load_state=0 unload_state=1" | sudo tee /etc/modprobe.d/bbswitch.conf
cat <<EOF | sudo tee /etc/pacman.d/hooks/nvidia.hook
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOF

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
sudo mv /etc/mkinitcpio.conf /etc/mkinitcpio.old.conf
sudo mv mkinitcpio.conf /etc/mkinitcpio.conf

sudo sed -i 's$GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"$GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash rd.udev.log_priority=3 vt.global_cursor_default=0 nvidia-drm.modeset=1"$' /etc/default/grub
sudo sed -i 's$GRUB_TIMEOUT=5$GRUB_TIMEOUT=0$' /etc/default/grub

sudo plymouth-set-default-theme -R arch-agua

cat <<EOF | sudo tee -a /etc/environment
MOZ_ENABLE_WAYLAND=1
QT_QPA_PLATFORM=wayland-egl
QT_WAYLAND_FORCE_DPI=physical
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
EOF

sudo sed -i 's$#Color$Color\nILoveCandy$' /etc/pacman.conf

sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat <<EOF | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin sheepymeh --noclear %I linux
EOF

sudo mkinitcpio -p linux
sudo grub-mkconfig -o /boot/grub/grub.cfg

# 7za x %f
# 7za a -tzip Archive.zip %F
