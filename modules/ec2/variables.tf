variable "public_subnet_id" {
  description = "ID of the public subnet for the EC2 instance"
  type        = string
}

variable "ec2_sg_id" {
  description = "ID of the EC2 security group"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

variable "rds_endpoint" {
  description = "RDS endpoint (host:port)"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "RDS master username"
  type        = string
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}
