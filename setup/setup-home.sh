#!/bin/sh

# Prepare /home/user
xdg-user-dirs-update
rm -rf ~/Desktop ~/Templates ~/Public ~/Documents ~/Music
xdg-user-dirs-update
touch ~/.hushlogin

# Configure colors
git clone --depth=1 -q https://github.com/catppuccin/alacritty.git ~/.config/alacritty/catppuccin
papirus-folders -C cat-mocha-mauve --theme Papirus-Dark
wget -qO ~/.config/wallpaper.png https://raw.githubusercontent.com/archcraft-os/archcraft-wallpapers/main/archcraft-backgrounds-minimal/files/minimal-12.jpg

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
codium --install-extension Catppuccin.catppuccin-vsc-icons
codium --install-extension ms-python.python
codium --install-extension Vue.volar

# Configure bat
mkdir -p "$(bat --config-dir)/themes"
wget -qO "$(bat --config-dir)/themes/Catppuccin-mocha.tmTheme" https://raw.githubusercontent.com/catppuccin/bat/main/Catppuccin-mocha.tmTheme
bat cache --build

# Configure sway
wget -qO ~/.config/sway/catppuccin-mocha https://raw.githubusercontent.com/catppuccin/i3/main/themes/catppuccin-mocha

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

wget https://github.com/catppuccin/firefox/releases/download/old/catppuccin_mocha_mauve.xpi
wget https://gitlab.com/magnolia1234/bpc-uploads/-/raw/master/bypass_paywalls_clean-latest.xpi
firefox catppuccin_mocha_mauve.xpi bypass_paywalls_clean-latest.xpi
rm catppuccin_mocha_mauve.xpi
rm bypass_paywalls_clean-latest.xpi

cp firefox/* ~/.mozilla/firefox/$FF_PROFILE
sqlite3 ~/.mozilla/firefox/$FF_PROFILE/permissions.sqlite <<EOF
INSERT INTO moz_perms (origin, type, permission, expireType, expireTime, modificationTime) VALUES
('https://mail.tutanota.com', 'cookie', '1', '0', '0', '1600000000000'),
('https://github.com', 'cookie', '1', '0', '0', '1600000000000'),
('https://cloud.sheepmeh.net', 'cookie', '1', '0', '0', '1600000000000'),
('https://discord.com', 'cookie', '1', '0', '0', '1600000000000'),
('https://notion.so', 'cookie', '1', '0', '0', '1600000000000'),
('https://chat.openai.com', 'cookie', '1', '0', '0', '1600000000000'),
('https://web.whatsapp.com', 'cookie', '1', '0', '0', '1600000000000'),
('https://nebula.tv', 'cookie', '1', '0', '0', '1600000000000'),
('https://accounts.google.com', 'cookie', '1', '0', '0', '1600000000000'),
('https://music.youtube.com', 'cookie', '1', '0', '0', '1600000000000');
EOF

# Configure Chromium
cat <<EOF >~/.config/chromium-flags.conf
--enable-features=UseOzonePlatform
--ozone-platform=wayland
EOF