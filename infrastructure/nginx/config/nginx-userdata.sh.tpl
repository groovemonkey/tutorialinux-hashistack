#!/usr/bin/env bash
set -eo pipefail

${BASE_PACKAGES_SNIPPET}

echo "Installing nginx-role-specific packages..."
apt-get install -y sshguard nginx python3 python3-venv

${DNSMASQ_CONFIG_SNIPPET}

${CONSUL_INSTALL_SNIPPET}

${CONSUL_CLIENT_CONFIG_SNIPPET}

${CONSUL_TPL_INSTALL_SNIPPET}

# Consul-template -- default systemd file requires vault??
cat <<EOF > '/usr/lib/systemd/system/consul-template.service'
[Unit]
Description=Hashicorp's amazing consul-template
After=consul.service

[Service]
ExecStart=/usr/local/bin/consul-template -max-stale 5s -template "/etc/consul-template/index.tpl:/usr/share/nginx/html/index.html"
Restart=always
RestartSec=5
KillSignal=SIGINT

[Install]
WantedBy=consul.service
EOF


# Consul-template nginx template
mkdir -p /etc/consul-template
cat <<EOF > '/etc/consul-template/index.tpl'
<!DOCTYPE html>
<html>
<head>
<title>Consul Madness!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Hello {{ key "/nginx/name" }}!</h1>
<p>It looks like you've got nginx configured If you see a value from the Consul Key-Value store above, that means you've got everything configured!</p>

<p>Here's the custom content you set in the consul KV store, at /nginx/content:</p>

<p class="blink">{{ key "/nginx/content" }}</p>

<!-- lol and thank you to http://fredericiana.com/2012/11/04/html5-blink-tag/ for the blink -->
<style>
.blink {
    color: red;
    animation-duration: 1s;
    animation-name: blink;
    animation-iteration-count: infinite;
    animation-timing-function: steps(2, start);
}
@keyframes blink {
    80% {
        visibility: hidden;
    }
}
</style>
</body>
</html>
EOF


# Python Application Config
echo "Setting up python application..."
set +eu # venv/bin/activate has an unset var :(
mkdir -p /usr/local/bin/tutorialinuxapp
cd /usr/local/bin/tutorialinuxapp
python3 -m venv venv
source venv/bin/activate
pip install python-consul gunicorn Flask
deactivate
set -eu

echo "Setting up gunicorn config..."
# Gunicorn config
cat <<EOF > '/usr/local/bin/tutorialinuxapp/wsgi.py'
from app import app

if __name__ == "__main__":
    app.run()
EOF

echo "Setting up systemd service for python example app..."
# Python app systemd service
cat <<EOF > '/usr/lib/systemd/system/tutorialinux-python-app.service'
[Unit]
Description=Tutorialinux Python Example App
After=consul.service

[Service]
WorkingDirectory=/usr/local/bin/tutorialinuxapp
Environment="PATH=/usr/local/bin/tutorialinuxapp/venv/bin"
ExecStart=/usr/local/bin/tutorialinuxapp/venv/bin/gunicorn --workers 3 --bind unix:myproject.sock -m 007 wsgi:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Python App Consul service registration and health check
cat <<EOF > '/etc/consul.d/python-service.json'
{
  "service": {
    "id": "python-web",
    "name": "python-web",
    "tags": ["primary"],
    "address": "",
    "meta": {
      "meta": "a tutorialinux Python web application example"
    },
    "port": 5000,
    "enable_tag_override": false,
    "checks": [
      {
          "id": "python-example",
          "name": "HTTP API on port 5000",
          "http": "http://localhost:5000/",
          "method": "GET",
          "interval": "10s",
          "timeout": "1s"
        }
    ]
  }
}
EOF


# nginx config for python app
mkdir -p /etc/nginx/sites-available
cat <<EOF > '/etc/nginx/sites-available/tutorialinux-python'
server {
    listen 80;
    server_name your_domain www.your_domain;

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/sammy/myproject/myproject.sock;
    }
}
EOF
ln -s /etc/nginx/sites-available/tutorialinux-python /etc/nginx/sites-enabled


echo "Enabling and starting consul-template..."
systemctl daemon-reload
systemctl enable consul-template
systemctl start consul-template

echo "Enabling and starting the tutorialinux-python-app service..."
systemctl enable tutorialinux-python-app
systemctl start tutorialinux-python-app

echo "Restarting nginx..."
systemctl restart nginx

echo "Done with our user-data script!"
