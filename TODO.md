# TODO

Basic Setup Readme
- not automated
- set up aws account, create + download .pem key
- export aws key ID / key
- run terraform





## FEATURE TODOs
- service registration demo (a little python program?)

python ---> nginx LB (https://learn.hashicorp.com/consul/integrations/nginx-consul-template)
    - or fabio? Traefik?

- service discovery demo
    - HTTP

- consul DNS setup
    - DNS service discovery demo

- load balancing demo


## SMALL TODOs:

Bastion:
- remove? The extra security/indirection/complication is not really needed.

Consul:
- add command for ssh -L tunneling to the consul UI
- add node names in each config (set hostname?)

Nginx:
- register nginx service with consul on startup (systemd unit file -- postexec?)


create variables.tf file for infrastructure/:
- ami should be a base_ami variable
- key_name should be a var
- abstract cloud-autojoin tag + value into a var, and use everywhere



## ARCHIVE

### OFFICIAL DOCS (learn.hashicorp.com sections)

Getting Started
    - Install Consul
    - Run the Agent
    - Register Services
    - Consul UI
    - Consul Connect: Service Mesh (prod guide: https://learn.hashicorp.com/consul/developer-mesh/connect-production)
    - Clustering
    - Health Checks
    - Key-Value Store

Day 1: Deploying your first Datacenter
    - Reference Architecture
    - Datacenter Backups
    - Prod Checklist

Day 2: Advanced Operations and Maintenance
    - Consul Cluster Monitoring and Metrics
    - Adding and Removing Servers
    - Autopilot
    - Outage Recovery
    - Cross-Datacenter ACL Replication
    - Troubleshooting (https://learn.hashicorp.com/consul/day-2-operations/troubleshooting)
