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


### References
https://python-consul.readthedocs.io/en/latest/
