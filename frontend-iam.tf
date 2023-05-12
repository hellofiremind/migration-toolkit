locals {
  account_id = data.aws_caller_identity.current.account_id
}

module "frontend_iam" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "${var.SERVICE}-${var.BUILD_STAGE}-frontend"
  description = "${var.SERVICE}-${var.BUILD_STAGE}-frontend"

  policy = data.aws_iam_policy_document.frontend_role_policy.json
}

data "aws_iam_policy_document" "frontend_role_policy" {

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "*"
    ]

  }

  statement {
    sid = "SSM"

    actions = [
      "ssm:Get*",
      "ssm:Describe*"
    ]

    resources = [
      "arn:aws:ssm:${var.AWS_REGION}:${local.account_id}:parameter/${var.SERVICE}/${var.BUILD_STAGE}/*"
    ]
  }
}

