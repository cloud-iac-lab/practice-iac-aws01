terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  #checkov:skip=CKV_AWS_158: "KMS encryption no requerida para log groups en dev local"
  #checkov:skip=CKV_AWS_338: "Retencion de 7 dias suficiente para logs de emulacion local - memory/MEMORY.md"

  name              = "/aws/ec2/${var.environment}-app"
  retention_in_days = 7

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.environment}-ec2-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarma cuando el uso de CPU supera el 80%"

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
