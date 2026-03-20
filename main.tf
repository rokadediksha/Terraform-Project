terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet1_cidr = var.private_subnet1_cidr
  private_subnet2_cidr = var.private_subnet2_cidr
}

module "security_groups" {
  source = "./modules/security_groups"

  vpc_id = module.vpc.vpc_id
}

module "rds" {
  source = "./modules/rds"

  private_subnet1_id = module.vpc.private_subnet1_id
  private_subnet2_id = module.vpc.private_subnet2_id
  rds_sg_id          = module.security_groups.rds_sg_id
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
}

module "ec2" {
  source = "./modules/ec2"

  public_subnet_id = module.vpc.public_subnet_id
  ec2_sg_id        = module.security_groups.ec2_sg_id
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  key_name         = var.key_name
  rds_endpoint     = module.rds.rds_endpoint
  db_username      = var.db_username
  db_password      = var.db_password
  db_name          = var.db_name
}
