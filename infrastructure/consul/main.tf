# This module encapsulates all the resources we need for our consul cluster


# The following data source gets used if the user has
# specified a network load balancer.
# This will lock down the EC2 instance security group to
# just the subnets that the load balancer spans
# (which are the private subnets the Vault instances use)

data "aws_subnet" "subnet" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}

locals {
  subnet_cidr_blocks = [for s in data.aws_subnet.subnet : s.cidr_block]
}

resource "aws_launch_template" "consul" {
  name          = "${var.resource_name_prefix}-consul"
  image_id      = var.ami.id
  instance_type = var.instance_type
  key_name      = var.key_name != null ? var.key_name : null
  user_data     = base64encode(data.template_file.consul_server_userdata.rendered)
  vpc_security_group_ids = [
    aws_security_group.consul.id,
  ]

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_type           = "gp3"
      volume_size           = 100
      throughput            = 150
      iops                  = 3000
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.consul.name
  }
}

resource "aws_autoscaling_group" "consul" {
  name                = "${var.resource_name_prefix}-consul"
  min_size            = var.cluster_size
  max_size            = var.cluster_size
  desired_capacity    = var.cluster_size
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.consul.id
    version = "$Latest"
  }

  tags = concat(
    [
      {
        key                 = "Name"
        value               = "${var.resource_name_prefix}-consul-server"
        propagate_at_launch = true
      }
    ],
    [
      {
        key                 = "${var.resource_name_prefix}-consul"
        value               = "server"
        propagate_at_launch = true
      }
    ],
    [
      {
        key                 = "role"
        value               = var.name
        propagate_at_launch = true
      }
    ]
  )
}


################################################
# consul-servers are configured via a template #
################################################
data "template_file" "consul_server_userdata" {
  template = file("${path.module}/config/consul-userdata.sh.tpl")
  vars = {
    BASE_PACKAGES_SNIPPET         = file("${path.module}/../shared_config/install_base_packages.sh")
    DNSMASQ_CONFIG_SNIPPET        = file("${path.module}/../shared_config/install_dnsmasq.sh")
    CONSUL_INSTALL_SNIPPET        = file("${path.module}/../shared_config/install_consul.sh")
  }
}


####################################################
# A security group for our consul-server instances #
####################################################
resource "aws_security_group" "consul" {
  name   = var.name
  vpc_id = var.vpc_id
  tags   = {
    Name = var.name
  }

  # HTTP API
  ingress {
    protocol    = "TCP"
    from_port   = 8500
    to_port     = 8500
    cidr_blocks = local.subnet_cidr_blocks
  }

  # DNS
  ingress {
    protocol    = "tcp"
    from_port   = 8600
    to_port     = 8600
    cidr_blocks = local.subnet_cidr_blocks
  }
  ingress {
    protocol    = "udp"
    from_port   = 8600
    to_port     = 8600
    cidr_blocks = local.subnet_cidr_blocks
  }

  # Server RPC
  ingress {
    protocol    = "tcp"
    from_port   = 8300
    to_port     = 8300
    cidr_blocks = local.subnet_cidr_blocks
  }

  # LAN Serf
  ingress {
    protocol    = "tcp"
    from_port   = 8301
    to_port     = 8301
    cidr_blocks = local.subnet_cidr_blocks
  }
  ingress {
    protocol    = "udp"
    from_port   = 8301
    to_port     = 8301
    cidr_blocks = local.subnet_cidr_blocks
  }

  # Allow SSH from inside our VPC
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = local.subnet_cidr_blocks
  }

  # Allow ingress from bastion
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${var.bastion_private_ip}/24"]
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
    role = aws_iam_role.consul.name
}

resource "aws_iam_role_policy" "consul-server" {
    name = "consul-server"
    role = aws_iam_role.consul.name
    policy = <<EOF
{
    "Statement": [
        {
            "Sid": "consulautojoin",
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
