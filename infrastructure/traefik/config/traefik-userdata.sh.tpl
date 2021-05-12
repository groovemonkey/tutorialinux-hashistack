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

echo "Installing consul-template"
wget https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
sudo cp consul-template /usr/local/bin/

echo "Done with our user-data script!"
