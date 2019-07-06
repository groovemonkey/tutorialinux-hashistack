# TODO

Basic Setup Readme
- not automated
- set up aws account, create + download .pem key
- export aws key ID / key
- run terraform


Network
- test network setup

Consul:
- bastion box? Or provision nginx server at the same time and use it as a bounce host?
- test basic config
- am I mixing normal resources and modules correctly?

Web Servers:
- register nginx service with consul on startup (systemd unit file -- postexec?)


Later:
create variables.tf file for infrastructure/:
- ami should be a base_ami variable
- key_name should be a var
- abstract cloud-autojoin tag + value into a var, and use everywhere

- install consul and consul-template via pacman -- the latest versions are in the community repo
