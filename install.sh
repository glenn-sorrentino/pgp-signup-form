#!/bin/bash

# Install required packages
apt-get update
apt-get install -y python3 python3-pip python3-venv nginx ufw openssh-server gnupg2

# Set up virtual environment and install required packages
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Set up firewall
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

# Configure Nginx
sed -i "s|{{PATH}}|$(pwd)/pgp-signup-form/app.py|g" pgp-signup-form.nginx
sed -i "s/{{DOMAIN}}/$1/g" pgp-signup-form.nginx
mv pgp-signup-form.nginx /etc/nginx/sites-enabled/

# Update default Nginx configuration
sed -i 's/# server_names_hash_bucket_size 64;/server_names_hash_bucket_size 64;/g' /etc/nginx/nginx.conf

# Restart Nginx
systemctl restart nginx

# Give ultimate trust to the PGP key
echo "allow-preset-passphrase" >> ~/.gnupg/gpg-agent.conf
echo "default-cache-ttl 604800" >> ~/.gnupg/gpg-agent.conf
echo "max-cache-ttl 604800" >> ~/.gnupg/gpg-agent.conf
echo "no-grab" >> ~/.gnupg/gpg-agent.conf
echo "default-key C11C21F89FD9B8610B3F3975AF5B672D287DB55C" >> ~/.gnupg/gpg.conf
echo "trust-model always" >> ~/.gnupg/gpg.conf
gpg --import public_key.asc
echo -e "5\ny\n" | gpg --command-fd 0 --expert --edit-key C11C21F89FD9B8610B3F3975AF5B672D287DB55C trust

# Start GPG agent
gpg-agent --daemon

# Start the application
cd pgp-signup-form/
python app.py
