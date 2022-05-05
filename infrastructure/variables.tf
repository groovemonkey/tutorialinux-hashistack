####################
# Set up variables #
####################
variable "resource_name_prefix" {
  type            = string
  description     = "A prefix for resources -- maybe, one day, all resources."
  default         = "tutorialinux"
}

# variable "public_subnet_cidr" {
#   type            = string
#   description     = "The CIDR for our public subnet"
#   default         = "10.0.10.0/24"
# }

# variable "public_subnet_az" {
#   type            = string
#   default         = "us-west-2a"
# }

# variable "private_subnet_cidr1" {
#   type            = string
#   description     = "The CIDR for our private subnet"
#   default         = "10.0.1.0/24"
# }

# variable "private_subnet_az1" {
#   type            = string
#   default         = "us-west-2a"
# }

# variable "private_subnet_cidr2" {
#   type            = string
#   description     = "The CIDR for our private subnet"
#   default         = "10.0.2.0/24"
# }

# variable "private_subnet_az2" {
#   type            = string
#   default         = "us-west-2b"
# }

# variable "private_subnet_cidr3" {
#   type            = string
#   description     = "The CIDR for our private subnet"
#   default         = "10.0.3.0/24"
# }

# variable "private_subnet_az3" {
#   type            = string
#   default         = "us-west-2c"
# }


## VPC Module Variables
variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-west-2"
}

variable "azs" {
  description = "availability zones to use in AWS region"
  type        = list(string)
  default = [
    "us-west-2a",
    "us-west-2b",
    "us-west-2c",
  ]
}

variable "common_tags" {
  type        = map(string)
  description = "Tags for VPC resources"
  default = {
    Vault = "dev"
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.0.0/19",
    "10.0.32.0/19",
    "10.0.64.0/19",
  ]
}

variable "private_subnet_tags" {
  type        = map(string)
  description = "Tags for private subnets."
  default = {
    Vault = "deploy"
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.128.0/20",
    "10.0.144.0/20",
    "10.0.160.0/20",
  ]
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}
