# Key Pair
resource "aws_key_pair" "pista-key" {
  key_name   = "pista-key"
  public_key = file("~/.ssh/pista-key.pub")

  tags = {
    Name = "pista-key"
  }
}

# Security Group (Bastion용)
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

  tags = {
    Name = "pista-bastion-sg"
  }
}

# Bastion EC2 (Public 서브넷)
resource "aws_instance" "pista-bastion" {
  ami                    = "ami-054240677cb44ffac"
  instance_type          = "t4g.micro"
  subnet_id              = aws_subnet.pista-public-a.id
  vpc_security_group_ids = [aws_security_group.pista-bastion-sg.id]
  key_name               = aws_key_pair.pista-key.key_name

  user_data = filebase64("${path.module}/bastion-init.sh")

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "pista-bastion"
  }
}

output "bastion_public_ip" {
  description = "Bastion 퍼블릭 IP"
  value       = aws_instance.pista-bastion.public_ip
}
