#!/usr/bin/env bash
set -eo pipefail

# from https://www.haproxy.com/blog/consul-service-discovery-for-haproxy/
# seems to have been written in 2021


${BASE_PACKAGES_SNIPPET}

${DNSMASQ_CONFIG_SNIPPET}

# TODO does this need to be a consul client? I don't actually think so...
${CONSUL_INSTALL_SNIPPET}

${CONSUL_CLIENT_CONFIG_SNIPPET}


add-apt-repository -y ppa:vbernat/haproxy-${HAPROXY_PPA_VERSION}
apt update
DEBIAN_FRONTEND=noninteractive apt install -y haproxy

# install haproxy dataplane API
wget https://github.com/haproxytech/dataplaneapi/releases/download/v${DATAPLANE_API_VERSION}/dataplaneapi_${DATAPLANE_API_VERSION}_Linux_x86_64.tar.gz
tar -zxvf dataplaneapi_${DATAPLANE_API_VERSION}_Linux_x86_64.tar.gz
cp build/dataplaneapi /usr/local/bin/
chmod +x /usr/local/bin/dataplaneapi

echo
echo "set haproxy's main config"
mkdir -p /etc/haproxy
cat <<EOF > '/etc/haproxy/haproxy.cfg'
${HAPROXY_MAIN_CONFIG_SNIPPET}
EOF

echo
echo "set haproxy's dataplane config"
cat <<EOF > '/etc/haproxy/dataplaneapi.yaml'
${HAPROXY_DATAPLANE_CONFIG_SNIPPET}
EOF

echo
echo "restart to make config changes take effect"
systemctl restart haproxy

echo "sleeping because localhost:5555 wasn't up yet before"
sleep 20

# activate the Consul API on haproxy
# TODO: there must be another way to activate this via config?
curl -u ${HAPROXY_DATAPLANE_USER}:${HAPROXY_DATAPLANE_PASSWORD} \
       -H 'Content-Type: application/json' \
       -d '{
             "address": "consul.service.consul",
             "port": 8500,
             "enabled": true,
             "retry_timeout": 10
           }' http://localhost:5555/v2/service_discovery/consul


echo
echo "SUCCESS: Finished running haproxy userdata script."

