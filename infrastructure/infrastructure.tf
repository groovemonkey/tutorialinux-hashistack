# This creates a bastion host
module "bastion" {
  source = "./bastion"
  public_subnet             = aws_subnet.public.id
  ami                       = var.base_ec2_ami
  instance_type             = "t2.micro"
  key_name                  = "tutorialinux"
  vpc_id                    = aws_vpc.tutorialinux.id
}

# This creates a consul cluster
module "consul" {
  source = "./consul"

  # Arch ebs-hvm-x86_64-stable for us-west-2 from https://www.uplinklabs.net/projects/arch-linux-on-ec2/
  ami                       = var.base_ec2_ami
  instance_type             = "t2.micro"
  azs                       = "us-west-2a,us-west-2b,us-west-2c"
  consul_cluster_size       = 3
  key_name                  = "tutorialinux"
  name                      = "tutorialinux-consul"
  subnet_id                 = aws_subnet.private.id
  vpc_id                    = aws_vpc.tutorialinux.id
  vpc_cidr                  = aws_vpc.tutorialinux.cidr_block
  bastion_connect           = module.bastion.bastion_public_ip
}

# This creates a nomad cluster
module "nomad" {
  source = "./nomad"

  # Arch ebs-hvm-x86_64-stable for us-west-2 from https://www.uplinklabs.net/projects/arch-linux-on-ec2/
  ami                       = var.base_ec2_ami
  instance_type             = "t2.micro"
  azs                       = "us-west-2a,us-west-2b,us-west-2c"
  nomad_cluster_size        = 3
  key_name                  = "tutorialinux"
  name                      = "tutorialinux-nomad"
  subnet_id                 = aws_subnet.private.id
  vpc_id                    = aws_vpc.tutorialinux.id
  vpc_cidr                  = aws_vpc.tutorialinux.cidr_block
}

# This creates a traefik host
module "traefik" {
  source = "./traefik"
  public_subnet             = aws_subnet.public.id
  ami                       = var.base_ec2_ami
  instance_type             = "t2.micro"
  key_name                  = "tutorialinux"
  vpc_id                    = aws_vpc.tutorialinux.id
  vpc_cidr                  = aws_vpc.tutorialinux.cidr_block
}

# This instantiates an nginx host, running the consul agent and reading from the consul KV store
module "nginx" {
  source = "./nginx"
  ami                       = var.base_ec2_ami
  instance_type             = "t2.micro"
  key_name                  = "tutorialinux"
  subnet_id                 = aws_subnet.public.id
  vpc_id                    = aws_vpc.tutorialinux.id
}
