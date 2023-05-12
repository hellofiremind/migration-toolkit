locals {
  cidr            = "172.20.0.0/18"
  private_subnets = slice(local.subnets, 1, 4)
  public_subnets  = slice(local.subnets, 4, 7)
  subnets         = cidrsubnets(local.cidr, 6, 3, 3, 3, 3, 3, 3)
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.SERVICE}-${var.BUILD_STAGE}"
  cidr = local.cidr

  azs                                            = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets                                = local.private_subnets
  public_subnets                                 = local.public_subnets
  public_subnet_ipv6_prefixes                    = [1, 2, 3]
  private_subnet_ipv6_prefixes                   = [4, 5, 6]
  public_subnet_assign_ipv6_address_on_creation  = true
  private_subnet_assign_ipv6_address_on_creation = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_vpn_gateway = false
  enable_ipv6        = true

  tags = local.common_tags
}
