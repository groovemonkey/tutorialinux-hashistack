#!/usr/bin/env bash

set -eo pipefail

echo "Installing packages..."
apt-get install -y wget unzip curl dnsmasq

# Add nomad Apt repository
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Kernel update breaks iptables
# echo "Starting system update..."
apt-get update && apt-get upgrade -y


echo "Setting up dnsmasq"
mkdir -p /etc/dnsmasq.d

cat <<EOF > "/etc/dnsmasq.d/10-consul"
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
EOF


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
cat <<EOF > "/usr/lib/systemd/system/consul.service"
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

# Add the consul client config
mkdir -p /etc/consul.d
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

echo "Installing Nomad"
apt-get install nomad

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

echo "Enabling and starting Nomad!"
systemctl enable nomad
systemctl start nomad

echo "Done with our user-data script!"
