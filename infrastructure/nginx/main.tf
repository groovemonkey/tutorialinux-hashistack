resource "aws_instance" "nginx" {
  ami                     = var.ami
  count                   = 1
  instance_type           = var.instance_type
  key_name                = var.key_name
  subnet_id               = var.subnet_id
  iam_instance_profile    = aws_iam_instance_profile.nginx.name
  user_data               = data.template_file.nginx_userdata.rendered
  vpc_security_group_ids  = [aws_security_group.nginx.id]

  tags = {
    Name = "nginx"
    role = "nginx"
  }

  # Two-step app move (put the .py script into Ubuntu's home, then create/move to privileged path)
  provisioner "file" {
    content               = file("${path.module}/config/python-app.py")
    destination           = "/home/ubuntu/app.py"
    connection {
      host                = self.public_ip
      user                = "ubuntu"
      private_key         = file("keys/${var.key_name}.pem")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /usr/local/bin/tutorialinuxapp",
      "sudo mv /home/ubuntu/app.py /usr/local/bin/tutorialinuxapp/"
    ]
    connection {
      host                = self.public_ip
      user                = "ubuntu"
      private_key         = file("keys/${var.key_name}.pem")
    }
  }

}


##########################################
# nginx is configured via template files #
##########################################
data "template_file" "nginx_userdata" {
  template = file("${path.module}/config/nginx-userdata.sh.tpl")
  vars = {
    BASE_PACKAGES_SNIPPET         = file("${path.module}/../shared_config/install_base_packages.sh")
    DNSMASQ_CONFIG_SNIPPET        = file("${path.module}/../shared_config/install_dnsmasq.sh")
    CONSUL_INSTALL_SNIPPET        = file("${path.module}/../shared_config/install_consul.sh")
    CONSUL_CLIENT_CONFIG_SNIPPET  = file("${path.module}/../shared_config/consul_client_config.sh")
    CONSUL_TPL_INSTALL_SNIPPET    = file("${path.module}/../shared_config/install_consul_template.sh")
  }
}


############################################
# A security group for our nginx instances #
############################################
resource "aws_security_group" "nginx" {
  name   = "nginx"
  vpc_id = var.vpc_id

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


################################################################
# IAM Role & Instance Profile that lets us use cloud auto-join #
################################################################
resource "aws_iam_instance_profile" "nginx" {
    name = "nginx"
    role = aws_iam_role.nginx.name
}

resource "aws_iam_role_policy" "nginx" {
    name = "nginx"
    role = aws_iam_role.nginx.name
    policy = <<EOF
{
    "Statement": [
        {
            "Sid": "nginxautojoin",
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

resource "aws_iam_role" "nginx" {
    name = "Nginx"
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