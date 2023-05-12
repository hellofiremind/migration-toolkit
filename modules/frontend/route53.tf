data "aws_route53_zone" "primary" {
  name         = var.dns_zone
  private_zone = false
}

resource "aws_route53_record" "www_a" {
  count   = length(local.domains)
  name    = local.domains[count.index]
  type    = "A"
  zone_id = data.aws_route53_zone.primary.zone_id

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_aaaa" {
  count   = length(local.domains)
  name    = local.domains[count.index]
  type    = "AAAA"
  zone_id = data.aws_route53_zone.primary.zone_id

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}
