output "alb_dns" { value = module.alb.alb_dns_name }
output "app_fqdn" { value = module.route53.fqdn }
output "rds_endpoint" { value = var.is_local ? var.db_endpoint : module.rds[0].db_endpoint }
output "ssm_profile" { value = module.ec2.ssm_instance_profile_name }
