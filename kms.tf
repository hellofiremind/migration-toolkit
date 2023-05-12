resource "aws_kms_key" "aurora" {
  provider                = aws
  description             = "${var.SERVICE}-${var.BUILD_STAGE}-db-aurora-key"
  deletion_window_in_days = 30

  key_usage  = "ENCRYPT_DECRYPT"
  is_enabled = true

  enable_key_rotation = true

  policy = data.aws_iam_policy_document.key_policy.json

  tags = local.common_tags
}

resource "aws_kms_alias" "aurora" {
  provider      = aws
  name          = "alias/${var.SERVICE}-num-${var.BUILD_STAGE}-aurora-key"
  target_key_id = aws_kms_key.aurora.key_id
}

data "aws_iam_policy_document" "key_policy" {
  statement {
    sid = "Enable Key Management"

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]

    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    resources = ["*"]
  }

  statement {
    sid = "Enable Key Usage for Encryption Operatons"

    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]

    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com", "rds.amazonaws.com", "secretsmanager.amazonaws.com"]
    }

    resources = ["*"]
  }

  statement {
    sid = "Enable Key Usage for Decryption Operations"

    actions = [
      "kms:Decrypt"
    ]

    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com", "rds.amazonaws.com", "secretsmanager.amazonaws.com"]
    }

    resources = ["*"]
  }

  statement {
    sid = "Delegate permissions to CloudWatch Logs"

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"

      values = [
        "*"
      ]
    }

    resources = ["*"]
  }
}
