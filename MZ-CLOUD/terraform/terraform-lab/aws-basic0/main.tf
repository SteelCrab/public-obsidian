# CSP, 라이브러리, 버전 선언
resource "aws_instance" "name" {
  ami = "ami-054240677cb44ffac"

  instance_type = "t3.micro"

  tags = {
    Name = "pista-test-ec2"
  }
}
