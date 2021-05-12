variable "name" {}
variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "subnet_id" {}
# variable "azs" {}
variable "vpc_cidr" {}
variable "vpc_id" {}
variable "nomad_cluster_size" {
    default = 3
}