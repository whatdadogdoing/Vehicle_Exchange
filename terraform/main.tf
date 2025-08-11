terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "item-exchange"
}

# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "${var.app_name}-${var.environment}"
  cidr = "10.0.0.0/16"
  
  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  
  enable_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support = true
}

# Security Groups
resource "aws_security_group" "alb" {
  name_prefix = "${var.app_name}-${var.environment}-alb"
  vpc_id      = module.vpc.vpc_id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-${var.environment}"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# RDS Database
resource "aws_db_subnet_group" "main" {
  name       = "${var.app_name}-${var.environment}"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "main" {
  identifier = "${var.app_name}-${var.environment}"
  
  engine         = "postgres"
  engine_version = "13.13"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  storage_encrypted = true
  
  db_name  = "item_exchange"
  username = "postgres"
  password = "your-secure-password"
  
  db_subnet_group_name = aws_db_subnet_group.main.name
  
  skip_final_snapshot = true
}

# Load Balancer
resource "aws_lb" "main" {
  name               = "${var.app_name}-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets           = module.vpc.public_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "database_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "load_balancer_dns" {
  value = aws_lb.main.dns_name
}