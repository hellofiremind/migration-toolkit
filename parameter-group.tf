locals {
  parameters = [{
    "name"  = "pgaudit.log",
    "value" = "role,ddl,misc"
    }, {
    "name"  = "pgaudit.log_level",
    "value" = "info"
    }, {
    "name"  = "pgaudit.log_catalog",
    "value" = "0"
    }, {
    "name"  = "log_connections",
    "value" = "1"
    }, {
    "name"  = "log_disconnections",
    "value" = "1"
    }, {
    "name"  = "log_temp_files",
    "value" = "1"
    }, {
    "name"  = "log_statement",
    "value" = "none"
    }, {
    "name"  = "log_min_duration_statement",
    "value" = "500"
    }
  ]
}

resource "aws_rds_cluster_parameter_group" "main" {
  name        = local.name
  family      = "aurora-postgresql14"
  description = "${local.name} for aurora-postgresql14"

  dynamic "parameter" {
    for_each = local.parameters
    content {
      name         = parameter.value["name"]
      value        = parameter.value["value"]
      apply_method = "pending-reboot"
    }
  }
}

resource "aws_db_parameter_group" "main" {
  name        = local.name
  family      = "aurora-postgresql14"
  description = "${local.name} for aurora-postgresql14"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}"
    }
  )
}
