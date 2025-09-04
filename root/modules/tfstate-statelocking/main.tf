resource "aws_s3_bucket" "statefile" {
  bucket = var.s3_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = var.s3_bucket_tags
}

resource "aws_s3_bucket_versioning" "tfstate_versioning" {
  count  = var.enable_s3_versioning ? 1 : 0
  bucket = aws_s3_bucket.statefile.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tfstate_lifecycle" {
  bucket = aws_s3_bucket.statefile.id

  rule {
    id     = "lifecycle-rules"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = var.s3_lifecycle_transition_days.noncurrent_days
    }

    transition {
      days          = var.s3_lifecycle_transition_days.standard_ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.s3_lifecycle_transition_days.glacier_days
      storage_class = "GLACIER"
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = var.s3_lifecycle_transition_days.abort_days
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_encryption" {
  bucket = aws_s3_bucket.statefile.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "state_lock" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}