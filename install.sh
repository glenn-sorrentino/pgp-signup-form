#!/bin/bash

# Install required packages
apt-get update && apt-get install -y nginx python3-pip python3 git

# Clone repository and install dependencies
git clone https://github.com/glenn-sorrentino/pgp-signup-form.git
cd pgp-signup-form
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt

# Configure nginx
cat <<EOF >/etc/nginx/sites-available/pgp-signup-form
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
ln -sf /etc/nginx/sites-available/pgp-signup-form /etc/nginx/sites-enabled/pgp-signup-form
nginx -t && systemctl restart nginx

# Setup firewall
ufw allow 'Nginx Full'

echo "Installation complete."
