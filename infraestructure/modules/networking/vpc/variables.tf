variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "compute_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "data_cidr" {
  type    = string
  default = "10.0.3.0/24"
}

variable "endpoints_cidr" {
  type    = string
  default = "10.0.4.0/24"
}

variable "az" {
  type    = string
  default = "us-east-1a"
}

variable "environment" {
  type = string
}
