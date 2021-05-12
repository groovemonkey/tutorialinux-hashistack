variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "public_subnet" {}
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "consul_version" {
    default = "1.9.1"
}