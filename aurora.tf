locals {
  log_group_names = ["audit", "error", "general", "slowquery"]

  name = "${var.SERVICE}-${var.BUILD_STAGE}-aurora-db"
}

module "aurora" {
  source              = "terraform-aws-modules/rds-aurora/aws"
  master_username     = "master"
  name                = local.name
  engine              = "aurora-postgresql"
  engine_version      = "14.6"
  allow_major_version_upgrade = true
  port                = "5432"
  database_name       = "main"
  deletion_protection = false
  instance_class      = "db.t4g.medium"
  instances = {
    1 = {}
    2 = {
      instance_class = "db.t4g.medium"
    }
  }

  vpc_id                = module.vpc.vpc_id
  subnets               = module.vpc.private_subnets
  create_security_group = true

  vpc_security_group_ids = [aws_security_group.fargate.id, aws_security_group.load_balancer.id]
  create_db_subnet_group = true

  storage_encrypted                   = true
  apply_immediately                   = true
  monitoring_interval                 = 10
  skip_final_snapshot                 = true
  iam_database_authentication_enabled = "true"
  db_cluster_parameter_group_family   = "aurora-postgresql14"

  enabled_cloudwatch_logs_exports = ["postgresql"]

  master_password = random_password.password.result

  kms_key_id = aws_kms_key.aurora.arn

  tags = merge(
    {},
    local.common_tags
  )
}

resource "random_password" "password" {
  length  = 64
  special = false
}

resource "aws_security_group" "rds_DB" {
  name        = "${var.SERVICE}-${var.BUILD_STAGE}-RDS"
  description = "Security group for RDS"
  vpc_id      = module.vpc.vpc_id
  tags        = local.common_tags
}

resource "aws_cloudwatch_log_group" "rds_log" {
  count = length(local.log_group_names)
  name  = "/aws/rds/cluster/${local.name}/${local.log_group_names[count.index]}"

  kms_key_id = aws_kms_key.aurora.arn

  retention_in_days = 14
}

resource "aws_secretsmanager_secret" "db_master" {
  name        = "${local.name}-num-masteruser"
  description = "${local.name}-num-masteruser"

  recovery_window_in_days = 30

  kms_key_id = aws_kms_key.aurora.arn
}
