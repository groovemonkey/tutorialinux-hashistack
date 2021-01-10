# Consul Health Checks

You can't really have useful service discovery without health checking. Consul gives you two ways to register healthchecks:

1. check definition (config) files, and
1. the HTTP API (see the [python applications used in this course](python-clients/web.py))


There are a bunch of different kinds of checks types that you can register, depending on what you're checking and how you want to do it:

1. Script
1. HTTP
1. TCP
1. TTL
1. Docker
1. gRPC
1. Alias


Docs: https://www.consul.io/docs/agent/checks.html


## Ensure that enable_local_script_checks is turned on in the consul agent config

Check your config!


## Register a check with a config file

```
mkdir -p /etc/consul.d/checks

cat <<EOF > '/etc/consul.d/checks/nginx.json'
{
  "service": {
    "name": "nginx",
    "tags": [
      "web"
    ],
    "port": 80,
    "check": {
      "args": ["curl", "localhost"],
      "interval": "10s"
    }
  }
}
EOF

systemctl reload consul

```

## Test service health

`curl 'http://localhost:8500/v1/health/service/web?passing'`

`dig nginx.service.consul`


## Make the service unhealthy

Turn off nginx:

`systemctl stop nginx`


Consul will mark it as unhealthy:

`curl 'http://localhost:8500/v1/health/service/web?passing'`

`dig nginx.service.consul`


