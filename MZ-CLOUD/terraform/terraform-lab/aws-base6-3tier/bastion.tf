# Key Pair
resource "aws_key_pair" "pista-key" {
  key_name   = "pista-key"
  public_key = file("~/.ssh/pista-key.pub")

  tags = { Name = "pista-key" }
}

# Bastion EC2 → 두 번째 퍼블릭 서브넷 (public-b, AZ-b)
resource "aws_instance" "pista-bastion" {
  ami                    = "ami-08d59269edddde222" # Ubuntu 24.04 LTS (x86, ap-southeast-1)
  instance_type          = "t3.nano"
  subnet_id              = aws_subnet.pista-public-b.id
  vpc_security_group_ids = [aws_security_group.pista-bastion-sg.id]
  key_name               = aws_key_pair.pista-key.key_name

  user_data = filebase64("${path.module}/bastion-init.sh")

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = { Name = "pista-bastion" }
}

output "bastion_public_ip" {
  description = "Bastion 퍼블릭 IP"
  value       = aws_instance.pista-bastion.public_ip
}
