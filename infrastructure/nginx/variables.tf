variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "subnet_id" {}
variable "vpc_id" {}
variable "consul_version" {
    default = "1.9.1"
}
variable "consul_template_version" {
    default = "0.25.1"
}