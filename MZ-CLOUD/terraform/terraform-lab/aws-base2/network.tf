resource "aws_vpc" "pista-vpc-alb" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "pista-vpc-alb"
  }
}

resource "aws_subnet" "pista-public-a" {
  vpc_id                  = aws_vpc.pista-vpc-alb.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "pista-public-a"
  }
}

resource "aws_subnet" "pista-public-b" {
  vpc_id                  = aws_vpc.pista-vpc-alb.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "pista-public-b"
  }
}

resource "aws_subnet" "pista-private-a" {
  vpc_id            = aws_vpc.pista-vpc-alb.id
  cidr_block        = "10.20.11.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "pista-private-a"
  }
}

resource "aws_subnet" "pista-private-b" {
  vpc_id            = aws_vpc.pista-vpc-alb.id
  cidr_block        = "10.20.12.0/24"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name = "pista-private-b"
  }
}

resource "aws_internet_gateway" "pista-igw-alb" {
  vpc_id = aws_vpc.pista-vpc-alb.id

  tags = {
    Name = "pista-igw-alb"
  }
}

resource "aws_route_table" "pista-public-rt-alb" {
  vpc_id = aws_vpc.pista-vpc-alb.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pista-igw-alb.id
  }

  tags = {
    Name = "pista-public-rt-alb"
  }
}

resource "aws_route_table_association" "pista-public-a-rta" {
  subnet_id      = aws_subnet.pista-public-a.id
  route_table_id = aws_route_table.pista-public-rt-alb.id
}

resource "aws_route_table_association" "pista-public-b-rta" {
  subnet_id      = aws_subnet.pista-public-b.id
  route_table_id = aws_route_table.pista-public-rt-alb.id
}

resource "aws_eip" "pista-nat-eip-alb" {
  domain = "vpc"

  tags = {
    Name = "pista-nat-eip-alb"
  }
}

resource "aws_nat_gateway" "pista-nat-alb" {
  allocation_id = aws_eip.pista-nat-eip-alb.id
  subnet_id     = aws_subnet.pista-public-a.id

  tags = {
    Name = "pista-nat-alb"
  }

  depends_on = [aws_internet_gateway.pista-igw-alb]
}

resource "aws_route_table" "pista-private-rt-alb" {
  vpc_id = aws_vpc.pista-vpc-alb.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.pista-nat-alb.id
  }

  tags = {
    Name = "pista-private-rt-alb"
  }
}

resource "aws_route_table_association" "pista-private-a-rta" {
  subnet_id      = aws_subnet.pista-private-a.id
  route_table_id = aws_route_table.pista-private-rt-alb.id
}

resource "aws_route_table_association" "pista-private-b-rta" {
  subnet_id      = aws_subnet.pista-private-b.id
  route_table_id = aws_route_table.pista-private-rt-alb.id
}

resource "aws_security_group" "pista-alb-sg" {
  name   = "pista-alb-sg"
  vpc_id = aws_vpc.pista-vpc-alb.id

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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pista-alb-sg"
  }
}

resource "aws_security_group" "pista-web-sg" {
  name   = "pista-web-sg"
  vpc_id = aws_vpc.pista-vpc-alb.id

  ingress {
    description = "HTTP from VPC (internal network)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.pista-vpc-alb.cidr_block]
  }

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.pista-alb-sg.id]
  }

  ingress {
    description = "ICMP from VPC for internal ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.pista-vpc-alb.cidr_block]
  }

  ingress {
    description = "SSH from VPC (internal network)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.pista-vpc-alb.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pista-web-sg"
  }
}
