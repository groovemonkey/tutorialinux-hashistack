apt-get install -y dnsmasq

echo "Setting up dnsmasq"
cat <<EOF > "/etc/dnsmasq.conf"
listen-address=127.0.0.1
port=53
no-negcache
EOF

mkdir -p /etc/dnsmasq.d
cat <<EOF > "/etc/dnsmasq.d/10-consul"
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
EOF

# Exorcise the DAEMONNNNNZZZZ
echo "Removing systemd-resolved"
systemctl disable --now systemd-resolved

# not sure about this, but I'll try (appending to keep 127.0.0.53 and search us-west-2.compute.internal)
# rm -rf /etc/resolv.conf

echo "nameserver 127.0.0.1" >> /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

echo "Restarting dnsmasq!"
systemctl restart dnsmasq
systemctl enable dnsmasq
