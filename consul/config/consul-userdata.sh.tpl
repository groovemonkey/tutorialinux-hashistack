#!/usr/bin/env bash

yes | pacman -Syu
yes | pacman -Sy wget

wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
