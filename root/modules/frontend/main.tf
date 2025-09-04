resource "aws_launch_template" "frontend-lt" {
  name          = var.launch_template_config.name
  image_id      = var.launch_template_config.ami
  instance_type = var.launch_template_config.instance_type
  vpc_security_group_ids = [
    coalesce(var.security_group_id_asg, aws_security_group.fasg_sg.id)
  ]
  key_name  = var.launch_template_config.key_name
  user_data = base64encode(templatefile("${path.module}/${var.launch_template_config.userdata_file}", { BACKEND_URL = var.balb_dns }))

  monitoring {
    enabled = var.launch_template_config.monitoring
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.tags["Name"]}-fec2"
      Engineer    = var.tags["Engineer"]
      ProjectCode = var.tags["ProjectCode"]
    }
  )
}

resource "aws_autoscaling_group" "fasg" {
  name                = var.asg_config.name
  min_size            = var.asg_config.min_size
  max_size            = var.asg_config.max_size
  desired_capacity    = var.asg_config.desired_capacity
  vpc_zone_identifier = var.subnet_id["asg"]
  target_group_arns   = [aws_lb_target_group.f_tg.arn]
  enabled_metrics     = var.asg_config.enabled_metrics

  launch_template {
    id = aws_launch_template.frontend-lt.id

  }

  health_check_type         = var.asg_config.health_check_type
  health_check_grace_period = var.asg_config.health_check_grace_period

  tag {
    key                 = "Name"
    value               = var.asg_config.name_tag
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "frontend_scale_out" {
  name                   = var.frontend_scaling_policies["scale_out"].name
  scaling_adjustment     = var.frontend_scaling_policies["scale_out"].adjustment
  adjustment_type        = var.frontend_scaling_policies["scale_out"].adjustment_type
  cooldown               = var.frontend_scaling_policies["scale_out"].cooldown
  autoscaling_group_name = aws_autoscaling_group.fasg.name
}

resource "aws_autoscaling_policy" "frontend_scale_in" {
  name                   = var.frontend_scaling_policies["scale_in"].name
  scaling_adjustment     = var.frontend_scaling_policies["scale_in"].adjustment
  adjustment_type        = var.frontend_scaling_policies["scale_in"].adjustment_type
  cooldown               = var.frontend_scaling_policies["scale_in"].cooldown
  autoscaling_group_name = aws_autoscaling_group.fasg.name
}

# Define CloudWatch Metric Alarms using for_each
resource "aws_cloudwatch_metric_alarm" "frontend_scale_out" {
  alarm_name          = var.frontend_cloudwatch_alarms["scale_out"].alarm_name
  comparison_operator = var.frontend_cloudwatch_alarms["scale_out"].comparison_operator
  evaluation_periods  = var.frontend_cloudwatch_alarms["scale_out"].evaluation_periods
  metric_name         = var.frontend_cloudwatch_alarms["scale_out"].metric_name
  namespace           = var.frontend_cloudwatch_alarms["scale_out"].namespace
  period              = var.frontend_cloudwatch_alarms["scale_out"].period
  statistic           = var.frontend_cloudwatch_alarms["scale_out"].statistic
  threshold           = var.frontend_cloudwatch_alarms["scale_out"].threshold
  alarm_description   = var.frontend_cloudwatch_alarms["scale_out"].description
  treat_missing_data  = var.frontend_cloudwatch_alarms["scale_out"].treat_missing_data
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.fasg.name
  }
  alarm_actions = [aws_autoscaling_policy.frontend_scale_out.arn]
}

resource "aws_cloudwatch_metric_alarm" "frontend_scale_in" {
  alarm_name          = var.frontend_cloudwatch_alarms["scale_in"].alarm_name
  comparison_operator = var.frontend_cloudwatch_alarms["scale_in"].comparison_operator
  evaluation_periods  = var.frontend_cloudwatch_alarms["scale_in"].evaluation_periods
  metric_name         = var.frontend_cloudwatch_alarms["scale_in"].metric_name
  namespace           = var.frontend_cloudwatch_alarms["scale_in"].namespace
  period              = var.frontend_cloudwatch_alarms["scale_in"].period
  statistic           = var.frontend_cloudwatch_alarms["scale_in"].statistic
  threshold           = var.frontend_cloudwatch_alarms["scale_in"].threshold
  alarm_description   = var.frontend_cloudwatch_alarms["scale_in"].description
  treat_missing_data  = var.frontend_cloudwatch_alarms["scale_in"].treat_missing_data
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.fasg.name
  }
  alarm_actions = [aws_autoscaling_policy.frontend_scale_in.arn]
}

resource "aws_security_group" "fasg_sg" {
  name   = var.frontend_asg_sg_name
  vpc_id = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_sg]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.falb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.tags["Name"]}-fasg_sg"
      Engineer    = var.tags["Engineer"]
      ProjectCode = var.tags["ProjectCode"]
    }
  )
}

resource "aws_lb" "falb" {
  name               = var.alb_name
  internal           = var.is_internal
  load_balancer_type = "application"
  security_groups = [
    coalesce(var.security_group_id_falb, aws_security_group.falb_sg.id)
  ]
  subnets = var.subnet_id["alb"]

  enable_deletion_protection = false
  idle_timeout               = var.alb_idle_timeout

  tags = merge(
    var.tags,
    {
      Name        = "${var.tags["Name"]}-falb"
      Engineer    = var.tags["Engineer"]
      ProjectCode = var.tags["ProjectCode"]
    }
  )
}

resource "aws_lb_listener" "f_listener" {
  load_balancer_arn = aws_lb.falb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.f_tg.arn
  }
}

resource "aws_lb_target_group" "f_tg" {
  name        = var.target_group_name
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    protocol            = var.health_check_config.protocol
    path                = var.health_check_config.path
    port                = var.health_check_config.port
    unhealthy_threshold = var.health_check_config.unhealthy_threshold
    healthy_threshold   = var.health_check_config.healthy_threshold
    timeout             = var.health_check_config.timeout
    interval            = var.health_check_config.interval
    matcher             = var.health_check_config.matcher
  }
}

resource "aws_security_group" "falb_sg" {
  name        = var.frontend_alb_sg_name
  description = "Allow HTTP from the internet to frontend ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.tags["Name"]}-falb_sg"
      Engineer    = var.tags["Engineer"]
      ProjectCode = var.tags["ProjectCode"]
    }
  )
}