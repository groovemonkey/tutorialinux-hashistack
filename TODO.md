# TODO

- move python clients into containers
- serve traffic on the public Internet

- move nginx into container on nomad
    - it's a great demo of a single-host webserver using consul, though
- use auto-scaling groups for consul, nomad, and traefik
- use an ELB for traefik

- service discovery demo
    - HTTP

- consul DNS setup
    - DNS service discovery demo

- load balancing demo


## SMALL TODOs:
- DNS is a little messed up - e.g. sudo -i takes really long because there's something that times out
    sudo: unable to resolve host ip-10-0-10-172: Name or service not known

- set hostnames (for shell prompt and consul)
- add node names in each config (set hostname?) (not a small TODO actually)

Nginx:
- register nginx service with consul on startup (systemd unit file -- postexec?)



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
