#!/usr/bin/env bash

set -euo pipefail

echo "Starting system update..."
pacman --noconfirm -Syu

echo "Installing packages..."
pacman --noconfirm -Sy nginx wget unzip consul consul-template


# Consul client config
cat <<EOF > "/etc/consul.d/client.json"
{
  "datacenter": "tutorialinux",
  "data_dir": "/var/lib/consul",
  "retry_join": [
    "provider=aws tag_key=role tag_value=consul-server"
  ],
  "ports": {
    "dns": 53
  },
  "client_addr": "0.0.0.0",
  "bind_addr": "{{GetInterfaceIP \"eth0\" }}",
  "leave_on_terminate": true,
  "enable_syslog": true,
  "disable_update_check": true,
  "enable_debug": true
}
EOF


# Consul-template -- default systemd file requires vault??
cat <<EOF > "/usr/lib/systemd/system/consul-template.service"
[Unit]
Description=Hashicorp's amazing consul-template
After=consul.service

[Service]
ExecStart=/usr/bin/consul-template -max-stale 5s -template "/etc/consul-template/index.tpl:/usr/share/nginx/html/index.html"
Restart=always
RestartSec=5
KillSignal=SIGINT

[Install]
WantedBy=consul.service
EOF


# Consul-template nginx template
cat <<EOF > "/etc/consul-template/index.tpl"
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

systemctl daemon-reload

echo "Starting Consul!"
systemctl enable consul
systemctl start consul

echo "Enabling and starting consul-template..."
systemctl enable consul-template
systemctl start consul-template

echo "Restarting nginx..."
systemctl restart nginx

echo "Done with our user-data script!"
