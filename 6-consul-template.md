# Consul-Template is the best tool ever

See the [official site and documentation](https://github.com/hashicorp/consul-template#quick-example) for details and the most up-to-date version number.

## Install consul-template

    export CURRENT_VERSION=0.25.1
    wget https://releases.hashicorp.com/consul-template/$CURRENT_VERSION/consul-template_$CURRENT_VERSION_linux_amd64.zip
    unzip consul-template_$CURRENT_VERSION_linux_amd64.zip
    sudo cp consul-template /usr/local/bin/


## Create a systemd service

    cat << EOF > /etc/systemd/systemconsul-template.service
    [Unit]
    Description=the consul-template service
    # presumes that consul is installed as a service (won't work with `consul agent -dev`)
    After=consul.service

    [Service]
    ExecStart=/usr/local/bin/consul-template -syslog -config /etc/consul-template.d/
    Restart=always
    KillSignal=SIGINT
    StandardOutput=null # using syslog

    [Install]
    WantedBy=multi-user.target

    EOF


## Create config directories/files
mkdir /etc/consul-template.d/


## Additional References
https://learn.hashicorp.com/tutorials/consul/consul-template
