#!/usr/bin/env bash
set -eo pipefail

${BASE_PACKAGES_SNIPPET}

# Add nomad Apt repository
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update

${DNSMASQ_CONFIG_SNIPPET}

${CONSUL_CLIENT_CONFIG_SNIPPET}

${CONSUL_INSTALL_SNIPPET}

${NOMAD_INSTALL_SNIPPET}

echo "Done with our user-data script!"
