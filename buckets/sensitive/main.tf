locals {
  data_classification = "sensitive"
}

resource "aws_s3_bucket" "sensitive" {
  bucket        = "bucket-${var.workload}-${local.data_classification}-789"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.sensitive.id
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

resource "aws_s3_bucket_server_side_encryption_configuration" "sensitive" {
  bucket = aws_s3_bucket.sensitive.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.main.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "put_object_kms" {
  count  = var.enforce_kms_policy == true ? 1 : 0
  bucket = aws_s3_bucket.sensitive.id
  policy = data.aws_iam_policy_document.put_object_kms.json
}

data "aws_iam_policy_document" "put_object_kms" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    effect = "Deny"
    actions = [
      "s3:PutObject*"
    ]
    resources = [
      "${aws_s3_bucket.restricted.arn}/enforced-kms/*"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }
}
