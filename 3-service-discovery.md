# Service discovery


## TODO Add Service registration





## Service Discovery

### DNS API
dig @127.0.0.1 -p 8600 web.service.consul

#### Service records
dig @127.0.0.1 -p 8600 web.service.consul SRV


#### TODO run consul dns on port 53


#### Tag-based queries
dig @127.0.0.1 -p 8600 nginx.web.service.consul SRV
dig @127.0.0.1 -p 8600 rails.service.consul SRV



### HTTP API

You'll probably want to use `jq` to filter this stuff

# See all registered 'web' services
curl http://localhost:8500/v1/catalog/service/web

# See only healthy ones
curl 'http://localhost:8500/v1/health/service/web?passing'
