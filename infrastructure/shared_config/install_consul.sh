echo "Installing Consul"
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install consul

# the package is not quite there yet...
mkdir /var/lib/consul
chown consul:consul /var/lib/consul

# remove the default config file that the package managers added...
rm /etc/consul.d/consul.hcl

systemctl enable consul
systemctl restart consul
