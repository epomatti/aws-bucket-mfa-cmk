terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  workload   = "blup"
  account_id = data.aws_caller_identity.current.account_id
}

### Sensitive Bucket ###
module "sensitive" {
  source         = "./buckets/sensitive"
  workload       = local.workload
  aws_account_id = local.account_id
}

### Restricted Bucket ###
module "restricted" {
  source             = "./buckets/restricted"
  mfa_policy_enabled = var.mfa_policy_enabled
  workload           = local.workload
  aws_account_id     = local.account_id
}
