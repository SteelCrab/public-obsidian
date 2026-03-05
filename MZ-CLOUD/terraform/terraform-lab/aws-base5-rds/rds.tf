variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

# DB Subnet Group (2개 AZ 필요)
resource "aws_db_subnet_group" "pista-rds-subnet-group" {
  name = "pista-rds-subnet-group"
  subnet_ids = [
    aws_subnet.pista-private-rds-a.id,
    aws_subnet.pista-private-rds-b.id,
  ]

  tags = {
    Name = "pista-rds-subnet-group"
  }
}

# RDS Instance (MySQL 최소 구성)
resource "aws_db_instance" "pista-rds" {
  identifier        = "pista-rds"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "pistadb"
  username = "admin"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.pista-rds-subnet-group.name
  vpc_security_group_ids = [aws_security_group.pista-rds-sg.id]

  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  backup_retention_period = 0

  tags = {
    Name = "pista-rds"
  }
}

output "rds_endpoint" {
  description = "RDS 엔드포인트"
  value       = aws_db_instance.pista-rds.endpoint
}
