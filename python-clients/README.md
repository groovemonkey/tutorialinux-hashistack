# TODO

## Setup
Run these commands from this python-clients directory.

    cd ./python-clients
    sudo apt-get install python3-venv


### Create a venv and use it

    python3 -m venv venv
    source venv/bin/activate


### Install prerequisites

    pip install -r requirements.txt


### Consul prereqs

1. Ensure consul-template is installed
1. Ensure Consul is running
1. ensure consul KV store contains a value for the key: web-demo-value
    consul kv put web-demo-value "schnooschnarbalurg"
1. Run the template command to render the index HTML (this will hang if the value doesn't exist in Consul's KV store):
    consul-template -template "consul-template/web-index.html.tpl:html/index.html" -once


### Run clients

    python web.py


### See what happens!

Check the [Services Tab](http://localhost:8500/ui/dc1/services) in the UI -- you'll see the [web service](http://localhost:8500/ui/dc1/services/web/instances) that your python script(s) just registered!

#### SRV records via DNS
Consul DNS is now also showing you SRV records for healthy instances of this service.

    dig @127.0.0.1 -p 8600 web.service.dc1.consul SRV

#### curl
If you've set up consul DNS to "just work" (via dnsmasq) then you can easily talk to a random, healthy instance of your web service:

    curl web.service.consul # requires an instance running on port 80

If you haven't set up consul DNS then you'll need to use the non-consul address:

    curl http://localhost:8900/



### References
https://python-consul.readthedocs.io/en/latest/
