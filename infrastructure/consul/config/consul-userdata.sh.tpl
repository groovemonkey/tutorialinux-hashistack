#!/usr/bin/env bash
set -eo pipefail
DEBIAN_FRONTEND=noninteractive

echo "Starting system update..."
apt-get update
apt-get -y upgrade

echo "Installing packages..."
apt-get install -y wget unzip dnsmasq


echo "Setting up dnsmasq"
cat <<EOF > "/etc/dnsmasq.conf"
listen-address=127.0.0.1
port=53
no-negcache
EOF

mkdir -p /etc/dnsmasq.d
cat <<EOF > "/etc/dnsmasq.d/10-consul"
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
EOF

# Exorcise the DAEMONNNNNZZZZ
systemctl disable --now systemd-resolved

# not sure about this, but I'll try (appending to keep 127.0.0.53 and search us-west-2.compute.internal)
# rm -rf /etc/resolv.conf

echo "nameserver 127.0.0.1" >> /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
systemctl restart dnsmasq
systemctl enable dnsmasq


echo "Installing Consul"
wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
unzip consul_${CONSUL_VERSION}_linux_amd64.zip
mv consul /usr/local/bin/consul

# user and group
groupadd consul
mkdir -p /var/lib/consul
useradd -d /var/lib/consul -g consul consul
chown consul:consul /var/lib/consul

# Add the consul agent systemd unit (service)
cat <<EOF > "/etc/systemd/system/consul.service"
[Unit]
Description=Consul Agent
Requires=network-online.target
After=network-online.target

[Service]
User=consul
Group=consul
Restart=on-failure
ExecStart=/usr/local/bin/consul agent $CONSUL_FLAGS -config-dir=/etc/consul.d
ExecReload=/usr/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF


# Add the server config
mkdir -p /etc/consul.d
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
  "client_addr": "0.0.0.0",
  "bind_addr": "{{GetInterfaceIP \"eth0\" }}",
  "leave_on_terminate": true,
  "enable_syslog": true
}
EOF


echo "Enabling and starting Consul!"
systemctl daemon-reload
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
