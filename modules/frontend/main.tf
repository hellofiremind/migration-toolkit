provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "north_virginia"
  region = "us-east-1"
}

locals {
  domains = [
    "${var.build_stage}.${var.service}.${var.frontend_name}.${var.domain_base}",
    "www.${var.build_stage}.${var.service}.${var.frontend_name}.${var.domain_base}"
  ]
  certificate_domains = concat(local.domains)
  cert_domains_zones = [for value in local.certificate_domains : {
    zone   = var.dns_zone
    domain = value
  }]
  domain_name = {
    zone   = var.dns_zone
    domain = var.domain_base
  }

  subject_alternative_names = []

  validated_domains = [
    for object in concat([local.domain_name], local.subject_alternative_names) : object.domain if can(object["zone"])
  ]

  validated_zones = [
    for object in concat([local.domain_name], local.subject_alternative_names) : object.zone if can(object["zone"])
  ]

  domain_zone_mapping = zipmap(local.validated_domains, local.validated_zones)

  cert_sans = sort([
    for v in local.subject_alternative_names : v.domain
  ])

  frontend_origin_id = "FrontendOrigin"
}
