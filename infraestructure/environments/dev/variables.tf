variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "domain_name" {
  type    = string
  default = "local.example.com"
}

variable "is_local" {
  type    = bool
  default = true
}

variable "local_endpoint" {
  type    = string
  default = "http://localhost:4566"
}

# Variables para base de datos local (mysql-inventario Podman :3307)
# Usadas cuando is_local=true y RDS no funciona en Floci OSS
variable "db_endpoint" {
  type        = string
  default     = "localhost:3307"
  description = "Endpoint de la BD local (mysql-inventario Podman :3307)"
}
