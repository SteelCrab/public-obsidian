# VPC
resource "aws_vpc" "pista-vpc" {
  cidr_block           = "10.50.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "pista-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "pista-igw" {
  vpc_id = aws_vpc.pista-vpc.id

  tags = {
    Name = "pista-igw"
  }
}

# EIP & NAT Gateway (public-a 배치)
resource "aws_eip" "pista-nat-eip" {
  domain = "vpc"

  tags = {
    Name = "pista-nat-eip"
  }
}

resource "aws_nat_gateway" "pista-nat" {
  allocation_id = aws_eip.pista-nat-eip.id
  subnet_id     = aws_subnet.pista-public-a.id

  tags = {
    Name = "pista-nat"
  }

  depends_on = [aws_internet_gateway.pista-igw]
}

# ─── Public 서브넷 (RTB → IGW) ───────────────────────────────────────────────

resource "aws_subnet" "pista-public-a" {
  vpc_id                  = aws_vpc.pista-vpc.id
  cidr_block              = "10.50.3.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "pista-public-a"
  }
}

resource "aws_route_table" "pista-public-rt" {
  vpc_id = aws_vpc.pista-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pista-igw.id
  }

  tags = {
    Name = "pista-public-rt"
  }
}

resource "aws_route_table_association" "pista-public-a-rta" {
  subnet_id      = aws_subnet.pista-public-a.id
  route_table_id = aws_route_table.pista-public-rt.id
}

# ─── Private 앱 서브넷 2개 (RTB → NAT 공유) ──────────────────────────────────

resource "aws_subnet" "pista-private-a" {
  vpc_id            = aws_vpc.pista-vpc.id
  cidr_block        = "10.50.13.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "pista-private-a"
  }
}

resource "aws_subnet" "pista-private-b" {
  vpc_id            = aws_vpc.pista-vpc.id
  cidr_block        = "10.50.14.0/24"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name = "pista-private-b"
  }
}

resource "aws_route_table" "pista-private-rt" {
  vpc_id = aws_vpc.pista-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.pista-nat.id
  }

  tags = {
    Name = "pista-private-rt"
  }
}

resource "aws_route_table_association" "pista-private-a-rta" {
  subnet_id      = aws_subnet.pista-private-a.id
  route_table_id = aws_route_table.pista-private-rt.id
}

resource "aws_route_table_association" "pista-private-b-rta" {
  subnet_id      = aws_subnet.pista-private-b.id
  route_table_id = aws_route_table.pista-private-rt.id
}

# ─── Private RDS 서브넷 2개 (RTB → local only, 인터넷 차단) ─────────────────
# DB Subnet Group은 2개 이상의 AZ 서브넷 필요

resource "aws_subnet" "pista-private-rds-a" {
  vpc_id            = aws_vpc.pista-vpc.id
  cidr_block        = "10.50.21.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "pista-private-rds-a"
  }
}

resource "aws_subnet" "pista-private-rds-b" {
  vpc_id            = aws_vpc.pista-vpc.id
  cidr_block        = "10.50.22.0/24"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name = "pista-private-rds-b"
  }
}

resource "aws_route_table" "pista-private-rds-rt" {
  vpc_id = aws_vpc.pista-vpc.id

  # default route 없음 → local only (인터넷 차단)

  tags = {
    Name = "pista-private-rds-rt"
  }
}

resource "aws_route_table_association" "pista-private-rds-a-rta" {
  subnet_id      = aws_subnet.pista-private-rds-a.id
  route_table_id = aws_route_table.pista-private-rds-rt.id
}

resource "aws_route_table_association" "pista-private-rds-b-rta" {
  subnet_id      = aws_subnet.pista-private-rds-b.id
  route_table_id = aws_route_table.pista-private-rds-rt.id
}

# ─── Security Group (RDS용) ───────────────────────────────────────────────────

resource "aws_security_group" "pista-rds-sg" {
  name   = "pista-rds-sg"
  vpc_id = aws_vpc.pista-vpc.id

  ingress {
    description = "MySQL from private-a"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.50.13.0/24"]
  }

  ingress {
    description = "MySQL from private-b"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.50.14.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pista-rds-sg"
  }
}
