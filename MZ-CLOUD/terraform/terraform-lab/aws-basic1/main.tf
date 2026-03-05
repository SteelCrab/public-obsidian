resource "aws_instance" "name" {
  ami                    = "ami-054240677cb44ffac"
  instance_type          = "t4g.micro"
  subnet_id              = aws_subnet.pista-subnet.id
  vpc_security_group_ids = [aws_security_group.pista-sg.id]

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
    INSTANCE_NAME="pista-test-ec2"
    cat > /var/www/html/index.html <<HTML
    <h1>$INSTANCE_NAME</h1>
    <p>IP: $INSTANCE_IP</p>
    HTML
    systemctl enable nginx
    systemctl start nginx
  EOF

  tags = {
    Name = "pista-test-ec2"
  }
}
