module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "3.0.0"
  name                   = "${var.resource_name_prefix}-vpc"
  cidr                   = var.vpc_cidr
  azs                    = var.azs
  enable_nat_gateway     = true
  one_nat_gateway_per_az = true
  private_subnets        = var.private_subnet_cidrs
  public_subnets         = var.public_subnet_cidrs

  tags = var.common_tags

  private_subnet_tags = var.private_subnet_tags
}

output "private_subnet_tags" {
  description = "tags of private subnets that will be used to filter them while installing roles like Vault, Consul, and Nomad"
  value       = var.private_subnet_tags
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# output "private_subnet_ids" {
#   description = "List of IDs of private subnets"
#   value = module.vpc.private_subnets
# }


# output "public_subnet" {
#   description = "The (single/first) public subnet created by this module"
#   value       = module.vpc.public_subnets[0]
# }