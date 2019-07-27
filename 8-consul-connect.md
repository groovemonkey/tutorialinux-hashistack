# Consul Connect

Encrypt and authorize traffic between services.

## TODO check prod configuration/setup for consul connect
- unencrypted traffic on loopback interface only

## TODO create your insecure web service (e.g. tiny python web service)



## Register your insecure service

```
cat <<EOF > '/etc/consul.d/python-webapp.json'
{
  "service": {
    "name": "python-webapp",
    "port": 3000,
    "connect": { "sidecar_service": {} }
  }
}
EOF
```

## Reload/SIGHUP consul to re-read configuration
systemctl reload consul




## Live Demo
### Run consul connect proxy in a separate process
consul connect proxy -sidecar-for python-webapp


### Configure consul to use that consul connect proxy
This looks for a consul-connect capable endpoint for this service.

consul connect proxy -service web -upstream python-webapp:3000





## Configuration (same as Live Demo above)

### Create a 'web' service with a sidecar registration that configures python-web as an upstream dependency
```
cat <<EOF > '/etc/consul.d/web.json'
{
  "service": {
    "name": "web",
    "port": 8080,
    "connect": {
      "sidecar_service": {
        "proxy": {
          "upstreams": [{
             "destination_name": "python-web",
             "local_bind_port": 3000
          }]
        }
      }
    }
  }
}
EOF
```

Make sure consul sees the new config:
`consul reload`



### Start the web proxy

`consul connect proxy -sidecar-for web`




