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

echo "Starting Consul!"
systemctl daemon-reload
systemctl enable consul
systemctl start consul
