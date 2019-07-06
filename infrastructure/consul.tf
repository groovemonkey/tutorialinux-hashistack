module "consul" {
  source = "../consul"
  # Arch ebs-hvm-x86_64-stable for us-west-2 from https://www.uplinklabs.net/projects/arch-linux-on-ec2/
  ami = "ami-0f0ddbdc490ad09fd"
  azs = "us-west-2a,us-west-2b,us-west-2c"
  instance_type = "t2.micro"
  count = "3"

  key_name                  = "${var.key_name}"
  name                      = "${var.name}-consul"
  subnet_ids                = "${aws_subnet.private}"
  vpc_id                    = "${aws_vpc.tutorialinux.id}"
  vpc_cidr                  = "${aws_vpc.tutorialinux.cidr}"
  iam_instance_profile_name = "${aws_iam_instance_profile.consul}"
}
