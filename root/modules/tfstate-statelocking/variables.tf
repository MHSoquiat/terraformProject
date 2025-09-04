variable "s3_bucket_name" {
  description = "The name of the S3 bucket to store the Terraform state"
  type        = string
  default     = "soquiat-tffinal-s3"
}

variable "s3_bucket_tags" {
  description = "Tags to apply to the S3 bucket"
  type        = map(string)
  default = {
    Name = "soquiat-tffinal-s3"
  }
}

variable "enable_s3_versioning" {
  description = "Enable versioning on the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_lifecycle_transition_days" {
  description = "Number of days after which to transition to STANDARD_IA and GLACIER"
  type = object({
    standard_ia_days = number
    glacier_days     = number
    noncurrent_days  = number
    abort_days       = number
  })
  default = {
    standard_ia_days = 30
    glacier_days     = 90
    noncurrent_days  = 30
    abort_days       = 7
  }
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for state locking"
  type        = string
  default     = "soquiat-tffinal-db"
}

variable "tags" {
  default = {
    "Name"        = "Soquiat-FinalProject"
    "ProjectCode" = "Terraform101-CloudIntern"
    "Engineer"    = "Soquiat-MarcHendri"
  }
}