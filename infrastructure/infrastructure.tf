module "consul" {
  source = "../consul"

  # Arch ebs-hvm-x86_64-stable for us-west-2 from https://www.uplinklabs.net/projects/arch-linux-on-ec2/
  ami                       = "ami-0f0ddbdc490ad09fd"
  consul_server_version     = "1.5.2"
  instance_type             = "t2.micro"

  azs                       = "us-west-2a,us-west-2b,us-west-2c"
  consul_cluster_size       = 3

  key_name                  = "tutorialinux"
  name                      = "tutorialinux-consul"
  subnet_id                 = "${aws_subnet.private.id}"
  vpc_id                    = "${aws_vpc.tutorialinux.id}"
  vpc_cidr                  = "${aws_vpc.tutorialinux.cidr_block}"
}

module "nginx" {
  source = "../nginx"
  ami                       = "ami-0f0ddbdc490ad09fd"
  nginx_pool_size           = 1
  consul_version            = "1.5.2"
  instance_type             = "t2.micro"
  key_name                  = "tutorialinux"
  subnet_id                 = "${aws_subnet.public.id}"
  vpc_id                    = "${aws_vpc.tutorialinux.id}"
}
