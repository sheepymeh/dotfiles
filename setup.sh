sudo yay -S --noconfirm android-tools blueman code firefox gcc libmpc php-fpm nginx-mainline nodejs npm i3blocks lollypop youtube-dl arc-gtk-theme papirus-icon-theme throttled noto-fonts-sc ttf-roboto ttf-roboto-mono ttf-font-awesome postman-bin lightdm-mini-greeter slurp grim wl-clipboard termite thunar-archive-plugin thunar wofi-hg xorg-server xorg-server-xwayland xorg-xrandr p7zip unzip mako sway
# mongodb?

sudo systemctl enable lenovo_fix
sudo systemctl enable lightdm

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
