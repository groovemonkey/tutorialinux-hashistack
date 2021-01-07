resource "aws_instance" "nginx" {
  ami                     = var.ami
  count                   = var.nginx_pool_size
  instance_type           = var.instance_type
  key_name                = var.key_name
  subnet_id               = var.subnet_id
  iam_instance_profile    = aws_iam_instance_profile.nginx.name
  user_data               = data.template_file.nginx_userdata.rendered
  vpc_security_group_ids  = [aws_security_group.nginx.id]

  tags = {
    Name = "nginx-${count.index}"
    role = "nginx"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /usr/local/bin/tutorialinuxapp"
    ]
    connection {
      host                = self.public_ip
      user                = "root"
      private_key         = file("../keys/tutorialinux.pem")
    }
  }

  provisioner "file" {
    content               = file("${path.module}/config/python-app.py")
    destination           = "/usr/local/bin/tutorialinuxapp/app.py"
    connection {
      host                = self.public_ip
      user                = "root"
      private_key         = file("../keys/tutorialinux.pem")
    }
  }

}


######################################
# nginx is configured via a template #
######################################
data "template_file" "nginx_userdata" {
  template = file("${path.module}/config/nginx-userdata.sh.tpl")
  # vars = {
  #   CONSUL_VERSION = var.consul_version
  # }
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