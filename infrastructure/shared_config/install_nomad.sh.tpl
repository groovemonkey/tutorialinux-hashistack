# Add the nomad server/client config
echo "Setting up Nomad!"

echo "Installing Nomad"
apt-get install nomad

cat <<EOF > "/etc/nomad.d/nomad.hcl"
data_dir = "/var/lib/nomad"
bind_addr = "0.0.0.0"
leave_on_terminate = true
enable_syslog = true

# Running as both client and server is not what you want for production!
server {
    enabled = true
    bootstrap_expect = ${NOMAD_COUNT}
}
client {
    enabled = true
    template {
        disable_file_sandbox = true
    }
}
consul {
    address = "127.0.0.1:8500"
    ssl = false
}
EOF

echo "Enabling and starting Nomad!"
systemctl enable nomad
systemctl restart nomad