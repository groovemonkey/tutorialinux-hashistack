# This module encapsulates all the resources we need for our nomad cluster


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

resource "aws_launch_template" "nomad" {
  name          = "${var.resource_name_prefix}-nomad"
  image_id      = var.ami.id
  instance_type = var.instance_type
  key_name      = var.key_name != null ? var.key_name : null
  user_data     = base64encode(data.template_file.nomad_server_userdata.rendered)
  vpc_security_group_ids = [
    aws_security_group.nomad.id,
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
    name = aws_iam_instance_profile.nomad.name
  }
}

resource "aws_autoscaling_group" "nomad" {
  name                = "${var.resource_name_prefix}-nomad"
  min_size            = var.cluster_size
  max_size            = var.cluster_size
  desired_capacity    = var.cluster_size
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.nomad.id
    version = "$Latest"
  }

  tags = concat(
    [
      {
        key                 = "Name"
        value               = "${var.resource_name_prefix}-nomad-server"
        propagate_at_launch = true
      }
    ],
    [
      {
        key                 = "${var.resource_name_prefix}-nomad"
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
# nomad-servers are configured via a template #
################################################
data "template_file" "nomad_server_userdata" {
  template = file("${path.module}/config/nomad-userdata.sh.tpl")
  vars = {
    BASE_PACKAGES_SNIPPET         = file("${path.module}/../shared_config/install_base_packages.sh")
    DNSMASQ_CONFIG_SNIPPET        = file("${path.module}/../shared_config/install_dnsmasq.sh")
    CONSUL_INSTALL_SNIPPET        = file("${path.module}/../shared_config/install_consul.sh")
    CONSUL_CLIENT_CONFIG_SNIPPET  = file("${path.module}/../shared_config/consul_client_config.sh")
    NOMAD_INSTALL_SNIPPET         = data.template_file.nomad_install_snippet.rendered
    CONSUL_TPL_INSTALL_SNIPPET    = file("${path.module}/../shared_config/install_consul_template.sh")
    ETHERPAD_NOMAD_JOB_SNIPPET    = file("${path.module}/config/etherpad-nomad-svc.hcl")
    ETHERPAD_CONFIG_SNIPPET       = file("${path.module}/config/etherpad-settings.json.tpl")
  }
}


data "template_file" "nomad_install_snippet" {
  template = file("${path.module}/../shared_config/install_nomad.sh.tpl")
  vars = {
    NOMAD_COUNT                   = var.cluster_size
  }
}

####################################################
# A security group for our nomad-server instances #
####################################################
resource "aws_security_group" "nomad" {
  name   = var.name
  vpc_id = var.vpc_id
  tags   = {
    Name = var.name
  }

  # Allow VPC Ingress
  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
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
resource "aws_iam_instance_profile" "nomad" {
    name = "nomad-server"
    role = aws_iam_role.nomad.name
}

resource "aws_iam_role_policy" "nomad-server" {
    name = "nomad-server"
    role = aws_iam_role.nomad.name
    policy = <<EOF
{
    "Statement": [
        {
            "Sid": "consulautojoinfornomad",
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

resource "aws_iam_role" "nomad" {
    name = "nomadServer"
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
