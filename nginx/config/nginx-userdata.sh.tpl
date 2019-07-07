#!/usr/bin/env bash

set -euo pipefail

echo "Starting system update..."
yes | pacman -Syu

echo "Installing packages..."
yes | pacman -Sy nginx wget unzip

# Avoiding potential race conditions between cloud-init and terraform provisioners
mkdir /usr/local/etc/consul/
mkdir /usr/local/etc/consul-template/

# Consul Install
echo "Starting consul install..."
cd /tmp
wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
unzip consul_${CONSUL_VERSION}_linux_amd64.zip
mv consul /usr/local/bin/

# Consul-template install
echo "Starting consul-template install"
wget https://releases.hashicorp.com/consul-template/0.20.0/consul-template_0.20.0_linux_amd64.zip
unzip consul-template_0.20.0_linux_amd64.zip
mv consul-template /usr/local/bin/

echo "Done with our user-data script!"
