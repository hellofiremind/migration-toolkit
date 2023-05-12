resource "aws_ssm_parameter" "s3_site" {
  name  = "/${var.service}/${var.build_stage}/${var.frontend_name}/s3_site"
  type  = "String"
  value = aws_s3_bucket.site_bucket.id
}

resource "aws_ssm_parameter" "distribution_id" {
  name  = "/${var.service}/${var.build_stage}/${var.frontend_name}/distribution_id"
  type  = "String"
  value = aws_cloudfront_distribution.site.id
}