#!/bin/bash

# Update packages and install dependencies
sudo apt update
sudo apt install -y gnupg nginx openssh-server python3 python3-venv python3-pip ufw curl

# Enable firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw --force enable

# Import public key
curl -sSL https://raw.githubusercontent.com/glenn-sorrentino/pgp-signup-form/master/public_key.asc | gpg --import

# Set ultimate trust for public key
echo "Setting ultimate trust for key"
echo -e "5\ny\n" | gpg --command-fd 0 --edit-key "hello@glennsorrentino.com" trust

# Clone repository and set up Flask app
git clone https://github.com/glenn-sorrentino/pgp-signup-form.git
cd pgp-signup-form
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt

# Run Flask app with Nginx
sudo tee /etc/nginx/sites-available/pgp-signup-form <<EOF
server {
    listen 80 default_server;
    server_name _;
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
sudo ln -s /etc/nginx/sites-available/pgp-signup-form /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
python3 app.py
