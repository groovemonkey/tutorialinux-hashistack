# This file uses the open-source vault module produced by Hashicorp.
# It does some ACM cert instantiation before provisioning a Vault cluster.

# 1. Create ACM certs and manage via AWS Secrets Manager
module "aws-secrets-manager-acm" {
  source  = "hashicorp/vault-ent-starter/aws//examples/aws-secrets-manager-acm"
  version = "0.1.2"

  # required variables
  aws_region           = "us-west-2"
  resource_name_prefix = var.resource_name_prefix

}
// OUTPUTS
//     lb_certificate_arn
//     leader_tls_servername
//     secrets_manager_arn

# 2. Instantiate the Vault Enterprise module!
module "vault-starter" {
  # # Vault Enterprise: uncomment this section
  # source  = "hashicorp/vault-ent-starter/aws"
  # version = "0.1.2"
  # vault_license_filepath = "./vault-ent.hclic"

  # Vault open-source: uncomment this section
  source  = "hashicorp/vault-starter/aws"
  version = "1.0.0"

  resource_name_prefix = var.resource_name_prefix
  private_subnet_tags  = { "Vault": "deploy" }

  # Required variables from VPC example module
  vpc_id = module.vpc.vpc_id

  # Required variables from ACM example module
  leader_tls_servername = module.aws-secrets-manager-acm.leader_tls_servername
  secrets_manager_arn   = module.aws-secrets-manager-acm.secrets_manager_arn
  lb_certificate_arn    = module.aws-secrets-manager-acm.lb_certificate_arn

  ## Really nice features
  # user_supplied_ami_id
  # user_supplied_iam_role_name
  # user_supplied_userdata_path
}
