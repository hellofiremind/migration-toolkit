locals {
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
}
