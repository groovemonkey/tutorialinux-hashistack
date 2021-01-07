################
# Create a VPC #
################
resource "aws_vpc" "tutorialinux" {
  cidr_block      = "10.0.0.0/16"
  tags = {
    Name          = "tutorialinux"
  }
}

##################
# Private Subnet #
##################
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.tutorialinux.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.private_subnet_az

  tags = {
    Name                  = "tutorialinux-private"
  }
}

#################
# Public Subnet #
#################
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.tutorialinux.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.public_subnet_az
  map_public_ip_on_launch = true

  tags = {
    Name          = "tutorialinux-public"
  }
}

####################
# Internet Gateway #
####################
resource "aws_internet_gateway" "igw" {
  vpc_id          = aws_vpc.tutorialinux.id

  tags = {
    Name          = "tutorialinux-gw"
  }
}

###############
# NAT Gateway #
###############
resource "aws_eip" "nat" {
  vpc             = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id   = aws_eip.nat.id
  subnet_id       = aws_subnet.public.id

  tags = {
    Name          = "tutorialinux-nat-gw"
  }
}

##################
# Routing Tables #
##################
resource "aws_route_table" "public_routes" {
  vpc_id          = aws_vpc.tutorialinux.id
  route {
    cidr_block    = "0.0.0.0/0"
    gateway_id    = aws_internet_gateway.igw.id
  }
  tags = {
    Name          = "tutorialinux-public-routes"
  }
}

resource "aws_route_table" "private_routes" {
  vpc_id          = aws_vpc.tutorialinux.id
  route {
    cidr_block    = "0.0.0.0/0"
    gateway_id    = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name          = "tutorialinux-private-routes"
  }
}

resource "aws_route_table_association" "priv_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_routes.id
}

resource "aws_route_table_association" "pub_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_routes.id
}
