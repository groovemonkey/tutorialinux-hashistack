####################
# Set up variables #
####################
variable "private_subnet_cidr" {
  type            = string
  description     = "The CIDR for our private subnet"
  default         = "10.0.1.0/24"
}

variable "public_subnet_cidr" {
  type            = string
  description     = "The CIDR for our public subnet"
  default         = "10.0.10.0/24"
}

variable "public_subnet_az" {
  type            = string
  default         = "us-west-2a"
}

variable "private_subnet_az" {
  type            = string
  default         = "us-west-2b"
}

variable "base_ec2_ami" {
  # us-west-2 ubuntu 20.04 HVM SSD
  default = "ami-07dd19a7900a1f049"
}
