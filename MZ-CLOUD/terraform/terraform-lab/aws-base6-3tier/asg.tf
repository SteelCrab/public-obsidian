# ─── ALB ──────────────────────────────────────────────────────────────────────

resource "aws_lb" "pista-alb" {
  name               = "pista-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.pista-alb-sg.id]
  subnets = [
    aws_subnet.pista-public-a.id,
    aws_subnet.pista-public-b.id,
    aws_subnet.pista-public-c.id,
  ]

  tags = { Name = "pista-alb" }
}

resource "aws_lb_target_group" "pista-tg" {
  name     = "pista-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.pista-vpc.id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = { Name = "pista-tg" }
}

resource "aws_lb_listener" "pista-alb-listener" {
  load_balancer_arn = aws_lb.pista-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pista-tg.arn
  }
}

# ─── Launch Template (nginx + FastAPI) ───────────────────────────────────────

resource "aws_launch_template" "pista-app-lt" {
  name_prefix            = "pista-app-lt-"
  image_id               = "ami-08d59269edddde222" # Ubuntu 24.04 LTS (x86, ap-southeast-1)
  instance_type          = "t3.micro"
  update_default_version = true

  vpc_security_group_ids = [
    aws_security_group.pista-nginx-sg.id,
    aws_security_group.pista-fastapi-sg.id,
  ]

  key_name  = aws_key_pair.pista-key.key_name
  user_data = filebase64("${path.module}/app-init.sh")

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "pista-app" }
  }
}

# ─── Auto Scaling Group ───────────────────────────────────────────────────────

resource "aws_autoscaling_group" "pista-app-asg" {
  name                = "pista-app-asg"
  min_size            = 1
  desired_capacity    = 1
  max_size            = 2
  target_group_arns   = [aws_lb_target_group.pista-tg.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 120

  vpc_zone_identifier = [
    aws_subnet.pista-private-a.id,
    aws_subnet.pista-private-b.id,
    aws_subnet.pista-private-c.id,
  ]

  launch_template {
    id      = aws_launch_template.pista-app-lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "pista-app"
    propagate_at_launch = true
  }
}

# ─── ASG Scaling Policy (CPU 60% 기준) ────────────────────────────────────────

resource "aws_autoscaling_policy" "pista-app-cpu-tt" {
  name                   = "pista-app-cpu-tt"
  autoscaling_group_name = aws_autoscaling_group.pista-app-asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}

# ─── Outputs ──────────────────────────────────────────────────────────────────

output "alb_dns_name" {
  description = "ALB DNS 주소"
  value       = aws_lb.pista-alb.dns_name
}
