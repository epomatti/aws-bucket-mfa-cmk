locals {
  data_classification = "restricted"
}

resource "aws_s3_bucket" "restricted" {
  bucket        = "bucket-${var.workload}-${local.data_classification}-789"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.restricted.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "main" {
  description             = "kms-${var.workload}-${local.data_classification}-key"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          "AWS" : "arn:aws:iam::${var.aws_account_id}:root"
        }
        Action   = "kms:*",
        Resource = "*"
      }
    ]
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "restricted" {
  bucket = aws_s3_bucket.restricted.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.main.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "mfa_delete" {
  count  = var.mfa_policy_enabled == true ? 1 : 0
  bucket = aws_s3_bucket.restricted.id
  policy = data.aws_iam_policy_document.mfa_delete.json
}

data "aws_iam_policy_document" "mfa_delete" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    effect = "Deny"
    actions = [
      "s3:DeleteObject*"
    ]
    resources = [
      "${aws_s3_bucket.restricted.arn}/mfa-objects/*",
    ]
  }
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.restricted.bucket
  key    = "mfa-objects/cant-delete-without-mfa.txt"
  source = "${path.module}/cant-delete-without-mfa.txt"
  etag   = filemd5("${path.module}/cant-delete-without-mfa.txt")
}
