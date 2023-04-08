#!/bin/sh

# Prepare /home/user
xdg-user-dirs-update
rm -rf ~/Desktop ~/Templates ~/Public ~/Documents ~/Music
xdg-user-dirs-update
touch ~/.hushlogin

# Configure colors
git clone --depth=1 -q https://github.com/catppuccin/alacritty.git ~/.config/alacritty/catppuccin
papirus-folders -C cat-mocha-mauve --theme Papirus-Dark
wget -qO ~/Pictures/wallpaper.png https://raw.githubusercontent.com/catppuccin/wallpapers/main/waves/cat-waves.png

cd ..

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

# systemd services
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

# Configure Firefox
sway &
firefox --createprofile default-release
FF_PROFILE="$(grep Path ~/.mozilla/firefox/profiles.ini | cut -f2 -d=)"
cat <<EOF >>~/.mozilla/firefox/profiles.ini
[Install4F96D1932A9F858E]
Default=$FF_PROFILE
Locked=1
EOF
cp ff_prefs.js ~/.mozilla/firefox/$FF_PROFILE/prefs.js
wget https://github.com/catppuccin/firefox/releases/download/old/catppuccin_mocha_mauve.xpi
firefox catppuccin_mocha_mauve.xpi
rm catppuccin_mocha_mauve.xpi