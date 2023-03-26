#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Install required packages
apt update
apt install -y python3 python3-pip git nginx

# Clone the PGP Signup Form repository
git clone https://github.com/glenn-sorrentino/pgp-signup-form.git

# Change to project directory
cd pgp-signup-form

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install required dependencies
pip3 install -r requirements.txt

# Configure Gunicorn service
cat << EOF > /etc/systemd/system/gunicorn.service
[Unit]
Description=Gunicorn instance to serve Signup Flask app
After=network.target

[Service]
User=root
Group=www-data
WorkingDirectory=/root/pgp-signup-form
ExecStart=/root/pgp-signup-form/venv/bin/gunicorn app:app -b localhost:8000 --workers 3

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd manager configuration
systemctl daemon-reload

# Enable and start Gunicorn service
systemctl enable gunicorn
systemctl start gunicorn

# Configure Nginx server block
cat << EOF > /etc/nginx/sites-available/signup
server {
    listen 80;
    server_name $domain;

    location / {
        proxy_pass http://localhost:8000;
        include /etc/nginx/proxy_params;
        proxy_redirect off;
    }
}
EOF

# Create symbolic link to enable server block
ln -s /etc/nginx/sites-available/signup /etc/nginx/sites-enabled/

# Test Nginx configuration and restart service
nginx -t && systemctl restart nginx

# Allow Nginx through firewall
ufw allow 'Nginx Full'

echo "Installation complete."
