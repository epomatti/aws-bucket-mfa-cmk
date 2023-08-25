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

resource "aws_s3_bucket" "sensitive" {
  bucket        = "bucket-${local.workload}-sensitive-789"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.sensitive.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sensitive" {
  bucket = aws_s3_bucket.sensitive.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.main.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "main" {
  description             = "kms-${local.workload}-key"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          "AWS" : "arn:aws:iam::${local.account_id}:root"
        }
        Action   = "kms:*",
        Resource = "*"
      }
    ]
  })
}

# resource "aws_s3_bucket" "confidential" {
#   bucket        = "bucket-${local.workload}-confidential-789"
#   force_destroy = true
# }

# resource "aws_s3_bucket" "restricted" {
#   bucket        = "bucket-${local.workload}-restricted-789"
#   force_destroy = true
# }
