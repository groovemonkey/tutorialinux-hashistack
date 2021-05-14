resource "aws_instance" "bastion" {
  ami                     = var.ami
  instance_type           = var.instance_type
  key_name                = var.key_name
  subnet_id               = var.public_subnet
  vpc_security_group_ids  = [aws_security_group.bastion.id]

  tags = {
    Name = "bastion"
    role = "bastion"
  }

  provisioner "remote-exec" {
    connection {
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("keys/${var.key_name}.pem")
      timeout     = "5m"
    }
    inline = [
      "sleep 30 && sudo apt-get update && sudo apt-get install -y sshguard"
    ]
  }
}

####################################
# A security group for our bastion #
####################################
resource "aws_security_group" "bastion" {
  name   = "bastion"
  vpc_id = var.vpc_id

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
