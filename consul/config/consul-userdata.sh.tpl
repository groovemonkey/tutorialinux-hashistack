#!/usr/bin/env bash

set -euo pipefail

echo "Starting system update..."
yes | pacman -Syu

echo "Installing packages..."
yes | pacman -Sy wget unzip

echo "Starting consul install..."
cd /tmp
wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
unzip consul_${CONSUL_VERSION}_linux_amd64.zip
mv consul /usr/local/bin

echo "Done with our user-data script!"
