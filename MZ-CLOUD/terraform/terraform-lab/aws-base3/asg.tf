resource "aws_launch_template" "pista-web-lt" {
  name_prefix            = "pista-web-lt-"
  image_id               = "ami-054240677cb44ffac"
  instance_type          = "t4g.micro"
  update_default_version = true
  vpc_security_group_ids = [aws_security_group.pista-web-sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    cat > /var/www/html/index.html <<HTML
    <h1>pista-web-asg</h1>
    <p>Instance: $INSTANCE_ID</p>
    HTML
    systemctl enable nginx
    systemctl start nginx
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "pista-web-asg"
    }
  }
}

resource "aws_autoscaling_group" "pista-web-asg" {
  name                      = "pista-web-asg"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  vpc_zone_identifier       = [aws_subnet.pista-private-a.id, aws_subnet.pista-private-b.id]
  target_group_arns         = [aws_lb_target_group.pista-tg-asg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 180
  force_delete              = true

  launch_template {
    id      = aws_launch_template.pista-web-lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "pista-web-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "pista-web-cpu-tt" {
  name                   = "pista-web-cpu-tt"
  autoscaling_group_name = aws_autoscaling_group.pista-web-asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.pista-web-asg.name
}
