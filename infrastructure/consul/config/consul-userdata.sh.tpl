#!/usr/bin/env bash
set -eo pipefail

${BASE_PACKAGES_SNIPPET}

${DNSMASQ_CONFIG_SNIPPET}

${CONSUL_INSTALL_SNIPPET}

# Add the server config
cat <<EOF > "/etc/consul.d/consul.hcl"
{
  "datacenter": "tutorialinux",
  "server": true,
  "ui": true,
  "bootstrap_expect": 3,

  "data_dir": "/var/lib/consul",
  "retry_join": [
    "provider=aws tag_key=role tag_value=consul-server addr_type=private_v4"
  ],
  "client_addr": "0.0.0.0",
  "bind_addr": "{{GetInterfaceIP \"eth0\" }}",
  "leave_on_terminate": true,
  "enable_syslog": true
}
EOF

systemctl restart consul

# Could take a few seconds for consul to come up
echo "Waiting for consul to come up..."
sleep 10
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
