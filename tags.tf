locals {
  common_tags = {
    Service = var.SERVICE
    Stage   = var.BUILD_STAGE
  }
}