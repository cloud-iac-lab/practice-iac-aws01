terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_route53_zone" "this" {
  #checkov:skip=CKV2_AWS_38: "DNSSEC no disponible en zona emulada localmente con Floci - memory/MEMORY.md"
  #checkov:skip=CKV2_AWS_39: "Query logging no soportado en emulacion local - memory/MEMORY.md"
  name = var.domain_name

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_route53_record" "alb" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "app.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}
