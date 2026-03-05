resource "aws_vpc" "pista-vpc-terraform" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Username = "pista"
  }
}

resource "aws_subnet" "pista-subnet" {
  vpc_id                  = aws_vpc.pista-vpc-terraform.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "pista-subnet"
  }
}

resource "aws_internet_gateway" "pista-igw" {
  vpc_id = aws_vpc.pista-vpc-terraform.id

  tags = {
    Name = "pista-igw"
  }
}

resource "aws_route_table" "pista-rt" {
  vpc_id = aws_vpc.pista-vpc-terraform.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pista-igw.id
  }

  tags = {
    Name = "pista-rt"
  }
}

resource "aws_route_table_association" "pista-rta" {
  subnet_id      = aws_subnet.pista-subnet.id
  route_table_id = aws_route_table.pista-rt.id
}

# Private Subnet
resource "aws_subnet" "pista-private-subnet" {
  vpc_id     = aws_vpc.pista-vpc-terraform.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "pista-private-subnet"
  }
}

# Elastic IP (NAT Gateway용)
resource "aws_eip" "pista-nat-eip" {
  domain = "vpc"

  tags = {
    Name = "pista-nat-eip"
  }
}

# NAT Gateway (Public Subnet에 배치)
resource "aws_nat_gateway" "pista-nat" {
  allocation_id = aws_eip.pista-nat-eip.id
  subnet_id     = aws_subnet.pista-subnet.id

  tags = {
    Name = "pista-nat"
  }

  depends_on = [aws_internet_gateway.pista-igw]
}

# Private Route Table
resource "aws_route_table" "pista-private-rt" {
  vpc_id = aws_vpc.pista-vpc-terraform.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.pista-nat.id
  }

  tags = {
    Name = "pista-private-rt"
  }
}

resource "aws_route_table_association" "pista-private-rta" {
  subnet_id      = aws_subnet.pista-private-subnet.id
  route_table_id = aws_route_table.pista-private-rt.id
}

# Security Group
resource "aws_security_group" "pista-sg" {
  name   = "pista-sg"
  vpc_id = aws_vpc.pista-vpc-terraform.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pista-sg"
  }
}
