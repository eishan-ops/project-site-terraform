output "subnets" {
  value = local.flat_subnets
}

output "subnet_ids" {
  value = { for key, value in aws_subnet.main : key => value.id }
  # above means -> the entire subnet object(value) has subnet ID as a key
}

output "security_group_ids" {
  value = { for key, value in aws_security_group.main : key => value.id }
  # above means -> the entire Security Group object(value) has SG ID as a key
}