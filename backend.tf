module "app1_service" {
  source             = "./modules/backend"
  ecs_service        = "app1"
  cpu                = 256
  memory             = 512
  container_port     = 80

  cluster_id         = aws_ecs_cluster.main.id
  ecs_security_group = aws_security_group.fargate.id
  task_role_arn      = aws_iam_role.containerised.arn

  lb_tg_port         = "80"
  lb_health_path     = "/"
  lb_listener_port   = 443
  lb_sg              = aws_security_group.load_balancer.id
  waf_arn            = module.waf_regional.web_acl_arn

  dns_zone           = var.DNS_ZONE
  domain_base        = var.DOMAIN_BASE

  vpc_id             = module.vpc.vpc_id
  public_subnets     = module.vpc.public_subnets
  private_subnets    = module.vpc.private_subnets

  account_id         = data.aws_caller_identity.current.account_id
  aws_region         = var.AWS_REGION
  service            = var.SERVICE
  build_stage        = var.BUILD_STAGE
  tags               = local.common_tags
}

module "app2_service" {
  source             = "./modules/backend"
  ecs_service        = "app2"
  cpu                = 256
  memory             = 512
  container_port     = 80

  cluster_id         = aws_ecs_cluster.main.id
  ecs_security_group = aws_security_group.fargate.id
  task_role_arn      = aws_iam_role.containerised.arn

  lb_tg_port         = "80"
  lb_health_path     = "/health"
  lb_listener_port   = 443
  lb_sg             = aws_security_group.load_balancer.id
  waf_arn            = module.waf_regional.web_acl_arn

  dns_zone           = var.DNS_ZONE
  domain_base        = var.DOMAIN_BASE

  vpc_id             = module.vpc.vpc_id
  public_subnets     = module.vpc.public_subnets
  private_subnets    = module.vpc.private_subnets

  account_id         = data.aws_caller_identity.current.account_id
  aws_region         = var.AWS_REGION
  service            = var.SERVICE
  build_stage        = var.BUILD_STAGE
  tags               = local.common_tags
}
