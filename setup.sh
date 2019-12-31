sudo pacman -S --noconfirm yay
yay -S --noconfirm acpi alsa-utils android-tools arc-gtk-theme base bash-completion brightnessctl code cups-pdf dialog dmidecode efibootmgr exfat-utils firefox grim grub gvfs i3blocks intel-ucode light lightdm-mini-greeter linux linux-firmware lollypop lsof mako nano neofetch networkmanager nginx-mainline noto-fonts-sc npm ntfs-3g p7zip pacman-contrib papirus-icon-theme php-fpm plymouth plymouth-theme-arch-agua postman-bin pulseaudio-alsa pulseaudio-bluetooth qbittorrent slurp sway termite throttled thunar-archive-plugin thunar-volman ttf-font-awesome ttf-roboto ttf-roboto-mono unzip wget wl-clipboard wob wofi-hg xbindkeys xdg-user-dirs xf86-video-intel xf86-video-nouveau xorg-server xorg-server-xwayland xorg-xrandr yay youtube-dl
# mongodb?
yay -R dhcpcd
yay -Rdd avahi v4l-utils

sudo systemctl enable lenovo_fix
sudo systemctl enable lightdm-plymouth

git config --global user.name 'sheepymeh'
git config --global user.email 'sheepymeh@users.noreply.github.com'
git config --global commit.gpgsign true
git config --global credential.helper store

chmod a+x battery.sh
sudo mv battery.sh /usr/local/bin/i3blocks/battery.sh
sudo mkdir -p ~/.config/sway ~/.config/wofi ~/.config/termite ~/.config/mako ~/.config/i3blocks
mv sway.conf ~/.config/sawy/config
mv wofi.conf ~/.config/wofi/config
mv wofi.css ~/.config/wofi/style.css
mv termite.conf ~/.config/termite/config
mv i3blocks.conf ~/.config/i3blocks/config
mv mako.conf ~/.config/mako/config
sudo mv /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.old.conf
sudo mv lightdm.conf /etc/lightdm/lightdm.conf
sudo mv /etc/lightdm/lightdm-mini-greeter.conf /etc/lightdm/lightdm-mini-greeter.old.conf
sudo mv lightdm-mini-greeter.conf /etc/lightdm/lightdm-mini-greeter.conf
sudo mv /etc/mkinitcpio.conf /etc/mkinitcpio.old.conf
sudo mv mkinitcpio.conf /etc/mkinitcpio.conf
sudo mv /etc/default/grub /etc/default/grub.old
sudo sed -i 's$GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash"$GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash rd.udev.log_priority=3 vt.global_cursor_default=0"$' /etc/default/grub
sudo mkinitcpio -p linux
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo plymouth-set-default-theme -R arch-agua
