output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet1_id" {
  description = "ID of private subnet 1"
  value       = aws_subnet.private1.id
}

output "private_subnet2_id" {
  description = "ID of private subnet 2"
  value       = aws_subnet.private2.id
}
