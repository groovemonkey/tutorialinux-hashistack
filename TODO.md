# TODO

Basic Setup Readme
- not automated
- set up aws account, create + download .pem key
- export aws key ID / key
- run terraform



Bastion:
- remove? The extra security/indirection/complication is not really needed.

Consul:
- add node names in each config (set hostname?)

Nginx:
- register nginx service with consul on startup (systemd unit file -- postexec?)


create variables.tf file for infrastructure/:
- ami should be a base_ami variable
- key_name should be a var
- abstract cloud-autojoin tag + value into a var, and use everywhere



terraform bug?
aws_internet_gateway.tutorialinux_gw: Still destroying... [id=igw-096629e213c5bd975, 9m10s elapsed]

can't manually detach igw from VPC -- error message:
Network vpc-059544e59fefc3f01 has some mapped public address(es). Please unmap those public address(es) before detaching the gateway.

terminated the EC2 host which was using it...