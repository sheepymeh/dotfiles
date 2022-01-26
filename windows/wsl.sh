#!/bin/bash

sudo apt purge alsa-topology-conf alsa-ucm-conf apport-symptoms apport cloud-guest-utils cloud-init cloud-initramfs-copymods cloud-initramfs-dyn-netconf console-setup console-setup-linux eatmydata ed eject fontconfig-config fonts-dejavu-core fonts-ubuntu-console friendly-recovery fwupd-signed fwupd landscape-common mdadm mesa-vulkan-drivers openssh-server openssh-sftp-server pastebinit plymouth-theme-ubuntu-text plymouth pollinate popularity-contest pulseaudio-utils python3-apport  show-motd snapd sosreport sound-theme-freedesktop ubuntu-advantage-tools vim-common vim-runtime vim-tiny vim --autoremove

sudo apt -y install software-properties-common dirmngr apt-transport-https
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el,s390x] https://mirror.djvg.sg/mariadb/repo/10.6/ubuntu focal main'

sudo apt update
sudo apt -y upgrade
sudo apt -y install mariadb-server redis-server php7.4-cli php7.4-mysql
sudo mkdir -p /var/www/adminer
sudo wget -qO /var/www/adminer/index.php https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-en.php
cat <<EOF >/etc/wsl.conf
[boot]
command="service mariadb start; service redis-server start; php -S localhost:8000 -t /var/www/adminer"
EOF
