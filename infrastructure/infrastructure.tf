# This creates a bastion host
module "bastion" {
  source = "./bastion"
  public_subnet             = module.vpc.public_subnets[0]
  ami                       = data.aws_ami.ubuntu
  instance_type             = "t3.small"
  key_name                  = "tutorialinux"
  vpc_id                    = module.vpc.vpc_id
}

# This creates a consul cluster
module "consul" {
  source = "./consul"
  ami                       = data.aws_ami.ubuntu
  instance_type             = "t3.small"
  cluster_size              = 3
  key_name                  = "tutorialinux"
  # name MUST be consul-server so that consul auto-join works (instances will get a corresponding 'role' tag)
  name                      = "consul-server"
  subnet_ids                = module.vpc.private_subnets
  vpc_id                    = module.vpc.vpc_id
  vpc_cidr                  = var.vpc_cidr
  bastion_private_ip        = module.bastion.bastion_private_ip
}

# This creates a nomad cluster
module "nomad" {
  source = "./nomad"
  ami                       = data.aws_ami.ubuntu
  instance_type             = "t3.small"
  cluster_size              = 3
  key_name                  = "tutorialinux"
  name                      = "nomad-server"
  subnet_ids                = module.vpc.private_subnets
  vpc_id                    = module.vpc.vpc_id
  vpc_cidr                  = var.vpc_cidr
  bastion_private_ip        = module.bastion.bastion_private_ip
}

# This creates a haproxy host
module "haproxy" {
  source = "./haproxy"
  ami                       = data.aws_ami.ubuntu
  instance_type             = "t3.small"
  num_instances             = 1
  key_name                  = "tutorialinux"
  name                      = "haproxy"
  public_subnet             = module.vpc.public_subnets[0]
  vpc_id                    = module.vpc.vpc_id
  vpc_cidr                  = var.vpc_cidr
}

# This creates a traefik host
# module "traefik" {
#   source = "./traefik"
#   ami                       = data.aws_ami.ubuntu
#   instance_type             = "t3.small"
#   # azs                       = "us-west-2a,us-west-2b,us-west-2c"
#   num_instances             = 1
#   key_name                  = "tutorialinux"
#   name                      = "traefik"
  # # public_subnet             = var.public_subnet_cidrs[0]
  # public_subnet             = var.public_subnet_cidrs
#   vpc_id                    = module.vpc.vpc_id
#   vpc_cidr                  = var.vpc_cidr
# }

# This instantiates an nginx host, running the consul agent and reading from the consul KV store
# switched off for now, to pursue traefik/nomad-service stuff
# module "nginx" {
#   source = "./nginx"
#   ami                       = data.aws_ami.ubuntu
#   instance_type             = "t3.small"
#   key_name                  = "tutorialinux"
# # public_subnet             = var.public_subnet_cidrs[0]
  # public_subnet             = var.public_subnet_cidrs
#   vpc_id                    = module.vpc.vpc_id
# }
