module "cloudfront_certificate" {
  source = "terraform-aws-modules/acm/aws"

  providers = {
    aws = aws.north_virginia
  }

  domain_name = local.cert_domains_zones[0].domain
  zone_id     = data.aws_route53_zone.self.zone_id

  wait_for_validation = true

  subject_alternative_names = local.domains

  tags = var.tags
}

data "aws_route53_zone" "self" {
  name         = var.domain_base
  private_zone = false
}

resource "aws_acm_certificate" "self" {
  domain_name               = local.domain_name.domain
  subject_alternative_names = local.cert_sans
  validation_method         = "DNS"
}
