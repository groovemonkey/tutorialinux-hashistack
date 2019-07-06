# This module encapsulates all the resources we need for our consul cluster

###############################
# Our Consul-Server Instances #
###############################
resource "aws_instance" "consul" {
  ami                     = "${var.ami}"
  count                   = "${var.count}"
  instance_type           = "${var.instance_type}"
  key_name                = "${var.key_name}"

  # A bit of extra cleverness -- this will only work if you have a 3-node cluster
  # You can make this highly available by having 3 subnets (one in each of your region's Availability Zones) and then doing
  # subnet_id = subnet_ids[count % len(subnet_ids)]
  # That way, you'll just loop over the subnets repeatedly and get an even distribution of instances
  subnet_id               = "${element(split(",", var.subnet_ids), count.index)}"

  iam_instance_profile    = "${var.iam_instance_profile_name}"
  user_data               = "${data.template_file.consul_server_userdata.rendered}"
  vpc_security_group_ids  = ["${aws_security_group.consul.id}"]

  tags {
    Name = "consul-server-${count.index}"
    role = "consul-server"
  }

  provisioner "file" {
    content     = "${data.template_file.consul_server_config.rendered}"
    destination = "/etc/consul.d/server.json"
  }

  provisioner "file" {
    content     = "${data.template_file.consul_systemd_servicefile.rendered}"
    destination = "/etc/systemd/system/consul.service"
  }

  # Might not be needed, if the cloud-init.target works
  # provisioner "remote-exec" {
  #     inline = [
  #       "service consul start"
  #     ]
  # }
}


####################################################
# consul-servers are configured via template files #
####################################################
data "template_file" "consul_server_userdata" {
  template = "${file("${path.module}/config/consul-userdata.sh.tpl")}"
  vars {
    CONSUL_VERSION = "${var.consul_server_version}"
  }
}

data "template_file" "consul_server_config" {
  template = "${file("${path.module}/config/consul-server.json.tpl")}"
  vars {
    CONSUL_COUNT = "${var.consul_cluster_size}"
  }
}

data "template_file" "consul_systemd_servicefile" {
  template = "${file("${path.module}/config/consul-systemd-service.conf.tpl")}"
}


####################################################
# A security group for our consul-server instances #
####################################################
resource "aws_security_group" "consul" {
  name   = "${var.name}"
  vpc_id = "${var.vpc_id}"

  # HTTP API
  ingress {
    protocol    = "TCP"
    from_port   = 8500
    to_port     = 8500
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # DNS
  ingress {
    protocol    = -1
    from_port   = 8600
    to_port     = 8600
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # LAN Serf
  ingress {
    protocol    = -1
    from_port   = 8301
    to_port     = 8301
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


################################################################
# IAM Role & Instance Profile that lets us use cloud auto-join #
################################################################
resource "aws_iam_instance_profile" "consul" {
    name = "consul-server"
    role = "${aws_iam_role.consul.name}"
}

resource "aws_iam_role_policy" "consul-server" {
    name = "consul-server"
    role = "${aws_iam_role.consul.name}"
    policy = <<EOF
{
    "Statement": [
        {
            "Sid": "consul-autojoin",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "consul" {
    name = "ConsulServer"
    path = "/"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
