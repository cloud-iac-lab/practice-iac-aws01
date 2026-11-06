terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_vpc" "this" {
  #checkov:skip=CKV2_AWS_11: "Flow logs no materializados en emulacion local con Floci - memory/MEMORY.md"
  #checkov:skip=CKV2_AWS_12: "Default SG abierto aceptado solo en VPC dev simulada - memory/MEMORY.md"
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.environment}-igw" }
}

# 4 CAPAS DE SUBNETS
resource "aws_subnet" "public" {
  #checkov:skip=CKV_AWS_130: "Map public IP solo en subnet de ALB publico emulado - memory/MEMORY.md"
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.environment}-public-alb" }
}

resource "aws_subnet" "compute" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.compute_cidr
  availability_zone = var.az
  tags              = { Name = "${var.environment}-compute-app" }
}

resource "aws_subnet" "data" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.data_cidr
  availability_zone = var.az
  tags              = { Name = "${var.environment}-data-db" }
}

resource "aws_subnet" "endpoints" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.endpoints_cidr
  availability_zone = var.az
  tags              = { Name = "${var.environment}-endpoints" }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = { Name = "${var.environment}-public-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
