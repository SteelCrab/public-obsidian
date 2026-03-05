resource "aws_instance" "pista-web-a" {
  ami                    = "ami-054240677cb44ffac"
  instance_type          = "t4g.micro"
  subnet_id              = aws_subnet.pista-private-a.id
  vpc_security_group_ids = [aws_security_group.pista-web-sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    cat > /var/www/html/index.html <<HTML
    <h1>pista-web-a</h1>
    <p>ALB Target A</p>
    HTML
    systemctl enable nginx
    systemctl start nginx
  EOF

  tags = {
    Name = "pista-web-a"
  }
}

resource "aws_instance" "pista-web-b" {
  ami                    = "ami-054240677cb44ffac"
  instance_type          = "t4g.micro"
  subnet_id              = aws_subnet.pista-private-b.id
  vpc_security_group_ids = [aws_security_group.pista-web-sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    cat > /var/www/html/index.html <<HTML
    <h1>pista-web-b</h1>
    <p>ALB Target B</p>
    HTML
    systemctl enable nginx
    systemctl start nginx
  EOF

  tags = {
    Name = "pista-web-b"
  }
}
