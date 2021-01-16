#!/usr/bin/env bash

set -euo pipefail

# Kernel update breaks iptables
# echo "Starting system update..."
# pacman --noconfirm -Syu

echo "Installing packages..."
pacman --noconfirm -Sy wget unzip consul nomad

# Configure consul dns via systemd-resolved
cat <<EOF > "/etc/systemd/resolved.conf"
DNS=127.0.0.1
Domains=~consul
EOF

# Consul creates /usr/lib/systemd/system/consul.service

# Add the consul client config
cat <<EOF > "/etc/consul.d/agent.json"
{
  "datacenter": "tutorialinux",
  "server": false,
  "ui": false,

  "data_dir": "/var/lib/consul",
  "retry_join": [
    "provider=aws tag_key=role tag_value=consul-server"
  ],
  "client_addr": "0.0.0.0",
  # "bind_addr": "{{GetInterfaceIP \"eth0\" }}", # should be 0.0.0.0
  "leave_on_terminate": true,
  "enable_syslog": true,
}
EOF


# DNS Config
cat <<EOF > "/etc/systemd/resolved.conf"
DNS=127.0.0.1
Domains=~consul
EOF

# Persist our iptables rules
iptables -t nat -A OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
iptables -t nat -A OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600
iptables-save > /etc/iptables/iptables.rules

echo "Restarting systemd-resolved so that consul DNS config takes effect..."
systemctl restart systemd-resolved


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



# Add the nomad server/client config
echo "Setting up Nomad!"

mkdir -p /etc/nomad
cat <<EOF > "/etc/nomad/nomad.hcl"
data_dir = "/var/lib/nomad"
bind_addr = "0.0.0.0"
leave_on_terminate = true
enable_syslog = true

# Running as both client and server is not what you want for production!
server {
    enabled = true
    bootstrap_expect = ${NOMAD_COUNT}
}
client {
    enabled = true

}
consul {
    address = "127.0.0.1:8500"
    ssl = false
}
EOF


# Create the systemd unit file for nomad
cat <<EOF > "/etc/systemd/system/nomad.service"
[Unit]
Description=Nomad
Documentation=https://www.nomadproject.io/docs
Requires=network-online.target consul.service
After=network-online.target

[Service]
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/nomad agent -config /etc/nomad.d
KillMode=process
KillSignal=SIGINT
LimitNOFILE=infinity
LimitNPROC=infinity
Restart=on-failure
RestartSec=2
StartLimitBurst=3
StartLimitIntervalSec=10
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF

echo "Enabling and starting Nomad!"
systemctl enable nomad
systemctl start nomad

echo "Done with our user-data script!"
