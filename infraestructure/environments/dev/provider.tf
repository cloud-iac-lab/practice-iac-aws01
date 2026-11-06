terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.is_local ? "test" : null
  secret_key = var.is_local ? "test" : null

  skip_credentials_validation = var.is_local
  skip_metadata_api_check     = var.is_local
  skip_requesting_account_id  = var.is_local

  dynamic "endpoints" {
    for_each = var.is_local ? [1] : []
    content {
      s3         = var.local_endpoint
      ec2        = var.local_endpoint
      rds        = var.local_endpoint
      elbv2      = var.local_endpoint
      route53    = var.local_endpoint
      cloudwatch = var.local_endpoint
      sts        = var.local_endpoint
      iam        = var.local_endpoint
      ssm        = var.local_endpoint
    }
  }
}
