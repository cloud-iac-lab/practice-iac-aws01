# Variables para QA local con MySQL real (Podman :3307)
# Usar este archivo para iteraciones rápidas sin RDS en Floci

aws_region     = "us-east-1"
environment    = "dev"
vpc_cidr       = "10.0.0.0/16"
domain_name    = "local.example.com"
is_local       = true
local_endpoint = "http://localhost:4566"

# Variables de base de datos reales (mysql-inventario Podman :3307)
db_endpoint = "localhost:3307"
db_user     = "admin"
db_password = "Inventario2026!"
db_name     = "inventario_db"

# AMI para EC2 local (ámbito de prueba)
ami_id = "ami-12345678" # Placeholder para pruebas Floci