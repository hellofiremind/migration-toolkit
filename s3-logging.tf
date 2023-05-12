data "aws_region" "current" {}

resource "aws_s3_bucket" "logging_bucket" {
  bucket        = "${var.SERVICE}-${var.BUILD_STAGE}-logging"
  force_destroy = true
  tags          = local.common_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging" {
  bucket = aws_s3_bucket.logging_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.logging.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logging_bucket" {
  bucket = aws_s3_bucket.logging_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "logging_bucket_ownership" {
  bucket = aws_s3_bucket.logging_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "logging_bucket_policy" {
  bucket = aws_s3_bucket.logging_bucket.id
  policy = data.aws_iam_policy_document.logging_bucket_policy_document.json
}

data "aws_iam_policy_document" "logging_bucket_policy_document" {

  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logging_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

  statement {
    sid    = "EnforceHttpsAlways"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "*"
    ]

    resources = [
      aws_s3_bucket.logging_bucket.arn,
      "${aws_s3_bucket.logging_bucket.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }
}

resource "aws_kms_key" "logging" {
  provider                = aws
  description             = "${var.SERVICE}-${var.BUILD_STAGE}-logging-key"
  deletion_window_in_days = 30

  key_usage  = "ENCRYPT_DECRYPT"
  is_enabled = true

  enable_key_rotation = true

  policy = data.aws_iam_policy_document.key_policy.json

  tags = local.common_tags
}

resource "aws_kms_alias" "logging" {
  provider      = aws
  name          = "alias/${var.SERVICE}-num-${var.BUILD_STAGE}-logging-key"
  target_key_id = aws_kms_key.logging.key_id
}
