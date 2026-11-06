module "vpc" {
  source      = "../../modules/networking/vpc"
  environment = var.environment
}

module "endpoints" {
  source      = "../../modules/networking/endpoints"
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = var.vpc_cidr
  subnet_id   = module.vpc.endpoints_subnet_id
  region      = var.aws_region
  environment = var.environment
}

module "alb" {
  source            = "../../modules/networking/alb"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = [module.vpc.public_subnet_id]
}

# Usar BD local (Podman :3307) cuando is_local=true
# RDS en Floci OSS causa timeout de 30+ minutos
locals {
  db_endpoint = var.is_local ? var.db_endpoint : (module.rds[0].db_endpoint)
}

module "ec2" {
  source           = "../../modules/compute/ec2"
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.compute_subnet_id
  alb_sg_id        = module.alb.alb_security_group_id
  target_group_arn = module.alb.target_group_arn
  db_endpoint      = local.db_endpoint
  ami_id           = "ami-0c55b159cbfafe1f0" # AMI placeholder Floci
}

# RDS solo se crea en AWS real (is_local=false)
# En Floci OSS, usar BD local en Podman :3307
# Nota: compute_sg_id es solo para referencia, no causa errores cuando count=0
module "rds" {
  source        = "../../modules/database/rds"
  count         = var.is_local ? 0 : 1
  environment   = var.environment
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.data_subnet_id
  compute_sg_id = module.ec2.ec2_security_group_id
}

module "route53" {
  source       = "../../modules/networking/route53"
  environment  = var.environment
  domain_name  = var.domain_name
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}

module "cloudwatch" {
  source      = "../../modules/monitoring/cloudwatch"
  environment = var.environment
  instance_id = module.ec2.instance_id
}
