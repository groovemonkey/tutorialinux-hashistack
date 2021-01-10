import consul
import http.server
import socket
import socketserver
import random

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
port = choose_server_port((8000,9000))
service_name = "web"

with socketserver.TCPServer(("", port), Handler) as httpd:
    print("Registering with Consul...")
    print("Now serving HTTP at port", port)
    httpd.serve_forever()

