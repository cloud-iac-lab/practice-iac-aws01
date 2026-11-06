# Variables para validar SOLO VPC y Networking en Floci OSS
# Este archivo se usa para validar la red sin crear recursos que Floci no soporta

aws_region    = "us-east-1"
environment   = "dev"
vpc_cidr      = "10.0.0.0/16"
domain_name   = "local.example.com"
is_local      = true
local_endpoint = "http://localhost:4566"

# BD local para fallback (aunque no se usará en este plan)
db_endpoint   = "localhost:3307"