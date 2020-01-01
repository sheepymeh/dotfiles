yay -S --noconfirm --needed acpi alsa-utils android-tools arc-gtk-theme base bash-completion code cups-pdf ttf-dejavu dialog dmidecode efibootmgr exfat-utils firefox grim grub gvfs i3blocks intel-ucode light lightdm linux linux-firmware lollypop lsof mako nano neofetch networkmanager nextcloud-client nginx-mainline npm ntfs-3g p7zip pacman-contrib papirus-icon-theme php-fpm pulseaudio-alsa pulseaudio-bluetooth qbittorrent qt5-wayland slurp sway termite throttled thunar-archive-plugin thunar-volman ttf-font-awesome ttf-roboto ttf-roboto-mono unzip wget wl-clipboard xbindkeys xdg-user-dirs xf86-video-intel xf86-video-nouveau xorg-server xorg-server-xwayland xorg-xrandr youtube-dl
wget https://keys.openpgp.org/vks/v1/by-fingerprint/5C6DA024DDE27178073EA103F4B432D5D67990E3
gpg --import 5C6DA024DDE27178073EA103F4B432D5D67990E3
rm 5C6DA024DDE27178073EA103F4B432D5D67990E3
yay -S --noconfirm --needed lightdm-mini-greeter noto-fonts-sc plymouth plymouth-theme-arch-agua postman-bin wob wofi-hg
# mongodb?
yay -R --noconfirm dhcpcd
yay -Rdd --noconfirm avahi v4l-utils

sudo systemctl enable lenovo_fix
sudo systemctl enable lightdm-plymouth

git config --global user.name 'sheepymeh'
git config --global user.email 'sheepymeh@users.noreply.github.com'
git config --global commit.gpgsign true
git config --global credential.helper store

sudo usermod -a -G video jiayang

chmod a+x battery.sh
mkdir -p ~/.config/sway ~/.config/wofi ~/.config/termite ~/.config/mako ~/.config/i3blocks
sudo mkdir -p /usr/local/bin/i3blocks
sudo mv battery.sh /usr/local/bin/i3blocks/battery.sh
mv sway.conf ~/.config/sway/config
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
sudo sed -i 's$GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"$GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash rd.udev.log_priority=3 vt.global_cursor_default=0"$' /etc/default/grub
sudo sed -i 's$GRUB_TIMEOUT=5$GRUB_TIMEOUT=0$' /etc/default/grub
sudo mkinitcpio -p linux
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo plymouth-set-default-theme -R arch-agua
printf "MOZ_ENABLE_WAYLAND=1\nQT_QPA_PLATFORM=wayland-egl\nQT_WAYLAND_FORCE_DPI=physical\nQT_WAYLAND_DISABLE_WINDOWDECORATION=1" | sudo tee -a /etc/environment
sudo sed -i 's$#Color$Color\nILoveCandy$' /etc/pacman.conf
