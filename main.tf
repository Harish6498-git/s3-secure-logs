terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

locals {
  use_custom_kms = length(trim(var.kms_key_id)) > 0
}

resource "aws_kms_key" "this" {
  count       = local.use_custom_kms ? 0 : (var.create_kms ? 1 : 0)
  description = "KMS key for S3 bucket encryption (created by s3-secure-logs module)"
  policy      = data.aws_iam_policy_document.kms_policy.json
  tags        = var.tags
}

data "aws_iam_policy_document" "kms_policy" {
  statement {
    sid = "Allow principals in account to use key"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name != "" ? var.bucket_name : null
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = local.kms_key_id_final
        sse_algorithm     = "aws:kms"
      }
    }
  }

  force_destroy = var.force_destroy

  tags = merge({
    "managed-by" = "s3-secure-logs"
  }, var.tags)
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "logs-lifecycle"
    status = "Enabled"

    transition {
      days          = var.transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.expiration_days
    }

    noncurrent_version_expiration {
      days = var.expiration_days
    }
  }
}

resource "aws_s3_bucket_policy" "deny_insecure" {
  bucket = aws_s3_bucket.this.id
  policy = local.deny_insecure_policy
}

locals {
  kms_key_id_final = local.use_custom_kms ? var.kms_key_id : (length(aws_kms_key.this) > 0 ? aws_kms_key.this[0].arn : null)

  deny_insecure_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyUnEncryptedRequests"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.this.arn,
          "${aws_s3_bucket.this.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
