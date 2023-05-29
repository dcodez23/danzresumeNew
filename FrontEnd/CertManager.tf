resource "aws_acm_certificate" "cert" {
  domain_name               = var.siteName
  subject_alternative_names = ["www.${var.siteName}"]
  validation_method         = "DNS"

  tags = {
    name = "Certificate for website"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_acm_certificate_validation" "example" {
  timeouts {
    create = "5m"
  }
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.records : record.fqdn]
}


# Validation process for certificate manager
/*resource "aws_route53_record" "example" {
  for_each = {
    for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.example.zone_id
}
*/