data "aws_route53_zone" "self_lb" {
  for_each = toset(local.validated_zones)

  name         = each.value
  private_zone = false
}

resource "aws_acm_certificate" "self_lb" {
  domain_name               = local.domain_name.domain
  subject_alternative_names = local.cert_sans
  validation_method         = "DNS"

  tags = var.tags
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.self_lb.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    } if contains(local.validated_domains, dvo.domain_name)
  }

  zone_id         = data.aws_route53_zone.self_lb[local.domain_zone_mapping[each.key]].zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "self_lb" {
  count = 1

  certificate_arn         = aws_acm_certificate.self_lb.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
