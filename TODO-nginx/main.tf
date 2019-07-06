


# Instance



# Template file for config
data "template_file" "nginx_config" {
  template = "${file("${path.module}/config/nginx.cfg.tpl")}"

  vars {
    web1_priv_ip = "${digitalocean_droplet.web1.ipv4_address_private}"
    web2_priv_ip = "${digitalocean_droplet.web2.ipv4_address_private}"
  }
}

