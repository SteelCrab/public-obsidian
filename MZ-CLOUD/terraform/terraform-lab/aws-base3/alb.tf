resource "aws_lb" "pista-alb-asg" {
  name               = "pista-alb-asg"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.pista-alb-sg.id]
  subnets = [
    aws_subnet.pista-public-a.id,
    aws_subnet.pista-public-b.id,
  ]

  tags = {
    Name = "pista-alb-asg"
  }
}

resource "aws_lb_target_group" "pista-tg-asg" {
  name        = "pista-tg-asg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.pista-vpc-asg.id

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "pista-tg-asg"
  }
}

resource "aws_lb_listener" "pista-http" {
  load_balancer_arn = aws_lb.pista-alb-asg.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pista-tg-asg.arn
  }
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.pista-alb-asg.dns_name
}
