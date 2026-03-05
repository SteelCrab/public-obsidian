variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

# DB Subnet Group (3개 AZ)
resource "aws_db_subnet_group" "pista-db-subnet-group" {
  name = "pista-db-subnet-group"
  subnet_ids = [
    aws_subnet.pista-private-db-a.id,
    aws_subnet.pista-private-db-b.id,
    aws_subnet.pista-private-db-c.id,
  ]

  tags = { Name = "pista-db-subnet-group" }
}

# RDS Primary (마스터)
resource "aws_db_instance" "pista-rds-primary" {
  identifier        = "pista-rds-primary"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "pistadb"
  username = "admin"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.pista-db-subnet-group.name
  vpc_security_group_ids = [aws_security_group.pista-db-sg.id]

  availability_zone       = "ap-southeast-1a"
  multi_az                = false
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 1 # Read Replica 생성에 필수

  tags = { Name = "pista-rds-primary" }
}

# RDS Replica (슬레이브)
resource "aws_db_instance" "pista-rds-replica" {
  identifier          = "pista-rds-replica"
  replicate_source_db = aws_db_instance.pista-rds-primary.identifier

  instance_class         = "db.t3.micro"
  storage_type           = "gp2"
  vpc_security_group_ids = [aws_security_group.pista-db-sg.id]

  availability_zone   = "ap-southeast-1b"
  publicly_accessible = false
  skip_final_snapshot = true

  tags = { Name = "pista-rds-replica" }
}

output "rds_primary_endpoint" {
  description = "RDS Primary 엔드포인트"
  value       = aws_db_instance.pista-rds-primary.endpoint
}

output "rds_replica_endpoint" {
  description = "RDS Replica 엔드포인트"
  value       = aws_db_instance.pista-rds-replica.endpoint
}
