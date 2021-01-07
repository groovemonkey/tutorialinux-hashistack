#!/usr/bin/env python3

## SETUP
# python3 -m venv venv
# source venv/bin/activate
# pip install python-consul Flask
# FLASK_APP=python-app.py flask run

## 3rd-PARTY LIBRARY DOCS
# https://flask.palletsprojects.com/en/1.1.x/quickstart/
# https://python-consul.readthedocs.io/en/latest/

from flask import Flask, request, jsonify
import consul as consul_library
import json
import socket

# Initialize our Flask app
app = Flask(__name__)

# Initialize our connection to consul
consul = consul_library.Consul()


def consul_get(path):
    index, data = consul.kv.get(path)
    if data['Value']:
        return json.load(data['Value'])
    else:
        return []


def register_with_consul_kv():
    '''Append our IP to a shared list kept in the KV store. Return 0 for success and 1 if our IP was already in the list.'''
    # Grab the current list of listening servers
    listening_list = consul_get('python-app/listening')

    # Add our IP
    my_ip = socket.gethostbyname(socket.getfqdn())

    if not my_ip in listening_list:
        listening_list.append(my_ip)
        # Re-serialize and write to the consul KV store
        consul.kv.put('python-app/listening', json.dumps(listening_list))
        return 0
    else:
        return 1


def deregister_with_consul_kv():
    '''Remove our IP from a shared list kept in the KV store. Return 0 for success and 1 if our IP was not in the list'''
    # Grab the current list of listening servers
    listening_list = consul_get('python-app/listening')
    if not listening_list:
        return 1

    # Remove our IP
    my_ip = socket.gethostbyname(socket.getfqdn())

    if my_ip in listening_list:
        listening_list.remove(my_ip)
        # Re-serialize and write to the consul KV store
        consul.kv.put('python-app/listening', json.dumps(listening_list))
        return 0
    else:
        return 1


def get_kv_registered_list():
    '''Return the JSON-formatted shared list kept in the KV store'''
    # Grab the current list of listening servers or create a new (empty) one
    listening_list = consul_get('python-app/listening')
    return jsonify(json.dumps(listening_list))


@app.route('/')
def index():
    return 'Welcome to the tutorialinux server registration app. Serving all your manual registration and deregistration needs! Valid paths are /register, /deregister, and /state.'


@app.route('/register')
def register():
    if register_with_consul_kv() == 0:
        return 'Registered!'
    else:
        return 'No need to register -- this IP was already in the list!'


@app.route('/deregister')
def deregister():
    if deregister_with_consul_kv() == 0:
        return 'Deregistered!'
    else:
        return 'No need to deregister -- this IP was not in the list!'


@app.route('/state')
def state():
    return jsonify(get_kv_registered_list())


if __name__ == "__main__":
    app.run(host='0.0.0.0')

