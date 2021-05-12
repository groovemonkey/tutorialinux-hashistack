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

# The AWS Marketplace is awash in scams, use https://cloud-images.ubuntu.com/locator/ec2/
variable "base_ec2_ami" {
  # us-west-2 amd64 ubuntu 20.04 HVM SSD, updated 05-10-2021
  default = "ami-09c3a3d3af3a0bd2e"
}
