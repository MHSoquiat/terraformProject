variable "ami" {
  default = "ami-00ca32bbc84273381"
}

variable "key_name" {
  description = "value"
  type        = string
  default     = "Soki-TFFinalAct"
}

variable "tags" {
  type = map(string)
  default = {
    "Name"        = "Soquiat-FinalProject"
    "ProjectCode" = "Terraform101-CloudIntern"
    "Engineer"    = "Soquiat-MarcHendri"
  }
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID to which the Bastion Host will be deployed"
  type = string
}

variable "instance_name" {
  type    = string
  default = "BastionHost"
}

variable "vpc_id" {
  description = "VPC ID to which the Bastion Host is deployed"
  type = string
}

variable "security_group_id" {
  description = "Optional custom security group ID for the Module"
  type        = string
  default     = null
}

variable "bastion_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to SSH into the bastion host"
  type        = list(string)
  default     = [
    "112.200.10.226/32",
    "203.82.34.178/32",
    "0.0.0.0/0"
  ]
}
