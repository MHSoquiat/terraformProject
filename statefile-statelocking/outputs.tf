output "bucket" {
  value = module.statefile-statelocking.bucket
}
output "region" {
  value = module.statefile-statelocking.region
}
output "dynamodb_table" {
  value = module.statefile-statelocking.dynamodb_table
}