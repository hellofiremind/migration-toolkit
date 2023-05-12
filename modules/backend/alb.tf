resource "aws_lb" "load_balancer" {
  name               = "${var.service}-${var.build_stage}-${var.ecs_service}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_sg]
  subnets            = var.public_subnets

  enable_deletion_protection = false

  tags = var.tags

  depends_on = [
    var.public_subnets
  ]
}

resource "aws_lb_target_group" "containerised_fargate_targetgroup" {
  name        = "${var.service}-${var.build_stage}-${var.ecs_service}-tg"
  port        = var.lb_tg_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags        = var.tags

  health_check {
    enabled  = true
    interval = 30
    path     = var.lb_health_path
    port     = var.container_port
    protocol = "HTTP"
    matcher  = "200,302,301"
  }
}

resource "aws_wafv2_web_acl_association" "web_acl_association_my_lb" {
  resource_arn = aws_lb.load_balancer.arn
  web_acl_arn  = var.waf_arn
}

resource "aws_alb_listener" "load_balancer_http_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = var.lb_tg_port
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "load_balancer_https_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = var.lb_listener_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-2019-08"
  certificate_arn   = aws_acm_certificate.self_lb.arn

  default_action {
    target_group_arn = aws_lb_target_group.containerised_fargate_targetgroup.arn
    type             = "forward"
  }

  depends_on = [
    aws_acm_certificate.self_lb
  ]
}
