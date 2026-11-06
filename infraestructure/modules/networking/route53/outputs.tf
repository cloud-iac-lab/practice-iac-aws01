output "zone_id" {
  value = aws_route53_zone.this.zone_id
}

output "fqdn" {
  value = aws_route53_record.alb.fqdn
}
