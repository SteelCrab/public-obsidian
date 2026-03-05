# ─── VPC ──────────────────────────────────────────────────────────────────────

resource "aws_vpc" "pista-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "pista-vpc" }
}

# ─── Internet Gateway ──────────────────────────────────────────────────────────

resource "aws_internet_gateway" "pista-igw" {
  vpc_id = aws_vpc.pista-vpc.id

  tags = { Name = "pista-igw" }
}

# ─── NAT Gateway (public-a에 단일 배치, 실습용) ───────────────────────────────

resource "aws_eip" "pista-nat-eip" {
  domain = "vpc"

  tags = { Name = "pista-nat-eip" }
}

resource "aws_nat_gateway" "pista-nat" {
  allocation_id = aws_eip.pista-nat-eip.id
  subnet_id     = aws_subnet.pista-public-a.id

  tags = { Name = "pista-nat" }

  depends_on = [aws_internet_gateway.pista-igw]
}

# ─── Public 서브넷 (3개 AZ) ───────────────────────────────────────────────────

resource "aws_subnet" "pista-public-a" {
  vpc_id                  = aws_vpc.pista-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = { Name = "pista-public-a" }
}

resource "aws_subnet" "pista-public-b" {
  vpc_id                  = aws_vpc.pista-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true

  tags = { Name = "pista-public-b" }
}

resource "aws_subnet" "pista-public-c" {
  vpc_id                  = aws_vpc.pista-vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-southeast-1c"
  map_public_ip_on_launch = true

  tags = { Name = "pista-public-c" }
}

# ─── Private 앱 서브넷 (3개 AZ, → NAT) ───────────────────────────────────────

resource "aws_subnet" "pista-private-a" {
  vpc_id            = aws_vpc.pista-vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-southeast-1a"

  tags = { Name = "pista-private-a" }
}

resource "aws_subnet" "pista-private-b" {
  vpc_id            = aws_vpc.pista-vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "ap-southeast-1b"

  tags = { Name = "pista-private-b" }
}

resource "aws_subnet" "pista-private-c" {
  vpc_id            = aws_vpc.pista-vpc.id
  cidr_block        = "10.0.13.0/24"
  availability_zone = "ap-southeast-1c"

  tags = { Name = "pista-private-c" }
}

# ─── Private DB 서브넷 (3개 AZ, local only) ───────────────────────────────────

resource "aws_subnet" "pista-private-db-a" {
  vpc_id            = aws_vpc.pista-vpc.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "ap-southeast-1a"

  tags = { Name = "pista-private-db-a" }
}

resource "aws_subnet" "pista-private-db-b" {
  vpc_id            = aws_vpc.pista-vpc.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = "ap-southeast-1b"

  tags = { Name = "pista-private-db-b" }
}

resource "aws_subnet" "pista-private-db-c" {
  vpc_id            = aws_vpc.pista-vpc.id
  cidr_block        = "10.0.23.0/24"
  availability_zone = "ap-southeast-1c"

  tags = { Name = "pista-private-db-c" }
}

# ─── Route Tables ─────────────────────────────────────────────────────────────

# Public RTB → IGW
resource "aws_route_table" "pista-public-rt" {
  vpc_id = aws_vpc.pista-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pista-igw.id
  }

  tags = { Name = "pista-public-rt" }
}

resource "aws_route_table_association" "pista-public-a-rta" {
  subnet_id      = aws_subnet.pista-public-a.id
  route_table_id = aws_route_table.pista-public-rt.id
}

resource "aws_route_table_association" "pista-public-b-rta" {
  subnet_id      = aws_subnet.pista-public-b.id
  route_table_id = aws_route_table.pista-public-rt.id
}

resource "aws_route_table_association" "pista-public-c-rta" {
  subnet_id      = aws_subnet.pista-public-c.id
  route_table_id = aws_route_table.pista-public-rt.id
}

# Private RTB → NAT (앱 서브넷 3개 공유)
resource "aws_route_table" "pista-private-rt" {
  vpc_id = aws_vpc.pista-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.pista-nat.id
  }

  tags = { Name = "pista-private-rt" }
}

resource "aws_route_table_association" "pista-private-a-rta" {
  subnet_id      = aws_subnet.pista-private-a.id
  route_table_id = aws_route_table.pista-private-rt.id
}

resource "aws_route_table_association" "pista-private-b-rta" {
  subnet_id      = aws_subnet.pista-private-b.id
  route_table_id = aws_route_table.pista-private-rt.id
}

resource "aws_route_table_association" "pista-private-c-rta" {
  subnet_id      = aws_subnet.pista-private-c.id
  route_table_id = aws_route_table.pista-private-rt.id
}

# Private DB RTB → local only (인터넷 차단)
resource "aws_route_table" "pista-private-db-rt" {
  vpc_id = aws_vpc.pista-vpc.id

  tags = { Name = "pista-private-db-rt" }
}

resource "aws_route_table_association" "pista-private-db-a-rta" {
  subnet_id      = aws_subnet.pista-private-db-a.id
  route_table_id = aws_route_table.pista-private-db-rt.id
}

resource "aws_route_table_association" "pista-private-db-b-rta" {
  subnet_id      = aws_subnet.pista-private-db-b.id
  route_table_id = aws_route_table.pista-private-db-rt.id
}

resource "aws_route_table_association" "pista-private-db-c-rta" {
  subnet_id      = aws_subnet.pista-private-db-c.id
  route_table_id = aws_route_table.pista-private-db-rt.id
}
