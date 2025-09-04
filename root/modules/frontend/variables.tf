variable "launch_template_config" {
  type = object({
    name          = string
    ami           = string
    instance_type = string
    key_name      = string
    monitoring    = bool
    userdata_file = string
  })
  default = {
    name          = "FrontEndLaunchTemplate"
    ami           = "ami-00ca32bbc84273381"
    instance_type = "t3.micro"
    key_name      = "Soki-TFFinalAct"
    monitoring    = true
    userdata_file = "frontend_userdata.sh"
  }
}

variable "asg_config" {
  type = object({
    name                      = string
    name_tag                  = string
    min_size                  = number
    max_size                  = number
    desired_capacity          = number
    health_check_type         = string
    health_check_grace_period = number
    enabled_metrics           = list(string)
  })
  default = {
    name                      = "Soquiat-FrontendASG"
    name_tag                  = "Soquiat-FrontEndEc2"
    min_size                  = 2
    max_size                  = 4
    desired_capacity          = 2
    health_check_type         = "ELB"
    health_check_grace_period = 60
    enabled_metrics = [
      "GroupMinSize",
      "GroupMaxSize",
      "GroupDesiredCapacity",
      "GroupInServiceInstances",
      "GroupPendingInstances",
      "GroupStandbyInstances",
      "GroupTerminatingInstances",
      "GroupTotalInstances"
    ]
  }
}

variable "security_group_id_asg" {
  description = "Security Group ID for AutoScalingGroup Launch Template"
  type        = string
  default     = null
}

variable "frontend_asg_sg_name" {
  description = "value"
  type        = string
  default     = "Soquiat-FrontEndSG"
}

variable "subnet_id" {
  description = "List of Subnets where the ASG and ALB are Deployed. For ALB, must be public as the Load Balancer is an Internet Facing Load Balancer, and private for ASG since it can only be accessed through Bastion Host"
  type = map(list(string))
}

variable "vpc_id" {
  description = "The ID of the VPC in which the frontend resources will be deployed"
  type = string
}

variable "bastion_sg" {
  description = "The ID of the Security group of the Bastion Host"
  type = string
}

variable "balb_dns" {
  description = "The DNS name of the Backend ALB used for the userdata of the Launch Template"
  type = string
}

variable "frontend_scaling_policies" {
  description = "Frontend scaling policy configuration for Auto Scaling Group"
  type = map(object({
    name            = string
    adjustment      = number
    adjustment_type = string
    cooldown        = number
  }))
  default = {
    scale_out = {
      name            = "scale-out-frontend"
      adjustment      = 1
      adjustment_type = "ChangeInCapacity"
      cooldown        = 60
    }
    scale_in = {
      name            = "scale-in-frontend"
      adjustment      = -1
      adjustment_type = "ChangeInCapacity"
      cooldown        = 60
    }
  }
}

variable "frontend_cloudwatch_alarms" {
  description = "CloudWatch alarm configurations for frontend ASG"
  type = map(object({
    alarm_name          = string
    metric_name         = string
    namespace           = string
    period              = number
    statistic           = string
    threshold           = number
    comparison_operator = string
    evaluation_periods  = number
    description         = string
    treat_missing_data  = string
  }))
  default = {
    scale_out = {
      alarm_name          = "scale-out-frontend-cpu"
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 60
      statistic           = "Average"
      threshold           = 40
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 1
      description         = "Scale out if CPU > 40% for 1 minute"
      treat_missing_data  = "notBreaching"
    }
    scale_in = {
      alarm_name          = "scale-in-frontend-cpu"
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 60
      statistic           = "Average"
      threshold           = 10
      comparison_operator = "LessThanOrEqualToThreshold"
      evaluation_periods  = 1
      description         = "Scale in if CPU <= 10% for 1 minute"
      treat_missing_data  = "notBreaching"
    }
  }
}

variable "security_group_id_falb" {
  description = "Security Group ID for Application Load Balancer"
  type        = string
  default     = null
}

variable "frontend_alb_sg_name" {
  description = "value"
  type        = string
  default     = "Soquiat-FrontedALB-SG"
}

variable "alb_name" {
  type    = string
  default = "Soquiat-FrontEndALB"
}

variable "is_internal" {
  type    = bool
  default = false
}

variable "alb_idle_timeout" {
  type    = number
  default = 60
}

variable "enable_deletion_protection" {
  type    = bool
  default = false
}

variable "listener_port" {
  type    = number
  default = 80
}

variable "listener_protocol" {
  type    = string
  default = "HTTP"
}

variable "target_group_name" {
  type    = string
  default = "Soquiat-FrontendTG"
}

variable "target_group_port" {
  type    = number
  default = 80
}

variable "target_group_protocol" {
  type    = string
  default = "HTTP"
}

variable "target_type" {
  type    = string
  default = "instance"
}

variable "health_check_config" {
  type = object({
    protocol            = string
    path                = string
    port                = string
    unhealthy_threshold = number
    healthy_threshold   = number
    timeout             = number
    interval            = number
    matcher             = string
  })
  default = {
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    unhealthy_threshold = 2
    healthy_threshold   = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

variable "tags" {
  type = map(string)
  default = {
    "Name"        = "Soquiat-FinalProject"
    "ProjectCode" = "Terraform101-CloudIntern"
    "Engineer"    = "Soquiat-MarcHendri"
  }
}