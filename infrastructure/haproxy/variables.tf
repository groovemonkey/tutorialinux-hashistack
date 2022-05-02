variable "ami" {}
variable "num_instances" {
  default = 1
}
variable "instance_type" {}
variable "key_name" {}
variable "name" {
  default = "haproxy"
}
variable "dataplaneAPIVersion" {
  default = "2.5.3"
}
# variable "haproxyVersion" {
#   default = "2.5.7"
# }
# this should match the haproxy version above
variable "haproxyPPAVersion" {
  default = "2.5"
}

variable "vpc_id" {}
variable "public_subnet" {}
variable "vpc_cidr" {}
variable "haproxy_dataplane_user" {
  description = "User used to auth to the haproxy dataplane API"
  default = "dataplaneapitl"
}
variable "haproxy_dataplane_password" {
  description = "Password used to auth to the haproxy dataplane API"
  default = "tlorganelementfeybruck"
}