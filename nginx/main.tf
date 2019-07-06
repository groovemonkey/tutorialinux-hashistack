resource "aws_instance" "nginx" {
  ami                     = "${var.ami}"
  count                   = "${var.nginx_pool_size}"
  instance_type           = "${var.instance_type}"
  key_name                = "${var.key_name}"
  subnet_id               = "${var.subnet_id}"
  user_data               = "${data.template_file.nginx_userdata.rendered}"
  vpc_security_group_ids  = ["${aws_security_group.nginx.id}"]

  tags = {
    Name = "nginx-${count.index}"
    role = "nginx"
  }

  provisioner "file" {
    content     = "${file("${path.module}/config/consul-systemd-service.conf")}"
    destination = "/etc/systemd/system/consul.service"
    connection {
      host        = "${aws_instance.nginx}"
      user        = "root"
      private_key = "${file("../keys/tutorialinux.pem")}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.consul_client_config.rendered}"
    destination = "/usr/local/etc/consul/client.json"
    connection {
      host        = "${aws_instance.nginx}"
      user        = "root"
      private_key = "${file("../keys/tutorialinux.pem")}"
    }
  }

  provisioner "file" {
    content     = "${file("${path.module}/config/consul-template.service")}"
    destination = "/etc/systemd/system/consul-template.service"
    connection {
      host        = "${aws_instance.nginx}"
      user        = "root"
      private_key = "${file("../keys/tutorialinux.pem")}"
    }
  }

  provisioner "file" {
    content     = "${file("${path.module}/config/index.tpl")}"
    destination = "/usr/local/etc/consul-template/index.tpl"
    connection {
      host        = "${aws_instance.nginx}"
      user        = "root"
      private_key = "${file("../keys/tutorialinux.pem")}"
    }
  }

  provisioner "remote-exec" {
    connection {
      host        = "${aws_instance.nginx}"
      user        = "root"
      private_key = "${file("../keys/tutorialinux.pem")}"
    }
    inline = [
      "systemctl daemon-reload",
      "service nginx restart"
    ]
  }
}


##########################################
# nginx is configured via template files #
##########################################
data "template_file" "nginx_userdata" {
  template = "${file("${path.module}/config/nginx-userdata.sh.tpl")}"
  vars = {
    CONSUL_VERSION = "${var.consul_version}"
  }
}

data "template_file" "consul_client_config" {
  template = "${file("${path.module}/config/consul-client.json.tpl")}"
}


###################################################
# A security group for our nginx-server instances #
###################################################
resource "aws_security_group" "nginx" {
  name   = "nginx"
  vpc_id = "${var.vpc_id}"

  # HTTP allowed from the Internet
  ingress {
    protocol    = "TCP"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH allowed from the Internet
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
