resource "aws_route53_zone" "primary" {
  name = var.siteName
}

resource "aws_route53_zone" "www_primary" {
  name = "www.${var.siteName}"
}
resource "aws_route53_record" "records" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.primary.zone_id


}



resource "aws_route53_record" "A" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.siteName
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }

}

resource "aws_route53domains_registered_domain" "domainRegistered" {
  domain_name = var.siteName

  name_server {
    name = aws_route53_zone.primary.name_servers[0]
  }
  name_server {
    name = aws_route53_zone.primary.name_servers[1]
  }
  name_server {
    name = aws_route53_zone.primary.name_servers[2]
  }
  name_server {
    name = aws_route53_zone.primary.name_servers[3]
  }
}

/*
resource "aws_route53_record" "NS" {
  allow_overwrite = true
  name            = var.siteName
  type            = "NS"
  zone_id         = aws_route53_zone.primary.zone_id
  ttl             = 172800
  records         = var.nsRecords
}

resource "aws_route53_record" "SOA" {
  allow_overwrite = true
  name            = var.siteName
  type            = "SOA"
  ttl             = 900
  zone_id         = aws_route53_zone.primary.zone_id

  records = var.soaRecords
}
*/