variable "vpc_id" {
  type        = string
  description = "ID de la VPC"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Subnets públicas para el ALB"
}

variable "environment" {
  type        = string
  description = "Entorno"
}
