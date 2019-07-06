####################
# Set up variables #
####################
variable "private_subnet_cidr" {
  type = "string"
  description = "The CIDR for our private subnet"
  default = "10.0.1.0/24"
}

variable "public_subnet_cidr" {
  type = "string"
  description = "The CIDR for our public subnet"
  default = "10.0.10.0/24"
}

################
# Create a VPC #
################
resource "aws_vpc" "tutorialinux" {
  cidr_block = "10.0.0.0/16"
}

##################
# Private Subnet #
##################
resource "aws_subnet" "private" {
  vpc_id     = "${aws_vpc.tutorialinux.id}"
  cidr_block = "${var.private_subnet_cidr}"

  tags = {
    Name = "tutorialinux-private"
  }
}

#################
# Public Subnet #
#################
resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.tutorialinux.id}"
  cidr_block = "${var.public_subnet_cidr}"
  map_public_ip_on_launch = true

  tags = {
    Name = "tutorialinux-public"
  }
}

###############
# NAT Gateway #
###############
resource "aws_internet_gateway" "tutorialinux_gw" {
  vpc_id = "${aws_vpc.tutorialinux.id}"

  tags = {
    Name = "tutorialinux-gw"
  }
}

#################
# Routing Table #
#################
resource "aws_route_table" "tutorialinux_routes" {
  vpc_id = "${aws_vpc.tutorialinux.id}"

  route {
    cidr_block = "${var.private_subnet_cidr}"
    gateway_id = "${aws_internet_gateway.tutorialinux_gw.id}"
  }

  route {
    cidr_block = "${var.public_subnet_cidr}"
    gateway_id = "${aws_internet_gateway.tutorialinux_gw.id}"
  }

  tags = {
    Name = "tutorialinux-routes"
  }
}
