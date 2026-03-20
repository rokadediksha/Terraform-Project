variable "private_subnet1_id" {
  description = "ID of private subnet 1"
  type        = string
}

variable "private_subnet2_id" {
  description = "ID of private subnet 2"
  type        = string
}

variable "rds_sg_id" {
  description = "ID of the RDS security group"
  type        = string
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
}

variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
}

variable "db_password" {
  description = "Master password for the RDS instance"
  type        = string
  sensitive   = true
}
