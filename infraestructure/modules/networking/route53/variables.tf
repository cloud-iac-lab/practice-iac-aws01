variable "domain_name" {
  type        = string
  description = "Nombre de dominio para la zona"
  default     = "local.example.com"
}

variable "alb_dns_name" {
  type        = string
  description = "DNS name del ALB"
}

variable "alb_zone_id" {
  type        = string
  description = "Zone ID del ALB"
}

variable "environment" {
  type        = string
  description = "Entorno"
}
