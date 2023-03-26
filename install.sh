#!/bin/bash

# Install required packages
apt update
apt install -y nginx python3 python3-pip git ufw openssh-server

# Install virtualenv
pip3 install virtualenv

# Clone the repository
git clone https://github.com/glenn-sorrentino/pgp-signup-form.git

# Create and activate virtualenv
cd pgp-signup-form
virtualenv venv
source venv/bin/activate

# Install dependencies
pip3 install -r requirements.txt

# Update nginx config
sed -i 's/server_name example.com/server_name pgp-signup-form/g' /etc/nginx/sites-available/default
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

# Restart nginx
systemctl restart nginx

# Enable firewall
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw enable

# Run the app
python3 app.py
