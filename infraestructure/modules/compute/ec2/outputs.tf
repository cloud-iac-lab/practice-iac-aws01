output "instance_id" { value = aws_instance.this.id }
output "ec2_security_group_id" { value = aws_security_group.ec2.id }
output "ssm_instance_profile_name" { value = aws_iam_instance_profile.ssm.name }
