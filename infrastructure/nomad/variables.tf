variable "name" {}
variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "vpc_cidr" {}
variable "vpc_id" {}
variable "bastion_private_ip" {}
variable "cluster_size" {
    default = 3
}
variable "subnet_ids" {
    description = "A list of subnet IDs to distribute instances across. These should be private."
}
variable "resource_name_prefix" {
  type            = string
  description     = "A prefix for naming nomad resources this module creates."
  default         = "tutorialinux"
}
