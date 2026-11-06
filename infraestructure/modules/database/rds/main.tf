terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.environment}-db-sg-group"
  subnet_ids = [var.subnet_id]
}

resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Permite conexiones MySQL solo desde la capa Compute (EC2)"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL desde la capa Compute"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.compute_sg_id] # Mínimo privilegio
  }

  tags = { Name = "${var.environment}-rds-sg" }
}

resource "aws_db_instance" "this" {
  #checkov:skip=CKV_AWS_353: "Skip dev local"
  #checkov:skip=CKV_AWS_157: "Skip dev local"
  #checkov:skip=CKV_AWS_161: "Skip dev local"
  #checkov:skip=CKV_AWS_16: "Encryption at rest no soportado en Floci OSS - memory/MEMORY.md"
  #checkov:skip=CKV_AWS_293: "Deletion protection no requerido en dev local - memory/MEMORY.md"
  #checkov:skip=CKV2_AWS_60: "Copy tags to snapshots no disponible en emulacion - memory/MEMORY.md"
  #checkov:skip=CKV_AWS_118: "Enhanced monitoring no soportado en emulacion local - memory/MEMORY.md"
  #checkov:skip=CKV_AWS_129: "Storage encryption no soportado en Floci OSS - memory/MEMORY.md"
  #checkov:skip=CKV_AWS_226: "Auto minor version upgrade no requerido en dev local - memory/MEMORY.md"

  identifier             = "${var.environment}-inventariado-db"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "inventario_db" # 3NF esquema vivirá aquí
  username               = "admin"
  password               = "Inventario2026!"
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}
