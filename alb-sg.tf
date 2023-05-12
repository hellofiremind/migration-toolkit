resource "aws_security_group" "load_balancer" {
  name        = "${var.SERVICE}-${var.BUILD_STAGE}-lb"
  description = "To control access to the load balancer primarily from the public internet"
  vpc_id      = module.vpc.vpc_id
  tags        = local.common_tags
}

resource "aws_security_group_rule" "internet_ingress_lb_80" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.load_balancer.id
  description       = "(INGRESS) HTTP - Allow inbound from public internet to load balancer for internet traffic"
}

resource "aws_security_group_rule" "internet_ingress_lb_443" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.load_balancer.id
  description       = "(INGRESS) HTTPS - Allow inbound from public internet to load balancer for internet traffic"
}

resource "aws_security_group_rule" "lb_to_fargate_80" {
  type      = "egress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  security_group_id        = aws_security_group.load_balancer.id
  source_security_group_id = aws_security_group.fargate.id
  description              = "(EGRESS) HTTP - Allow outbound from load balancer to Fargate for internet traffic"
}