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
  ami                       = var.base_ec2_ami
  instance_type             = "t2.micro"
  # azs                       = "us-west-2a,us-west-2b,us-west-2c"
  key_name                  = "tutorialinux"
  # name MUST be consul-server so that consul auto-join works (instances will get a corresponding 'role' tag)
  name                      = "consul-server"
  subnet_id                 = aws_subnet.private.id
  vpc_id                    = aws_vpc.tutorialinux.id
  vpc_cidr                  = aws_vpc.tutorialinux.cidr_block
  bastion_connect           = module.bastion.bastion_public_ip
}

# This creates a nomad cluster
module "nomad" {
  source = "./nomad"
  ami                       = var.base_ec2_ami
  instance_type             = "t2.micro"
  # azs                       = "us-west-2a,us-west-2b,us-west-2c"
  nomad_cluster_size        = 3
  key_name                  = "tutorialinux"
  name                      = "nomad-server"
  subnet_id                 = aws_subnet.private.id
  vpc_id                    = aws_vpc.tutorialinux.id
  vpc_cidr                  = aws_vpc.tutorialinux.cidr_block
}

# This creates a haproxy host
module "haproxy" {
  source = "./haproxy"
  ami                       = var.base_ec2_ami
  instance_type             = "t2.micro"
  # azs                       = "us-west-2a,us-west-2b,us-west-2c"
  num_instances             = 1
  key_name                  = "tutorialinux"
  name                      = "haproxy"
  public_subnet             = aws_subnet.public.id
  vpc_id                    = aws_vpc.tutorialinux.id
  vpc_cidr                  = aws_vpc.tutorialinux.cidr_block
}

# This creates a traefik host
module "traefik" {
  source = "./traefik"
  ami                       = var.base_ec2_ami
  instance_type             = "t2.micro"
  # azs                       = "us-west-2a,us-west-2b,us-west-2c"
  num_instances             = 1
  key_name                  = "tutorialinux"
  name                      = "traefik"
  public_subnet             = aws_subnet.public.id
  vpc_id                    = aws_vpc.tutorialinux.id
  vpc_cidr                  = aws_vpc.tutorialinux.cidr_block
}

# This instantiates an nginx host, running the consul agent and reading from the consul KV store
# switched off for now, to pursue traefik/nomad-service stuff
// module "nginx" {
//   source = "./nginx"
//   ami                       = var.base_ec2_ami
//   instance_type             = "t2.micro"
//   key_name                  = "tutorialinux"
//   subnet_id                 = aws_subnet.public.id
//   vpc_id                    = aws_vpc.tutorialinux.id
// }
