# PGP Signup Form

These instructions will guide you through setting up the Signup Flask app for production environment using the Gunicorn WSGI HTTP server and the Nginx reverse proxy server.

![pgp](https://user-images.githubusercontent.com/28545431/227760266-2d9ed5ff-91b3-43df-831a-356004b21ff9.png)

## Requirements

* Ubuntu 18.04 or higher
* Python 3.x
* Git
* Pip3

## Installation

1. Update the system packages:

    ```
    sudo apt update
    sudo apt upgrade
    ```

2. Install Python 3, Git, and Pip3:

    ```
    sudo apt install python3 python3-pip git
    ```

3. Clone the Signup Flask app from GitHub:

    ```
    git clone https://github.com/username/signup.git
    ```

4. Change into the project directory:

    ```
    cd signup
    ```

5. Create and activate a Python virtual environment:

    ```
    python3 -m venv venv
    source venv/bin/activate
    ```

6. Install the project dependencies:

    ```
    pip3 install -r requirements.txt
    ```

7. Exit the virtual environment:

    ```
    deactivate
    ```

## Configuring Gunicorn

1. Install Gunicorn:

    ```
    pip3 install gunicorn
    ```

2. Create a Gunicorn configuration file:

    ```
    sudo nano /etc/systemd/system/gunicorn.service
    ```

3. Add the following configuration to the file:

    ```
    [Unit]
    Description=Gunicorn instance to serve Signup Flask app
    After=network.target

    [Service]
    User=<your_username>
    Group=www-data
    WorkingDirectory=/home/<your_username>/signup
    ExecStart=/home/<your_username>/signup/venv/bin/gunicorn app:app -b localhost:8000 --workers 3

    [Install]
    WantedBy=multi-user.target
    ```

4. Reload the system daemon:

    ```
    sudo systemctl daemon-reload
    ```

5. Start and enable the Gunicorn service:

    ```
    sudo systemctl start gunicorn
    sudo systemctl enable gunicorn
    ```

## Configuring Nginx

1. Install Nginx:

    ```
    sudo apt install nginx
    ```

2. Create a server block configuration file:

    ```
    sudo nano /etc/nginx/sites-available/signup
    ```

3. Add the following configuration to the file:

    ```
    server {
        listen 80;
        server_name your_domain www.your_domain;

        location / {
            proxy_pass http://localhost:8000;
            include /etc/nginx/proxy_params;
            proxy_redirect off;
        }
    }
    ```

4. Enable the server block:

    ```
    sudo ln -s /etc/nginx/sites-available/signup /etc/nginx/sites-enabled/
    ```

5. Test the Nginx configuration:

    ```
    sudo nginx -t
    ```

6. Restart Nginx:

    ```
    sudo systemctl restart nginx
    ```

7. Allow Nginx through the firewall:

    ```
    sudo ufw allow 'Nginx Full'
    ```

## Conclusion

You have now successfully set up the Signup Flask app for production environment using Gunicorn and Nginx.


