variable "aws_acm_arn" { }

resource "aws_cloudfront_distribution" "website" {
  origin {
    domain_name = data.aws_s3_bucket.website_complete.bucket_regional_domain_name
    origin_id   = data.aws_s3_bucket.website_complete.bucket
  }

  enabled             = true
  is_ipv6_enabled     = true

  logging_config {
    include_cookies = false
    bucket          = "${var.global_log_bucket}.s3.amazonaws.com"
    prefix          = "CloudFront/"
  }

  aliases = ["www.${local.global_website_domain}", local.global_website_domain]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = data.aws_s3_bucket.website_complete.bucket

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 1
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = local.global_tag_environment
    Service     = local.global_tag_service
  }

  viewer_certificate {
    acm_certificate_arn       = var.aws_acm_arn
    minimum_protocol_version  = "TLSv1.2_2019"
    ssl_support_method        = "sni-only"
  }

  wait_for_deployment = false
}
