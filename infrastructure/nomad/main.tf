# This module encapsulates all the resources we need for our nomad cluster

###############################
# Our nomad-Server Instances #
###############################
resource "aws_instance" "nomad" {
  ami                     = var.ami
  count                   = var.nomad_cluster_size
  instance_type           = var.instance_type
  key_name                = var.key_name

  # A bit of extra cleverness if you have multiple subnets in different AZs:
  #   You can make this highly available by having 3 subnets (one in each of your region's Availability Zones) and then doing
  #
  #   availability_zone = var.azs[count.index % len(azs)]
  #
  # That way, you'll just loop over the subnets repeatedly and get an even distribution of instances
  # availability_zone       = element(split(",", var.azs), count.index)
  subnet_id               = var.subnet_id
  iam_instance_profile    = aws_iam_instance_profile.nomad.name
  user_data               = data.template_file.nomad_server_userdata.rendered
  vpc_security_group_ids  = [aws_security_group.nomad.id]

  tags = {
    Name                  = var.name
    role                  = var.name
  }
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
    NOMAD_COUNT                   = var.nomad_cluster_size
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
    cidr_blocks = [var.vpc_cidr]
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
