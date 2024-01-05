#!/bin/bash
SITE_FQDN=$1
USER_EMAIL=$2

sudo apt update && sudo apt upgrade -y
#install pre-requisits
sudo apt install nginx php8.1-fpm php8.1-gd snapd unzip -y

#if [$REMOTE_USER -eq "root"]; then

#download AllSky Website
wget https://github.com/thomasjacquin/allsky-website/archive/refs/heads/master.zip
unzip master.zip
sudo mv allsky-website-master/ /var/www/allsky
sudo chown -R www-data:www-data /var/www/allsky
#add group write permissions
sudo chmod g+w allsky/ -R
ME=(whoami)
sudo gpasswd -a $ME www-data
sudo gpasswd -a www-data $ME
ln -s /var/www/allsky /home/$ME/allsky

#create nginx site 
{	printf 'server {\n'
	printf '  listen 80;\n'
	printf '  listen [::]:80;\n'
	printf "  server_name $SITE_FQDN;\n"
	printf '  root /var/www/allsky;\n'
	printf '\n'
	printf '  index index.php;\n'
	printf '\n'
	printf '  access_log  /var/log/nginx/access.log combined buffer=512k flush=1m;\n'
	printf '  error_log   /var/log/nginx/error.log warn;\n'
	printf '\n'
	printf '  location / {\n'
    printf '    try_files $uri $uri/ =404;\n'
	printf '  }\n'
	printf '\n'
	printf '  location ~ \.php$ {\n'
    printf '    include snippets/fastcgi-php.conf;\n'
	printf '\n'
    printf '    fastcgi_pass unix:/run/php/php8.1-fpm.sock;\n'
	printf '  }\n'
	printf '\n'
	printf '  # deny access to Apache .htaccess on Nginx with PHP, \n'
	printf '  # if Apache and Nginx document roots concur\n'
	printf '  location ~ /\.ht {\n'
    printf '    deny all;\n'
	printf '  }\n'
	printf '}\n'
} > /etc/nginx/sites-available/allsky
ln -s /etc/nginx/sites-available/allsky /etc/nginx/sites-enabled/allsky
rm /etc/nginx/sites-enabled/default

#Let's Encrypt install
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot --nginx -d $SITE_FQDN -m $USER_EMAIL --agree-tos -n
#to allow certbot to finish
sleep 10

#NTP Server update
sudo sed -i 's/#NTP=/NTP=0.us.pool.ntp.org/g' /etc/systemd/timesyncd.conf

#reboot
sudo shutdown -r now
