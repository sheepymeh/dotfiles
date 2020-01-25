#!/bin/bash

sudo ubuntu-report -f send no

sudo snap remove gnome-calculator gnome-system-monitor gnome-characters gnome-logs gtk-common-themes &
sudo snap install discord &
sudo snap install code --classic &
wget https://dl.pstmn.io/download/latest/linux64

sudo apt -y purge apport apturl gnome-startup-applications popularity-contest ubuntu-report vim vim-common vim-tiny whoopsie whoopsie-preferences
sudo add-apt-repository -y ppa:nextcloud-devs/client
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo apt -y install curl
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt update
sudo apt -y autoremove
sudo apt -y upgrade
sudo apt -y install adb build-essential exfat-fuse exfat-utils fonts-roboto gdbserver gnome-control-center git gnome-tweaks gvfs-fuse htop ibus-pinyin libcairo2-dev libgconf-2-4 libgirepository1.0-dev libhttp-daemon-perl libdbus-glib-1-dev mongodb-org nextcloud-client nginx-light nodejs python3-dev php7.3-curl php7.3-fpm php7.3-mysql php7.3-xml python3-venv safeeyes stress s-tui transmission-gtk network-manager-openvpn network-manager-openvpn-gnome ubuntu-restricted-extras
sudo apt -y autoremove

sudo prime-select intel &

git clone https://github.com/erpalma/lenovo-throttling-fix.git &

sudo systemctl enable mongod

sed -i 's$XDG_DESKTOP$#XDG_DESKTOP$' ~/.config/user-dirs.dirs
sed -i 's$XDG_TEMPLATES$#XDG_TEMPLATES$' ~/.config/user-dirs.dirs
sed -i 's$XDG_PUBLICSHARE$#XDG_PUBLICSHARE$' ~/.config/user-dirs.dirs
sed -i 's$XDG_MUSIC$#XDG_MUSIC$' ~/.config/user-dirs.dirs
sed -i 's$XDG_PICTURES$#XDG_PICTURES$' ~/.config/user-dirs.dirs
sed -i 's$XDG_VIDEOS$#XDG_VIDEOS$' ~/.config/user-dirs.dirs
echo "enabled=false" > ~/.config/user-dirs.conf

sudo sed -i 's#font-family:#font-family: Roboto,#' /usr/share/gnome-shell/theme/Yaru/gnome-shell.css
sudo sed -i 's#font-family:#font-family: Roboto,#' /usr/share/gnome-shell/theme/gdm3.css
sudo sed -i 's$background-color: #2C001E;$background-color: #000;$' /usr/share/gnome-shell/theme/gdm3.css

sudo sed -i 's#Window.SetBackgroundTopColor (0.16, 0.00, 0.12);#Window.SetBackgroundTopColor(0.0, 0.0, 0.0);#' /usr/share/plymouth/themes/ubuntu-logo/ubuntu-logo.script
sudo sed -i 's#Window.SetBackgroundBottomColor (0.16, 0.00, 0.12);#Window.SetBackgroundBottomColor(0.0, 0.0, 0.0);#' /usr/share/plymouth/themes/ubuntu-logo/ubuntu-logo.script

sudo sed -i 's#44,0,30,0#0,0,0,0#' /usr/share/plymouth/themes/default.grub

sudo sed -i 's/#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf

if (( $(bc <<< "$(lsb_release -r -s) >= 18.10") ))
then
	echo 'RESUME=none' | sudo tee /etc/initramfs-tools/conf.d/resume
fi

sudo cat >> /lib/systemd/system-sleep/resume<<-EOF
#!/bin/sh
if [ $(hcitool dev | wc -l) -gt 1 ]; then
	rfkill block bluetooth
	touch /tmp/bt-sleep-on
elif [ -f /tmp/bt-sleep-on ]; then
	rfkill unblock bluetooth
	rm /tmp/bt-sleep-on
fi
exit 0
EOF
chmod a+x /lib/systemd/system-sleep/resume

sudo update-grub &
sudo update-initramfs -u &
sudo service mongod start &

wait

sudo chmod +x lenovo-throttling-fix/install.sh
sudo ./lenovo-throttling-fix/install.sh
sudo systemctl stop thermald.service
sudo systemctl disable thermald.service
sudo systemctl mask thermald.service
rm -rf lenovo-throttling-fix

tar -xzf linux64
rm linux64
sudo mv Postman /opt
cat >> ~/.local/share/applications/Postman.desktop<<-EOF
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=/opt/Postman/app/Postman %U
Icon=/opt/Postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
EOF

git config --global user.name 'sheepymeh'
git config --global user.email 'sheepymeh@users.noreply.github.com'
git config --global commit.gpgsign true
git config --global credential.helper store

printf "Press [ENTER] to reboot..."
read -n1 CONFIRMATION
rm $0
if [ "$CONFIRMATION" == "" ]; then
	sudo reboot
else
	echo "Please reboot your system manually"
	exit 1
fi
