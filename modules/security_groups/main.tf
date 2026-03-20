# ── EC2 Security Group ────────────────────────────────────
# Allows SSH (22), HTTP (80), HTTPS (443) from the internet.
# Port 3306 is intentionally NOT opened here — DB traffic stays
# within the VPC via the RDS SG below.

resource "aws_security_group" "ec2_sg" {
  vpc_id = var.vpc_id
  name   = "hospital-ec2-sg"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "hospital-ec2-sg"
  }
}

# ── RDS Security Group ────────────────────────────────────
# Only allows MySQL traffic originating from the EC2 SG.
# RDS is never reachable from the internet.

resource "aws_security_group" "rds_sg" {
  vpc_id = var.vpc_id
  name   = "hospital-rds-sg"

  ingress {
    description     = "MySQL from EC2 only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "hospital-rds-sg"
  }
}
