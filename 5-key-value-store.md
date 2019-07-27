# Consul Key-Value (KV) Store


## On a consul member:
consul kv put nginx/name "Dave"
consul kv get nginx/content "This is some content"
consul kv get nginx/stuff "Foobar"

consul kv put nginx/name "Steve" # update

consul kv delete nginx/name
consul kv delete -recurse nginx

## Show UI

