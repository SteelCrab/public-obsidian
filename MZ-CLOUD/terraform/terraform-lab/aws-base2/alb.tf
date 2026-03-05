resource "aws_lb" "pista-alb" {
  name               = "pista-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.pista-alb-sg.id]
  subnets = [
    aws_subnet.pista-public-a.id,
    aws_subnet.pista-public-b.id,
  ]

  tags = {
    Name = "pista-alb"
  }
}

resource "aws_lb_target_group" "pista-tg" {
  name     = "pista-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.pista-vpc-alb.id

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "pista-tg"
  }
}

resource "aws_lb_target_group_attachment" "pista-web-a" {
  target_group_arn = aws_lb_target_group.pista-tg.arn
  target_id        = aws_instance.pista-web-a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "pista-web-b" {
  target_group_arn = aws_lb_target_group.pista-tg.arn
  target_id        = aws_instance.pista-web-b.id
  port             = 80
}

resource "aws_lb_listener" "pista-http" {
  load_balancer_arn = aws_lb.pista-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pista-tg.arn
  }
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.pista-alb.dns_name
}
