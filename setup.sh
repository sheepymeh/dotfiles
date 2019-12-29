sudo pacman -R --noconfirm markdown_previewer vi vim speedtest-cli memtest86+ spectre-meltdown-checker screenfetch tlp powertop ranger brandr links mousepad palemoon-bin kvantum-manjaro gcolor2 xterm manjaro-i3-settings conky-i3 conky zsh f2fs-tools manjaro-ranger-settings manjaro-browser-settings networkmanager-pptp i3-scrot clipit
# fzf

rm -rf .config/i3-scrot.conf .config/Ranger

sudo pacman -S --noconfirm yay

sudo yay -S --noconfirm android-tools blueman firefox gcc libmpc php-fpm nginx-mainline nodejs npm flameshot i3blocks lollypop youtube-dl arc-gtk-theme arc-icon-theme throttled noto-fonts-sc ttf-roboto ttf-roboto-mono postman-bin mons

# mongodb?

sudo systemctl enable bluetooth
sudo systemctl enable lenovo_fix.service

sudo usermod -a -G bumblebee jiayang

git config --global user.name 'sheepymeh'
git config --global user.email 'sheepymeh@users.noreply.github.com'
git config --global commit.gpgsign true
git config --global credential.helper store

mv i3.conf ~/.i3/config
mv i3blocks.conf ~/.i3blocks.conf
mv gtk2 ~/.gtkrc-2.0
mv gtk3 ~/.config/gtk-3.0
chmod a+x battery.sh
sudo mv battery.sh /usr/local/bin/battery.sh
sudo mv xresources ~/.Xresources