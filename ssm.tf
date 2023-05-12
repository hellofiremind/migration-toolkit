resource "aws_ssm_parameter" "state_bucket" {
  name  = "/${var.SERVICE}/${var.BUILD_STAGE}/state_bucket"
  type  = "String"
  value = var.STATE_BUCKET
}

resource "aws_ssm_parameter" "private_subnets" {
  name  = "/${var.SERVICE}/${var.BUILD_STAGE}/private_subnets"
  type  = "StringList"
  value = join(",", module.vpc.private_subnets)
}

resource "aws_ssm_parameter" "account_id" {
  name  = "/${var.SERVICE}/${var.BUILD_STAGE}/account_id"
  type  = "String"
  value = data.aws_caller_identity.current.account_id
}

resource "aws_ssm_parameter" "ecs_cluster" {
  name  = "/${var.SERVICE}/${var.BUILD_STAGE}/ecs_cluster"
  type  = "String"
  value = aws_ecs_cluster.main.arn
}
