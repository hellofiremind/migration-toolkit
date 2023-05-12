resource "aws_s3_bucket" "site_bucket" {
  bucket        = "${var.service}-${var.build_stage}-${var.frontend_name}-site"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "site_bucket" {
  bucket = aws_s3_bucket.site_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "site_bucket_policy" {
  bucket = aws_s3_bucket.site_bucket.id
  policy = data.aws_iam_policy_document.site_bucket_policy_document.json
}

data "aws_iam_policy_document" "site_bucket_policy_document" {

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = ["${aws_s3_bucket.site_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.site_origin_access_identity.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.site_bucket.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.site_origin_access_identity.iam_arn]
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
      aws_s3_bucket.site_bucket.arn,
      "${aws_s3_bucket.site_bucket.arn}/*"
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
