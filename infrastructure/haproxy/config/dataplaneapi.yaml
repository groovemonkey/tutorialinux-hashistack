# should be placed at /etc/haproxy/dataplaneapi.yaml

config_version: 2
name: haproxy1
dataplaneapi:
  # TODO does 0.0.0.0 work? This was a static address before
  host: 0.0.0.0
  port: 5555
  user:
  - name: ${HAPROXY_DATAPLANE_USER}
    password: ${HAPROXY_DATAPLANE_PASSWORD}
    # ugh TODO make secure, whatever that means
    insecure: true
