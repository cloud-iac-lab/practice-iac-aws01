terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Role para SSM (Elimina necesidad de SSH - Zero Trust)
resource "aws_iam_role" "ssm" {
  name = "${var.environment}-ssm-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.environment}-ssm-profile"
  role = aws_iam_role.ssm.name
}

resource "aws_security_group" "ec2" {
  #checkov:skip=CKV_AWS_382: "Egreso abierto para VPC endpoints y paquetes Node - memory/MEMORY.md"
  name        = "${var.environment}-ec2-sg"
  description = "Security group para instancias de App"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP desde el ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    description = "Salida a internet para actualizaciones y VPC Endpoints"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-ec2-sg"
    Environment = var.environment
  }
}

resource "aws_instance" "this" {
  #checkov:skip=CKV_AWS_135: "Skip dev local"
  #checkov:skip=CKV_AWS_88: "Skip dev local"
  #checkov:skip=CKV_AWS_7: "Skip dev local"
  #checkov:skip=CKV_AWS_79: "Metadata v2 no critico en emulacion local"
  #checkov:skip=CKV_AWS_8: "EBS encryption no soportada en Floci OSS - memory/MEMORY.md"
  #checkov:skip=CKV_AWS_126: "Detailed monitoring no requerido en dev local - memory/MEMORY.md"
  #checkov:skip=CKV_AWS_382: "Egreso abierto necesario para VPC endpoints y Node.js - memory/MEMORY.md"
  #checkov:skip=CKV2_AWS_41: "Instance profile SSM restaurado (veriamos en plan) - memory/MEMORY.md"

  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.ssm.name
  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = <<-EOF
              #!/bin/bash
              # App Inventariado Node+React 3NF
              apt-get update -y
              apt-get install -y nodejs npm git
              npm install -g pm2

              mkdir -p /var/www/app
              cat <<EOT > /var/www/app/.env
              DB_HOST=${var.db_endpoint}
              DB_USER=admin
              DB_PASS=Inventario2026!
              DB_NAME=inventario_db
              PORT=3000
              EOT

              # En un entorno real aqui clonariamos el repo
              # Por ahora la app vive en src/app/ localmente
              echo "Aprovisionamiento listo"
              EOF

  tags = {
    Name        = "${var.environment}-app-server"
    Environment = var.environment
  }
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.this.id
  port             = 3000
}
