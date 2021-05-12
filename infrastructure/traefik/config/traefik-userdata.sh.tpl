#!/usr/bin/env bash
set -eo pipefail

${BASE_PACKAGES_SNIPPET}

echo "Installing traefik-role-specific packages..."
wget https://github.com/traefik/traefik/releases/download/${TRAEFIK_VERSION}/traefik_linux-amd64
cp traefik_linux-amd64 /usr/local/bin/traefik
chmod +x /usr/local/bin/traefik

${DNSMASQ_CONFIG_SNIPPET}

${CONSUL_INSTALL_SNIPPET}

${CONSUL_CLIENT_CONFIG_SNIPPET}

# Add traefik systemd unit file
cat <<EOF > "/usr/lib/systemd/system/traefik.service"
[Unit]
Description=Traefik
Requires=network-online.target
After=network-online.target

[Service]
# run traefik with consul provider enabled (passing command-line args is MUTUTALLY exclusive with a config file)
ExecStart=/usr/local/bin/traefik --providers.consul

Restart=on-failure
ExecReload=/usr/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF

echo "Starting Traefik!"
systemctl daemon-reload
systemctl enable traefik
systemctl start traefik



echo "Done with our user-data script!"
