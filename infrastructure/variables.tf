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
  type            = string
  default         = "ami-0cfda0fc60e54b0d4"
}
