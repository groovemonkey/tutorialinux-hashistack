# Real-Life Operational Considerations

https://learn.hashicorp.com/consul/datacenter-deploy/production-checklist


## Backups

Upload to an s3 bucket:

`DATE=$(date +"%Y%m%d")`

```
consul snapshot save consul_state_${DATE}.snap
aws s3 cp consul_state_${DATE}.snap $S3_LOCATION
```

Restore:

```
aws s3 cp $S3_LOCATION consul_state_${DATE}.snap
consul snapshot restore consul_state_${DATE}.snap
```



## Adding/Wrapping External Services into Consul

https://learn.hashicorp.com/consul/developer-discovery/external

