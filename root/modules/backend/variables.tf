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
    name          = "BackendLaunchTemplate"
    ami           = "ami-00ca32bbc84273381"
    instance_type = "t3.micro"
    key_name      = "Soki"
    monitoring    = true
    userdata_file = "backend_userdata.sh"
  }
}

variable "security_group_id_asg" {
  description = "Security Group ID for AutoScalingGroup Launch Template"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "This variable will serve as the placeholder for the subnet ID in which the ALB and ASG will be deployed"
  type = list(string)
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
  default = {
    "Name"        = "Sokii"
    "ProjectCode" = "TerraformProject"
    "Engineer"    = "Soquiat-MarcHendri"
  }
}

variable "vpc_id" {
  description = "VPC ID for various resources inside the module"
  type = string
}

variable "bastion_sg" {
  description = "This variable will serve as the placeholder for the Security Group ID of the Bastion Host"
  type = string
}

variable "fasg_sg" {
  description = "This variable will serve as the placeholder for the Security Group ID of the Front End Auto Scaling Group"
  type = string
}

variable "backend_asg_sg_name" {
  description = "value"
  type        = string
  default     = "Soquiat-BackendSG"
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
    name                      = "SoquiatBackendASG"
    name_tag                  = "Soquiat-BackEndEc2"
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

variable "scaling_policies" {
  description = "Scaling policy configuration for Auto Scaling Group"
  type = map(object({
    name            = string
    adjustment      = number
    adjustment_type = string
    cooldown        = number
  }))
  default = {
    scale_out = {
      name            = "scale-out-backend"
      adjustment      = 1
      adjustment_type = "ChangeInCapacity"
      cooldown        = 60
    }
    scale_in = {
      name            = "scale-in-backend"
      adjustment      = -1
      adjustment_type = "ChangeInCapacity"
      cooldown        = 60
    }
  }
}


variable "cloudwatch_alarms" {
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
      alarm_name          = "scale-out-backend-cpu"
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 60
      statistic           = "Average"
      threshold           = 40
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 1
      description         = "Scale out if CPU > 40% for 1 minute"
      treat_missing_data  = "notBreaching"
    }
    scale_in = {
      alarm_name          = "scale-in-backend-cpu"
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 60
      statistic           = "Average"
      threshold           = 10
      comparison_operator = "LessThanOrEqualToThreshold"
      evaluation_periods  = 1
      description         = "Scale in if CPU <= 10% for 1 min"
      treat_missing_data  = "notBreaching"
    }
  }
}

variable "backend_alb_sg_name" {
  description = "value"
  type        = string
  default     = "Soquiat-BackendALB-SG"
}

variable "security_group_id_balb" {
  description = "Security Group ID for Application Load Balancer"
  type        = string
  default     = null
}

variable "alb_name" {
  type    = string
  default = "Soquiat-BackendALB"
}

variable "is_internal" {
  type    = bool
  default = true
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
  default = "Soquiat-BackendTG"
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

