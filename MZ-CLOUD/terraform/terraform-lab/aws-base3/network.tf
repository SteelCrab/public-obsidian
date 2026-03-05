resource "aws_vpc" "pista-vpc-asg" {
  cidr_block           = "10.30.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "pista-vpc-asg"
  }
}

resource "aws_subnet" "pista-public-a" {
  vpc_id                  = aws_vpc.pista-vpc-asg.id
  cidr_block              = "10.30.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "pista-public-a"
  }
}

resource "aws_subnet" "pista-public-b" {
  vpc_id                  = aws_vpc.pista-vpc-asg.id
  cidr_block              = "10.30.2.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "pista-public-b"
  }
}

resource "aws_subnet" "pista-private-a" {
  vpc_id            = aws_vpc.pista-vpc-asg.id
  cidr_block        = "10.30.11.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "pista-private-a"
  }
}

resource "aws_subnet" "pista-private-b" {
  vpc_id            = aws_vpc.pista-vpc-asg.id
  cidr_block        = "10.30.12.0/24"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name = "pista-private-b"
  }
}

resource "aws_internet_gateway" "pista-igw-asg" {
  vpc_id = aws_vpc.pista-vpc-asg.id

  tags = {
    Name = "pista-igw-asg"
  }
}

resource "aws_route_table" "pista-public-rt-asg" {
  vpc_id = aws_vpc.pista-vpc-asg.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pista-igw-asg.id
  }

  tags = {
    Name = "pista-public-rt-asg"
  }
}

resource "aws_route_table_association" "pista-public-a-rta" {
  subnet_id      = aws_subnet.pista-public-a.id
  route_table_id = aws_route_table.pista-public-rt-asg.id
}

resource "aws_route_table_association" "pista-public-b-rta" {
  subnet_id      = aws_subnet.pista-public-b.id
  route_table_id = aws_route_table.pista-public-rt-asg.id
}

resource "aws_eip" "pista-nat-eip-asg" {
  domain = "vpc"

  tags = {
    Name = "pista-nat-eip-asg"
  }
}

resource "aws_nat_gateway" "pista-nat-asg" {
  allocation_id = aws_eip.pista-nat-eip-asg.id
  subnet_id     = aws_subnet.pista-public-a.id

  tags = {
    Name = "pista-nat-asg"
  }

  depends_on = [aws_internet_gateway.pista-igw-asg]
}

resource "aws_route_table" "pista-private-rt-asg" {
  vpc_id = aws_vpc.pista-vpc-asg.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.pista-nat-asg.id
  }

  tags = {
    Name = "pista-private-rt-asg"
  }
}

resource "aws_route_table_association" "pista-private-a-rta" {
  subnet_id      = aws_subnet.pista-private-a.id
  route_table_id = aws_route_table.pista-private-rt-asg.id
}

resource "aws_route_table_association" "pista-private-b-rta" {
  subnet_id      = aws_subnet.pista-private-b.id
  route_table_id = aws_route_table.pista-private-rt-asg.id
}

resource "aws_security_group" "pista-alb-sg" {
  name   = "pista-alb-sg"
  vpc_id = aws_vpc.pista-vpc-asg.id

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
  vpc_id = aws_vpc.pista-vpc-asg.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.pista-vpc-asg.cidr_block]
  }

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.pista-alb-sg.id]
  }

  ingress {
    description = "ICMP from VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.pista-vpc-asg.cidr_block]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.pista-vpc-asg.cidr_block]
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
