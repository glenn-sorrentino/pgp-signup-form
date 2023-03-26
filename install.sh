#!/bin/bash

# Install dependencies
sudo apt update
sudo apt -y upgrade
sudo apt -y install nginx python3-pip python3-venv git ufw openssh-server gnupg2

# Clone repository
if [ ! -d "pgp-signup-form" ]; then
  git clone https://github.com/glenn-sorrentino/pgp-signup-form.git
fi

# Set up virtual environment and install dependencies
cd pgp-signup-form
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt

# Configure nginx
sudo unlink /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/pgp-signup-form /etc/nginx/sites-enabled/pgp-signup-form
sudo sed -i 's|/path/to/pgp-signup-form|'"$(pwd)"'|g' /etc/nginx/sites-enabled/pgp-signup-form
sudo sed -i 's|server_name example.com;|server_name localhost;|g' /etc/nginx/sites-enabled/pgp-signup-form
sudo nginx -t
sudo systemctl restart nginx

# Configure firewall
sudo ufw allow 'Nginx Full'
sudo ufw allow 'OpenSSH'
echo "y" | sudo ufw enable

# Import and trust PGP key
gpg --import pgp-key.pub
echo "5" | gpg --command-fd 0 --expert --edit-key hello@glennsorrentino.com trust

# Start the app
export FLASK_APP=app.py
flask run --host=0.0.0.0
