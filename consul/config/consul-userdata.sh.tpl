#!/usr/bin/env bash

set -euo pipefail

echo "Starting system update..."
pacman --noconfirm -Syu

echo "Installing packages..."
pacman --noconfirm -Sy wget unzip consul

# Configure consul dns via systemd-resolved
cat <<EOF > "/etc/systemd/resolved.conf"
DNS=127.0.0.1
Domains=~consul
EOF

# Consul creates /usr/lib/systemd/system/consul.service

# Add the server config
cat <<EOF > "/etc/consul.d/server.json"
{
  "datacenter": "tutorialinux",
  "server": true,
  "ui": true,
  "bootstrap_expect": ${CONSUL_COUNT},

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

echo "Enabling and starting Consul!"
systemctl enable consul
systemctl start consul

# Could take a few seconds for consul to come up
echo "Waiting for consul to come up..."
sleep 30
set +e
until [[ $(curl localhost:8500/v1/status/leader) != "No known Consul servers" ]]
do
  sleep 5
  echo "waiting for consul..."
done
set -e

echo "Writing some data to the consul key-value store..."
consul kv put nginx/name "Dave"
consul kv put nginx/content "I love the Hashistack!"

echo "Done with our user-data script!"
