sudo systemctl enable NetworkManager
sudo systemctl startNetworkManager

sudo pacman -R --noconfirm vi memtest86+ spectre-meltdown-checker tlp zsh f2fs-tools

rm -rf .config/i3-scrot.conf .config/Ranger

sudo pacman -S --noconfirm yay

sudo yay -S --noconfirm android-tools blueman code firefox gcc libmpc php-fpm nginx-mainline nodejs npm i3blocks lollypop youtube-dl arc-gtk-theme papirus-icon-theme throttled noto-fonts-sc ttf-roboto ttf-roboto-mono ttf-font-awesome postman-bin lightdm-mini-greeter slurp grim wl-clipboard termite thunar-archive-plugin thunar wofi-hg xorg-server xorg-server-xwayland xorg-xrandr p7zip unzip mako
# mongodb?

sudo systemctl enable bluetooth
sudo systemctl enable lenovo_fix

git config --global user.name 'sheepymeh'
git config --global user.email 'sheepymeh@users.noreply.github.com'
git config --global commit.gpgsign true
git config --global credential.helper store

chmod a+x battery.sh
sudo mv battery.sh /usr/local/bin/i3blocks/battery.sh
mv sway.conf ~/$XDG_CONFIG_HOME/sawy/config
mv wofi.conf ~/$XDG_CONFIG_HOME/wofi/config
mv wofi.css ~/$XDG_CONFIG_HOME/wofi/style.css
mv termite.conf ~/$XDG_CONFIG_HOME/termite/config
mv i3blocks.conf ~/$XDG_CONFIG_HOME/i3blocks/config
mv mako.conf ~/$XDG_CONFIG_HOME/mako/config
sudo mv /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.old.conf
sudo mv lightdm.conf /etc/lightdm/lightdm.conf
sudo mv lightdm-mini-greeter.conf /etc/lightdm/lightdm-mini-greeter.old.conf
sudo mv lightdm-mini-greeter.conf /etc/lightdm/lightdm-mini-greeter.conf
