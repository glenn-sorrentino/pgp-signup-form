#!/bin/bash

# Install required packages
apt-get update
apt-get install -y curl nginx python3 python3-pip python3-venv ufw openssh-server gnupg

# Configure firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw --force enable

# Clone the code
curl -sSL https://github.com/glenn-sorrentino/pgp-signup-form/archive/main.tar.gz | tar -xz
cd pgp-signup-form

# Import the PGP key
gpg --import public_key.asc

# Set trust level to ultimate
echo "Setting ultimate trust for key"
echo "trust 7B437253F81116E1B1DBFF69D5F9B36A5DC2CAF0" | gpg --batch --yes --command-fd 0 --edit-key demo@scidsg.org

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip3 install -r requirements.txt

# Start the app
export FLASK_APP=app.py
flask run --host=0.0.0.0
