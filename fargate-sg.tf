resource "aws_security_group" "fargate" {
  name        = "${var.SERVICE}-${var.BUILD_STAGE}-fargate"
  description = "Central Security Group controlling Fargate inbound and outbound access, primarly from the load balancer and databases."
  vpc_id      = module.vpc.vpc_id
  tags        = local.common_tags
}

resource "aws_security_group_rule" "ingress_fargate_from_lb" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  description              = "(INGRESS) HTTP - Allow inbound connection from load balancer to Fargate"
  security_group_id        = aws_security_group.fargate.id
  source_security_group_id = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "allow_internet_access_fargate" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  description       = "(EGRESS) Allow Fargate to communicate with the public internet"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.fargate.id
}

resource "aws_security_group_rule" "allow_dns_access_fargate" {
  type      = "egress"
  from_port = 53
  to_port   = 53
  protocol  = "tcp"

  description       = "(EGRESS) Allow Fargate to communicate with DNS"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.fargate.id
}