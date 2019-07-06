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
  # You can add resilence via cleverness by doing
  # subnet_id = subnet_ids[count % len(subnet_ids)]
  # That way, you'll just loop over the subnets repeatedly and get an even distribution of instances
  subnet_id               = "${element(split(",", var.subnet_ids), count.index)}"

  iam_instance_profile    = "${var.iam_instance_profile_name}"
  user_data               = "${file("${path.module}/config/consul-userdata.sh")}"
  vpc_security_group_ids  = ["${aws_security_group.consul.id}"]

  tags {
    Name = "consul-server-${count.index}"
    role = "consul-server"
  }
}


###############################################
# consul-servers are configured via user-data #
###############################################
data "template_file" "consul_server_userdata" {
  template = "${file("${path.module}/config/consul-userdata.sh.tpl")}"
  vars {
    CONSUL_VERSION = "1.5.2"
  }
}

data "template_file" "consul_server_config" {
  template = "${file("${path.module}/config/consul-server.json.tpl")}"
  vars {
    CONSUL_COUNT = 3
  }
}

# And a template file...
data "template_file" "consul_systemd_servicefile" {
  template = "${file("${path.module}/config/consul-systemd-service.conf.tpl")}"
}


####################################################
# A security group for our consul-server instances #
####################################################
resource "aws_security_group" "consul" {
  name   = "${var.name}"
  vpc_id = "${var.vpc_id}"

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
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
