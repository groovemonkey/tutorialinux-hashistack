# TODO

- move python clients into containers
- run containers on nomad
- set up traefik or fabio
- serve traffic on the public Internet

- move nginx into container on nomad
    - it's a great demo of a single-host webserver using consul, though
- use auto-scaling groups for consul, nomad, and the consul-aware load balancer that I choose


## FEATURE TODOs
- service registration demo (little python program)
    - Install and run it on the nginx instance?
    - Create a systemd unit file to run the python app
    - Create a service registration config file
    - Create an HTTP health check file (should return 200)


python ---> nginx LB (https://learn.hashicorp.com/consul/integrations/nginx-consul-template)
    - or fabio? Traefik?

- service discovery demo
    - HTTP

- consul DNS setup
    - DNS service discovery demo

- load balancing demo


## SMALL TODOs:
- set hostnames (for shell prompt and consul)
- add node names in each config (set hostname?)

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
