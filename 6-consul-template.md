# Consul-Template is the best tool ever

If you ever want to use some of Consul's amazing features with a non-consul aware application, consul-template can be a fantastic way to do it. Some examples of ways that I've used it:

1. Dynamically configure an always-up-to-date list of `haproxy` backends as different services join and leave the consul cluster.
1. Dynamically configure secrets or configuration values for your running applications -- one change in the consul KV can reconfigure all running services that use that config value. See this [example service killswitch](https://www.youtube.com/watch?v=2Hnz9prnZis).
1. Configure a dynamically updated upstream list for nginx -- e.g. scale your WordPress php-fpm pools up or down as needed, with no service interruption.


See the [official site and documentation](https://github.com/hashicorp/consul-template#quick-example) for details and the most up-to-date version number.

## Install consul-template

    export CURRENT_VERSION=0.25.1
    wget https://releases.hashicorp.com/consul-template/$CURRENT_VERSION/consul-template_$CURRENT_VERSION_linux_amd64.zip
    unzip consul-template_$CURRENT_VERSION_linux_amd64.zip
    sudo cp consul-template /usr/local/bin/


## Create a systemd service

    cat << EOF > /etc/systemd/system/consul-template.service
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


## Example template
If you store the example configuration below in a file, `/etc/consul-template.d/tutorialinux`, it would automatically be picked up when the consul-template service starts up (due to the `-config` flag in the ExecStart statement in the unit file above). Here's what the consul-template process would then do:

* Look for the file defined as the `source`.
* Interpret that file as a consul-template.
* Render the resulting content at the `destination`.
* KEEP Re-rendering it any time the content would change based on consul or vault key changes, service catalog changes, address changes, etc.

    template {
        source = "/etc/tutorialinux/config-example-consultemplate.tpl
        destination = "/etc/tutorialinux/config.json
        command = "bash -c 'systemctl reload-or-restart --no-block tutorialinux.service'"
    }

## Additional References
https://learn.hashicorp.com/tutorials/consul/consul-template
