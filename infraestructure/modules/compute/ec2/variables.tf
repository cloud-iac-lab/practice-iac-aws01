variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "alb_sg_id" { type = string }
variable "target_group_arn" { type = string }
variable "db_endpoint" { type = string }
variable "ami_id" {
  type    = string
  default = "ami-0c55b159cbfafe1f0"
}
variable "environment" { type = string }
