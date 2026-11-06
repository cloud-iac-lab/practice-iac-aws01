# Override para entornos locales con Floci
# RDS en Floci OSS necesita más tiempo que el timeout por defecto (30m)
# Uso: terraform apply -timeout=90m
#
# Alternativa: timeout global para el módulo RDS:
# module "rds" {
#   source = "../modules/database/rds"
#   timeout = {
#     create = "90m"
#     delete = "30m"
#   }
# }