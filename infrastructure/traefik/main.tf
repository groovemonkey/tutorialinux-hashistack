resource "aws_instance" "traefik" {
  ami                     = var.ami
  count                   = var.num_instances
  instance_type           = var.instance_type
  key_name                = var.key_name
  subnet_id               = var.public_subnet
  # availability_zone       = element(split(",", var.azs), count.index)
  vpc_security_group_ids  = [aws_security_group.traefik.id]

  tags = {
    Name                  = var.name
    role                  = var.name
  }
}


##########################################
# traefik is configured via template files #
##########################################
data "template_file" "traefik_userdata" {
  template = file("${path.module}/config/traefik-userdata.sh.tpl")
  vars = {
    BASE_PACKAGES_SNIPPET         = file("${path.module}/../shared_config/install_base_packages.sh")
    DNSMASQ_CONFIG_SNIPPET        = file("${path.module}/../shared_config/install_dnsmasq.sh")
    CONSUL_INSTALL_SNIPPET        = file("${path.module}/../shared_config/install_consul.sh")
    CONSUL_CLIENT_CONFIG_SNIPPET  = file("${path.module}/../shared_config/consul_client_config.sh")
    TRAEFIK_VERSION               = "v1.7.30"
  }
}


####################################
# A security group for our traefik #
####################################
resource "aws_security_group" "traefik" {
  name   = var.name
  vpc_id = var.vpc_id

  # HTTP/HTTPS allowed from our internal network
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  # non-production-grade: allow SSH from inside our network
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
