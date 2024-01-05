#!/bin/bash

read -p "Enter remote username: " REMOTE_USER
read -p "Enter remote system IP: " REMOTE_SYSTEM
read -p "Enter remote FWDN: " SITE_FQDN
read -p "Enter email for SSL creation: " USER_EMAIL

ssh-keygen -t rsa
ssh-copy-id $REMOTE_USER@$REMOTE_SYSTEM

ssh -i ~/.ssh/id_rsa $REMOTE_USER@$REMOTE_SYSTEM "wget https://raw.githubusercontent.com/Dhovin/allsky-remote-setup/main/remote-setup.sh && sudo chmod +x remote-setup.sh && ./remote-setup.sh $SITE_FQDN $USER_EMAIL"

#update ftp-settings.sh
sed -i 's/PROTOCOL=""/PROTOCOL="scp"/g' ~/allsky/config/ftp-settings.sh
sed -i 's/IMAGE_DIR=""/IMAGE_DIR="allsky"/g' ~/allsky/config/ftp-settings.sh
sed -i 's/VIDEOS_DIR=""/VIDEOS_DIR="allsky/videos"/g' ~/allsky/config/ftp-settings.sh
sed -i 's/KEOGRAM_DIR=""/KEOGRAM_DIR="allsky/keograms"/g' ~/allsky/config/ftp-settings.sh
sed -i 's/STARTRAILS_DIR=""/STARTRAILS_DIR="allsky/startrails"/g' ~/allsky/config/ftp-settings.sh
sed -i 's/REMOTE_HOST=""/REMOTE_HOST="$REMOTE_SYSTEM"/g' ~/allsky/config/ftp-settings.sh
sed -i 's/REMOTE_USER=""/REMOTE_USER="$REMOTE_USER"/g' ~/allsky/config/ftp-settings.sh
sed -i 's/SSH_KEY_FILE=""/SSH_KEY_FILE="/home/$REMOTE_USER/.ssh/id_rsa""/g' ~/allsky/config/ftp-settings.sh
sudo systemctl restart allsky.service