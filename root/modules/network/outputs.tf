output "vpc_id" {
  value = aws_vpc.soki-vpc.id
}

output "all_subnet_ids" {
  value = { for k, s in aws_subnet.subnet : k => s.id }
}
