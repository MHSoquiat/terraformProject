variable "tags" {
  type = map(string)
  default = {
    "Name"        = "Soquiat-FinalProject"
    "ProjectCode" = "Terraform101-CloudIntern"
    "Engineer"    = "Soquiat-MarcHendri"
  }
}

variable "vpc_cidr" {
  description = "CIDR Block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet" {
  type = map(object({
    az   = string
    cidr = string
    pub  = bool
  }))
  default = {
    pub_sub-1 = {
      az   = "us-east-1a"
      cidr = "10.0.1.0/24"
      pub  = true
    }
    pub_sub-2 = {
      az   = "us-east-1b"
      cidr = "10.0.2.0/24"
      pub  = true
    }
    priv_sub-1 = {
      az   = "us-east-1a"
      cidr = "10.0.3.0/24"
      pub  = false
    }
    priv_sub-2 = {
      az   = "us-east-1a"
      cidr = "10.0.4.0/24"
      pub  = false
    }
    priv_sub-3 = {
      az   = "us-east-1b"
      cidr = "10.0.5.0/24"
      pub  = false
    }
    priv_sub-4 = {
      az   = "us-east-1b"
      cidr = "10.0.6.0/24"
      pub  = false
    }
  }
}

variable "pub_subnet_keys" {
  type    = set(string)
  default = ["pub_sub-1", "pub_sub-2"]
}

variable "priv_subnet_keys" {
  type    = set(string)
  default = ["priv_sub-1", "priv_sub-2", "priv_sub-3", "priv_sub-4"]
}
