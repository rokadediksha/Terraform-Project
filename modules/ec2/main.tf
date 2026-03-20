locals {
  # Strip the :3306 port suffix from the RDS endpoint to get just the hostname
  rds_host = split(":", var.rds_endpoint)[0]
}

resource "aws_instance" "hospital_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.ec2_sg_id]
  key_name               = var.key_name

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    rds_host   = local.rds_host
    db_user    = var.db_username
    db_pass    = var.db_password
    db_name    = var.db_name
  })

  tags = {
    Name = "hospital-web-server"
  }
}
