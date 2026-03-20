output "website_url" {
  description = "Public URL of the hospital web server"
  value       = "http://${module.ec2.public_ip}"
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2.public_ip
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint (host:port)"
  value       = module.rds.rds_endpoint
  sensitive   = true
}
