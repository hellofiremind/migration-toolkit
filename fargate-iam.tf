resource "aws_iam_role" "containerised" {
  name               = "${var.SERVICE}-${var.BUILD_STAGE}-containerised"
  assume_role_policy = data.aws_iam_policy_document.containerised_policy.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "containerised_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "containerised_policy" {
  name        = "${var.SERVICE}-${var.BUILD_STAGE}-containerised"
  description = "${var.SERVICE}-${var.BUILD_STAGE}-containerised"
  path        = "/"
  policy      = data.aws_iam_policy_document.containerised.json
}

resource "aws_iam_policy_attachment" "containerised" {
  name       = "${var.SERVICE}-${var.BUILD_STAGE}-containerised"
  roles      = [aws_iam_role.containerised.name]
  policy_arn = aws_iam_policy.containerised_policy.arn
}

resource "aws_secretsmanager_secret" "api_token" {
  name = "${var.SERVICE}-num-${var.BUILD_STAGE}-api-token"
  tags = local.common_tags
}

data "aws_iam_policy_document" "containerised" {
  statement {
    sid = "Secrets"

    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]

    resources = [aws_secretsmanager_secret.api_token.arn]
  }

  statement {
    sid = "AllowECR"

    actions = [
      "ecr:UntagResource",
      "ecr:TagResource",
      "ecr:StartImageScan",
      "ecr:ListTagsForResource",
      "ecr:ListImages",
      "ecr:InitiateLayerUpload",
      "ecr:GetRepositoryPolicy",
      "ecr:GetLifecyclePolicy",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:CompleteLayerUpload",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }

  statement {
    sid = "AllowECS"

    actions = [
      "ecs:CreateCluster",
      "ecs:DescribeClusters",
      "ecs:DescribeServices",
      "ecs:DescribeTasks",
      "ecs:DescribeContainerInstances",
      "ecs:ListServices",
      "ecs:ListContainerInstances",
      "ecs:ListClusters",
      "ecs:ListTaskDefinitions"
    ]

    resources = [
      aws_ecs_cluster.main.arn
    ]
  }

  statement {
    sid = "AllowKms"

    actions = [
      "kms:Decrypt",
      "kms:Describe*",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]

    resources = [
      aws_kms_key.aurora.arn,
      aws_kms_key.logging.arn
    ]
  }

  statement {
    sid = "AllowSsm"

    actions = [
      "ssm:Get*",
      "ssm:Describe*"
    ]

    resources = [
      "arn:aws:logs:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.SERVICE}-${var.BUILD_STAGE}*:*",
      "arn:aws:ssm:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:parameter/${var.SERVICE}/${var.BUILD_STAGE}/*"
    ]
  }
}
