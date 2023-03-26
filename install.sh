#!/bin/bash

# Update package list
apt-get update

# Install dependencies
apt-get install -y nginx python3-pip python3 git ufw openssh-server

# Clone repository
REPO_NAME="pgp-signup-form"
mkdir $REPO_NAME
git clone https://github.com/glenn-sorrentino/$REPO_NAME.git $REPO_NAME

# Create virtual environment and install dependencies
cd $REPO_NAME
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt

# Configure Nginx
cp nginx_config /etc/nginx/sites-available/$REPO_NAME
ln -s /etc/nginx/sites-available/$REPO_NAME /etc/nginx/sites-enabled/$REPO_NAME
sed -i 's/server_name example.com;/server_name localhost;/g' /etc/nginx/sites-available/$REPO_NAME

# Start Nginx
systemctl restart nginx

# Configure firewall
ufw allow 'Nginx Full'
ufw allow 'OpenSSH'
ufw enable
