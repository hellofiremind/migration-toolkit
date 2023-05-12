variable "frontend_name" {
  description = "Name of the frontend deployment"
}

variable "dns_zone" {
  description = "DNS Zone value specified in main.tf"
}

variable "domain_base" {
  description = "Domain Base value specified in main.tf"
}

variable "logging_bucket" {
  description = "ARN for S3 logging bucket - defined externally (s3-logging.tf)"
}

variable "account_id" {
}

variable "aws_region" {
}

variable "service" {
}

variable "build_stage" {
}

variable "tags" {
}