# ######
# # security groups 

locals {
    flat_security_groups = flatten([ for vpc in var.vpc : [
        for security_group_name in vpc.security_groups : {
            vpc_name = vpc.name
            security_group_name = security_group_name
        }
      ]
    ])
}


resource "aws_security_group" "allow_tls" {
  for_each = { for security_group in local.flat_security_groups : security_group.security_group_name => security_group } 
  name        = each.key
  description = "something -something"
  vpc_id      = aws_vpc.main[each.value.vpc_name].id

  tags = {
    Name = each.key
  }
}