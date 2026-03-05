# ─── ALB 보안그룹 ─────────────────────────────────────────────────────────────

resource "aws_security_group" "pista-alb-sg" {
  name   = "pista-alb-sg"
  vpc_id = aws_vpc.pista-vpc.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from Internet"
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

  tags = { Name = "pista-alb-sg" }
}

# ─── Bastion 보안그룹 ─────────────────────────────────────────────────────────

resource "aws_security_group" "pista-bastion-sg" {
  name   = "pista-bastion-sg"
  vpc_id = aws_vpc.pista-vpc.id

  ingress {
    description = "SSH from Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "pista-bastion-sg" }
}

# ─── Nginx 보안그룹 (ALB → Nginx) ─────────────────────────────────────────────

resource "aws_security_group" "pista-nginx-sg" {
  name   = "pista-nginx-sg"
  vpc_id = aws_vpc.pista-vpc.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.pista-alb-sg.id]
  }

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.pista-bastion-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "pista-nginx-sg" }
}

# ─── FastAPI 보안그룹 (Nginx → FastAPI, 동일 인스턴스 내부) ──────────────────

resource "aws_security_group" "pista-fastapi-sg" {
  name   = "pista-fastapi-sg"
  vpc_id = aws_vpc.pista-vpc.id

  ingress {
    description     = "FastAPI from Nginx (same instance)"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.pista-nginx-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "pista-fastapi-sg" }
}

# ─── DB 보안그룹 (Bastion + FastAPI → MySQL) ──────────────────────────────────

resource "aws_security_group" "pista-db-sg" {
  name   = "pista-db-sg"
  vpc_id = aws_vpc.pista-vpc.id

  ingress {
    description     = "MySQL from Bastion"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.pista-bastion-sg.id]
  }

  ingress {
    description     = "MySQL from FastAPI"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.pista-fastapi-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "pista-db-sg" }
}
