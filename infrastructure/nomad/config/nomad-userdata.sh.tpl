#!/usr/bin/env bash
set -eo pipefail

${BASE_PACKAGES_SNIPPET}

# Add nomad Apt repository
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update

# Add docker (to enable nomad docker driver)
apt-get -y install docker.io

${DNSMASQ_CONFIG_SNIPPET}

${CONSUL_INSTALL_SNIPPET}

${CONSUL_CLIENT_CONFIG_SNIPPET}

${NOMAD_INSTALL_SNIPPET}

${CONSUL_TPL_INSTALL_SNIPPET}

# Install demo application
cat <<EOF > "/etc/nomad.d/etherpad.jobspec"
${ETHERPAD_NOMAD_JOB_SNIPPET}
EOF

# Write demo application settings file
cat <<EOF > "/etc/nomad.d/etherpad-settings.json.tpl"
${ETHERPAD_CONFIG_SNIPPET}
EOF

echo "Done with our user-data script!"
