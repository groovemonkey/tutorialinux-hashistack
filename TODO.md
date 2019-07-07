# TODO

Basic Setup Readme
- not automated
- set up aws account, create + download .pem key
- export aws key ID / key
- run terraform



Consul:
- consul isn't auto-starting

Web Servers:
- lock down -- should also only be accessible from bastion's IP, just like consul
- register nginx service with consul on startup (systemd unit file -- postexec?)

Bastion:
- install sshguard


Later:
- separate bastion into its own module?

create variables.tf file for infrastructure/:
- ami should be a base_ami variable
- key_name should be a var
- abstract cloud-autojoin tag + value into a var, and use everywhere

- install consul and consul-template via pacman -- the latest versions are in the community repo




terraform bug?
aws_internet_gateway.tutorialinux_gw: Still destroying... [id=igw-096629e213c5bd975, 9m10s elapsed]

can't manually detach igw from VPC -- error message:
Network vpc-059544e59fefc3f01 has some mapped public address(es). Please unmap those public address(es) before detaching the gateway.

terminated the EC2 host which was using it...