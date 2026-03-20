output "rds_endpoint" {
  description = "RDS instance endpoint (host:port)"
  value       = aws_db_instance.hospital_db.endpoint
  sensitive   = true
}

output "rds_host" {
  description = "RDS hostname only (without port)"
  value       = aws_db_instance.hospital_db.address
  sensitive   = true
}
