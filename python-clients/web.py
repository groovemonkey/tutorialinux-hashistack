import consul
import http.server
import socket
import socketserver
import random
import sys

"""
Takes a port number and returns True if it's available for the web server to use; False otherwise.
"""
def is_port_available(port_num):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    result = sock.connect_ex(('127.0.0.1', port_num))

    if result == 0:
        print("Port {0} is open, trying another port".format(port_num))
        return False
    else:
        print("Port {0} is not open; using it".format(port_num))
        return True
    sock.close()


"""
Takes a port-range tuple and returns a port number that can be used for the web server.
"""
def choose_server_port(range_tuple):
    chosen = False
    while not chosen:
        test_port = random.randrange(range_tuple[0], range_tuple[1])
        if is_port_available(test_port):
            return test_port


##############
# Server Setup
##############
class DaveHttpRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.path = 'html/index.html'
        return http.server.SimpleHTTPRequestHandler.do_GET(self)

Handler = DaveHttpRequestHandler

# Try the user-supplied port, else pick a random one
if len(sys.argv) > 1 and is_port_available(int(sys.argv[1])):
    port = int(sys.argv[1])
else:
    port = choose_server_port((8000,9000)) # (port range)
    print("Using port {0}".format(port))

consul_service_name = "web"
# Slight cleverness to get a unique service ID
consul_service_id = "{0}-{1}".format(consul_service_name, port)

with socketserver.TCPServer(("", port), Handler) as httpd:
    try:
        print("Connecting to Consul...")
        c = consul.Consul()
        c.agent.members() # hit the API to see if it's working
    except:
        print("Failed to connect to Consul...do you have an agent running?")
        sys.exit(1)

    print("Creating a service healthcheck...")
    web_check = consul.Check.http(url="http://localhost:{0}/".format(port), interval="10s", timeout="5s")

    # Register service + check
    print("Registering service...")
    c.agent.Service.register(c.agent, name=consul_service_name, service_id=consul_service_id, port=port, check=web_check)

    # Run webserver
    try:
        print("Now serving HTTP at port", port)
        httpd.serve_forever()
    finally:
        # Cleanup
        print("Server stopped; deregistering from the Consul service catalog")
        c.agent.Service.deregister(c.agent, service_id=consul_service_id)
        print("Exiting!")
