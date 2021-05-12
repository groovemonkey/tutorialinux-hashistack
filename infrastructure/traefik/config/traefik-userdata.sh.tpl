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

echo "Done with our user-data script!"
