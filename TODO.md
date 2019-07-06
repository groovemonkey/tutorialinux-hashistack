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
- install nginx
- download and install consul-template
- feed in consul template file via a provisioner
- register nginx service with consul on startup (systemd unit file -- postexec?)

