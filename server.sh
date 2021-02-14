apt update
apt purge -y --autoremove alsa-topology-conf alsa-ucm-conf apport-symptoms apport bolt eatmydata ed eject pastebinit plymouth-theme-ubuntu-text plymouth pollinate popularity-contest python3-apport python3-problem-report snapd sosreport sound-theme-freedesktop vim-common vim-runtime vim-tiny vim
apt upgrade

apt install -y software-properties-common
add-apt-repository -y ppa:ondrej/php
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://sgp1.mirrors.digitalocean.com/mariadb/repo/10.5/ubuntu focal main'
curl -sL https://deb.nodesource.com/setup_14.x | bash -

apt -y install nginx

apt -y install mariadb-server

apt -y install php7.4-fpm php7.4-dom php7.4-mysql php7.4-curl php7.4-ctype php7.4-curl php7.4-dom php7.4-gd php7.4-iconv php7.4-json php7.4-mbstring php7.4-posix php7.4-xml php7.4-zip php7.4-fileinfo php7.4-bz2 php7.4-intl php7.4-exif php7.4-apcu php7.4-imagick php7.4-bcmath php7.4-gmp

apt -y install nodejs npm
npm i -g pm2

apt install p7zip-full

mysql_secure_insallation

cd /var/www
wget https://download.nextcloud.com/server/releases/latest-20.zip
7za x latest-20.zip
rm latest-20.zip
mv nextcloud cloud
chown -R www-data:www-data cloud

mkdir /etc/nginx/ssl
mkdir /etc/nginx/ssl/letsencrypt
mkdir /etc/nginx/ssl/cloudflare
cd /etc/nginx/ssl
openssl genrsa 4096 > account.key
openssl req -new -sha256 -key domain.key -subj "/" -addext "subjectAltName = DNS:sheepymeh.tk, DNS:www.sheepymeh.tk, DNS:cloud.sheepymeh.tk, DNS:dev.sheepymeh.tk" -addext "1.3.6.1.5.5.7.1.24 = DER:30:03:02:01:05" > sheepymeh.csr
wget https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py
python3 acme_tiny.py --account-key account.key --csr sheepymeh.csr --acme-dir /var/www/acme/ > /etc/nginx/ssl/letsencrypt/cert.pem

chmod a-x /etc/update-motd.d/10-help-text /etc/update-motd.d/50-motd-news

useradd -m sheepymeh -G sudo -s /bin/bash
chage -d 0 sheepymeh
