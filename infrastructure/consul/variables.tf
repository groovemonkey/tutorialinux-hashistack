variable "name" {}
variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "subnet_id" {}
variable "azs" {}
variable "vpc_cidr" {}
variable "vpc_id" {}
variable "consul_cluster_size" {}
variable "bastion_connect" {}
variable "consul_version" {
    default = "1.9.1"
}