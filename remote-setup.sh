#!/bin/bash
sudo apt update && sudo apt upgrade -y
#install pre-requisits
sudo apt install nginx php8.1-fpm php8.1-gd snapd unzip -y
#download AllSky Website
wget https://github.com/thomasjacquin/allsky-website/archive/refs/heads/master.zip
mkdir allsky
unzip master.zip
sudo mv allsky-website-master/ allsky/
#sudo chown -R www-data:www-data /var/www/allsky
#create nginx site 
{	printf 'server {\n'
	printf '  listen 80;\n'
	printf '  listen [::]:80;\n'
	printf '  server_name allsky.dhovin.me;\n'
	printf '  set $base /var/www/allsky.dhovin.me;\n'
	printf '  root $base/home/dhovin/allsky;\n'
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
sudo certbot --nginx -d allsky.dhovin.me -m dhovin@gmail.com --agree-tos -n
#NTP Server update
#sudo nano /etc/systemd/timesyncd.conf
sudo sed -i 's/#NTP=/NTP=0.us.pool.ntp.org/g' /etc/systemd/timesyncd.conf
#reboot
sudo shutdown -r now

