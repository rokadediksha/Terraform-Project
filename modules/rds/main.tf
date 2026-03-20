resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "hospital-rds-subnet-group"
  subnet_ids = [var.private_subnet1_id, var.private_subnet2_id]

  tags = {
    Name = "hospital-rds-subnet-group"
  }
}

resource "aws_db_instance" "hospital_db" {
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [var.rds_sg_id]
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 0

  tags = {
    Name = "hospital-rds"
  }
}
