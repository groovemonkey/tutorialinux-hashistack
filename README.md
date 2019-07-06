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
