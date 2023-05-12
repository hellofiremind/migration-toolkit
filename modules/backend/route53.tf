data "aws_route53_zone" "primary" {
  name         = var.dns_zone
  private_zone = false
}

resource "aws_route53_record" "ecs_alias" {
  name    = "${var.build_stage}.${var.service}.${var.ecs_service}."
  zone_id = data.aws_route53_zone.primary.zone_id
  type    = "A"
  alias {
    name                   = aws_lb.load_balancer.dns_name
    zone_id                = aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
}
