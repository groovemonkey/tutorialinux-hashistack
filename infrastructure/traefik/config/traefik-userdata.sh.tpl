#!/usr/bin/env bash
set -eo pipefail

${BASE_PACKAGES_SNIPPET}

echo "Installing traefik-role-specific packages..."
wget https://github.com/traefik/traefik/releases/download/v2.4.8/traefik_v2.4.8_linux_amd64.tar.gz
tar -zxf traefik_v2.4.8_linux_amd64.tar.gz
cp traefik /usr/local/bin/traefik
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
ExecStart=/usr/local/bin/traefik --configFile=/etc/traefik/traefik.yaml

Restart=on-failure
ExecReload=/usr/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF


# Add config file in default location
mkdir /etc/traefik
cat <<EOF > "/etc/traefik/traefik.yaml"
${TRAEFIK_STATIC_CONFIG_SNIPPET}
EOF

cat <<EOF > "/etc/traefik/dynamic.yaml"
${TRAEFIK_DYN_CONFIG_SNIPPET}
EOF

echo "Starting Traefik!"
systemctl daemon-reload
systemctl enable traefik
systemctl start traefik



echo "Done with our user-data script!"
