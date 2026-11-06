terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_security_group" "alb" {
  #checkov:skip=CKV_AWS_260: "ALB publico emulado localmente sin WAF - memory/MEMORY.md"
  #checkov:skip=CKV_AWS_382: "Egreso abierto para alcanzar objetivo EC2 emulado - memory/MEMORY.md"
  name        = "${var.environment}-alb-sg"
  description = "Security group para el ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP desde cualquier origen (ALB publico emulado localmente)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Salida a cualquier destino"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-alb-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_lb" "this" {
  #checkov:skip=CKV2_AWS_28: "No se requiere WAF en emulacion local con Floci"
  #checkov:skip=CKV_AWS_150: "No se requiere deletion protection en emulacion local"
  #checkov:skip=CKV_AWS_91: "No se requieren access logs en emulacion local"
  #checkov:skip=CKV_AWS_131: "Drop HTTP headers no requerido en ALB local sin TLS - memory/MEMORY.md"
  #checkov:skip=CKV2_AWS_20: "TLS en ALB no requerido en emulacion local con red interna - memory/MEMORY.md"

  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_lb_target_group" "this" {
  #checkov:skip=CKV_AWS_378: "Health check HTTP (no HTTPS) permitido en emulacion local - memory/MEMORY.md"
  name     = "${var.environment}-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/productos"
    port                = "3000"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 10
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_lb_listener" "http" {
  #checkov:skip=CKV_AWS_2: "HTTP permitido en emulacion local sin certificado TLS"
  #checkov:skip=CKV_AWS_103: "TLS en listener no requerido en dev local con red interna - memory/MEMORY.md"

  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
