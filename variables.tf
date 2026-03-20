variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# ── Networking ────────────────────────────────────────────
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet1_cidr" {
  description = "CIDR block for private subnet 1 (AZ-a)"
  type        = string
  default     = "10.0.4.0/24"
}

variable "private_subnet2_cidr" {
  description = "CIDR block for private subnet 2 (AZ-b)"
  type        = string
  default     = "10.0.5.0/24"
}

# ── EC2 ───────────────────────────────────────────────────
variable "ami_id" {
  description = "AMI ID for the EC2 instance (Amazon Linux 2)"
  type        = string
  default     = "ami-02dfbd4ff395f2a1b"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
  default     = "terraform"
}

# ── RDS ───────────────────────────────────────────────────
variable "db_name" {
  description = "Name of the MySQL database"
  type        = string
  default     = "hospitaldb"
}

variable "db_username" {
  description = "Master username for RDS"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password for RDS — override via terraform.tfvars or environment variable"
  type        = string
  sensitive   = true
}
