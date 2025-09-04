output "bucket" {
  value = aws_s3_bucket.statefile.id
}
output "region" {
  value = aws_s3_bucket.statefile.region
}
output "dynamodb_table" {
  value = aws_dynamodb_table.state_lock.id
}