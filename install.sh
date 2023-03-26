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
cd pgp-signup-form-main

# Import the PGP key
gpg --import public_key.asc

# Ask user to trust the key
read -e -i "n" -p "Do you want to trust the key used to demo this app? (y/n) " trust_key
if [[ "$trust_key" == "y" ]]; then
    # Set trust level to ultimate
    echo "Setting ultimate trust for key"
    echo "trust C11C21F89FD9B8610B3F3975AF5B672D287DB55C" | gpg --batch --yes --command-fd 0 --edit-key hello@glennsorrentino.com
else
    echo "Not setting ultimate trust for key"
fi

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip3 install -r requirements.txt

# Start the app
export FLASK_APP=app.py
flask run --host=0.0.0.0
