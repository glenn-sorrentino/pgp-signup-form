from flask import Flask, request, render_template, jsonify
from flask_cors import CORS
import gnupg

app = Flask(__name__)
CORS(app)

# Replace the path below with the path to your public key file
public_key_file = "public_key.asc"

# Initialize the GnuPG object
gpg = gnupg.GPG()

# Import the public key
with open(public_key_file, "r") as key_data:
    gpg.import_keys(key_data.read())

# The email address associated with the public key
recipient = "hello@glennsorrentino.com"

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/signup', methods=['POST'])
def signup():
    email = request.form['email']
    encrypted_email = gpg.encrypt(email, recipient)

    # Add debugging information
    print(f"Email: {email}")
    print(f"Recipient: {recipient}")
    print(f"Encrypted email status: {encrypted_email.status}")
    print(f"Encrypted email data: {encrypted_email.data}")
    print(f"Encrypted email stderr: {encrypted_email.stderr}")

    if encrypted_email.status == 'encryption ok':
        with open('encrypted_emails.txt', 'a') as f:
            f.write(str(encrypted_email))
            f.write('\n')
        return jsonify({'message': 'Email saved and encrypted successfully.'}), 200
    else:
        return jsonify({'message': 'Encryption failed. Please try again.'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
