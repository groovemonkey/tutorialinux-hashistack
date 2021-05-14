echo "Installing consul-template"
CONSUL_TEMPLATE_VERSION=0.25.2
wget https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
cp consul-template /usr/local/bin/
