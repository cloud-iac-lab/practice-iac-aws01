output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_id" { value = aws_subnet.public.id }
output "compute_subnet_id" { value = aws_subnet.compute.id }
output "data_subnet_id" { value = aws_subnet.data.id }
output "endpoints_subnet_id" { value = aws_subnet.endpoints.id }
