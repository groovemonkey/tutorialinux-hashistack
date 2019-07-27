# TutoriaLinux Set-Up-Consul-With-Terraform extravaganza!
This code is all you'll need to follow along with the free mini-course I put up on YouTube.

It covers setting up a consul cluster, running in AWS, which

- has sane defaults
- is relatively close to production-ready
- uses Terraform to persist your Infrastructure as Code
- requires minimal fuss and configuration
- is easy to adapt to your existing CI pipeline, if you have one


Here's our architecture:

```
[nginx] --> uses consul-template to render something from the consul KV store
   |
   |
(consul) - (consul) - (consul) --> a 3-node consul cluster
```

I also ended up making a simple VPC config that creates a new VPC, a public and a private subnet, an internet gateway, and a routing table.



## Instructions

### AWS Setup

1. Create AWS Account, Log into AWS
1. Create + download a keypair in AWS EC2
1. `mv Downloads/tutorialinux.pem ./keys`
1. Add an IAM user with programmatic access & administrator perms; save access key ID + secret key in provider.tf
1. mv provider.tf infrastructure/


### Infrastructure Creation

1. `cd $THIS_REPOSITORY/infrastructure`
1. `terraform init`
1. `terraform plan`
1. `terraform apply`


### Log in to your instances

Remember that only instances in your public subnet are directly accessible from across the Internet. Bounce through the bastion host to get to hosts in your private subnet.

Use whatever key you created/downloaded for your terraform IAM user (above):

```
ssh-add keys/tutorialinux.pem
ssh -A root@$BASTION_IP

# From your bastion or web server, jump to your non-publicly-accessible consul instances
# (enter this command from the first server you SSH into)
ssh $CONSUL_IP
```


### Common troubleshooting tasks

See more verbose terraform output in your shell:
`export TF_LOG=DEBUG`


Have a look at the cloud-init log, or tail (-f follow) it:
`journalctl -u cloud-init`
`journalctl -fu cloud-init`

Consul:
`systemctl status consul`
`journalctl -fu cloud-init`



