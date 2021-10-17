#!/bin/bash
#####################################################
#Script to create SSL Let`s Encrypt Cert
#####################################################

echo "Do You Want to install SSL cert for your website?"
read -p "Enter y or yes to continue, enter whatever to skip: " confirm
if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then 
sudo apt install snapd
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot --apache

sudo certbot renew --dry-run
fi

