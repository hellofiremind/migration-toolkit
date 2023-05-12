module "frontend_1" {
  source         = "./modules/frontend"
  frontend_name  = "frontend1"

  dns_zone       = var.DNS_ZONE
  domain_base    = var.DOMAIN_BASE

  logging_bucket = aws_s3_bucket.logging_bucket.bucket_domain_name

  account_id     = data.aws_caller_identity.current.account_id
  aws_region     = var.AWS_REGION
  service        = var.SERVICE
  build_stage    = var.BUILD_STAGE
  tags           = local.common_tags
}

module "frontend_2" {
  source         = "./modules/frontend"
  frontend_name  = "frontend2"

  dns_zone       = var.DNS_ZONE
  domain_base    = var.DOMAIN_BASE

  logging_bucket = aws_s3_bucket.logging_bucket.bucket_domain_name

  account_id     = data.aws_caller_identity.current.account_id
  aws_region     = var.AWS_REGION
  service        = var.SERVICE
  build_stage    = var.BUILD_STAGE
  tags           = local.common_tags
}
