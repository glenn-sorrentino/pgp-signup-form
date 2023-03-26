#!/bin/bash

# Install required packages
apt-get update
apt-get install -y curl nginx ufw gnupg2 openssh-server python3-venv

# Enable firewall
ufw allow 'Nginx Full'
ufw --force enable

# Clone the code repository and install dependencies
cd /var/www/
git clone https://github.com/glenn-sorrentino/pgp-signup-form.git
cd pgp-signup-form
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Import the PGP public key and trust it ultimately
gpg --import /var/www/pgp-signup-form/public_key.asc
echo -e "5\ny\n" | gpg --command-fd 0 --expert --edit-key hello@glennsorrentino.com

# Configure Nginx
rm /etc/nginx/sites-enabled/default
cat > /etc/nginx/sites-enabled/pgp-signup-form <<EOF
server {
    listen 80;
    server_name pgp-signup-form.com;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Test Nginx configuration
nginx -t

# Start the Flask app
cd /var/www/pgp-signup-form
export FLASK_APP=app.py
flask run &

echo "The PGP signup form is now running at http://pgp-signup-form.com"
