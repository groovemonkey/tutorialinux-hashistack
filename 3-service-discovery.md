# Service discovery


## TODO Add Service registration





## Service Discovery

### DNS API
Either run it on port 53, or use something like dnsmasq to route specific requests (i.e. for the .consul TLD) to the consul DNS service on its standard port (8600).

    dig @127.0.0.1 -p 8600 web.service.consul

Setting up consul DNS to work seamlessly via e.g. dnsmasq enables you to do things like:

    curl web.service.consul

(That would return ONLY healthy instances of the 'web' service in the Consul service catalog, provided it's on a well-known port)


#### Service records
dig @127.0.0.1 -p 8600 web.service.consul SRV

#### Tag-based queries
dig @127.0.0.1 -p 8600 nginx.web.service.consul SRV
dig @127.0.0.1 -p 8600 rails.service.consul SRV



### HTTP API

You'll probably want to use `jq` to filter this stuff

# See all registered 'web' services
curl http://localhost:8500/v1/catalog/service/web

# See only healthy ones
curl 'http://localhost:8500/v1/health/service/web?passing'
