module "statefile-statelocking" {
  source = "../root/modules/tfstate-statelocking"
  s3_bucket_name = "soquiat-capstone-demo-1"
}