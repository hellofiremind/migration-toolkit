terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.AWS_REGION
}

provider "aws" {
  alias  = "north_virginia"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
